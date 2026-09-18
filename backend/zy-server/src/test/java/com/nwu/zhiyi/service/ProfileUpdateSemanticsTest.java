package com.nwu.zhiyi.service;

import com.nwu.zhiyi.api.dto.profile.ProfileUpdateRequest;
import com.nwu.zhiyi.domain.entity.Student;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

/**
 * 个人资料修改的语义测试（FR-M1-05）。
 *
 * <p><b>为什么这个测试重要</b>：本接口的字段语义是
 * <b>null = 不修改，空串 = 清空</b>。前端提交的是整份表单，而用户通常只改一项，
 * 若把 null 也当成清空，一次误提交就会把学院、专业、简介全部抹掉 ——
 * 这类"静默丢数据"不会报错，用户过几天才发现资料没了。
 * 因此必须有测试把这个语义钉死。
 *
 * <p><b>为什么手写假 Mapper 而不是用 Mockito</b>：本项目测试依赖里没有 mock 框架，
 * 而 {@link StudentMapper} 继承 MyBatis-Plus 的 {@code BaseMapper}，方法极多。
 * 这里用 {@link Proxy} 只实现用到的方法，既避免引入新依赖，
 * 也不会因为 BaseMapper 升级而让测试编译不过。
 *
 * @author 李泽宬
 */
@DisplayName("M1 - 个人资料修改语义（null 不修改 / 空串清空）")
class ProfileUpdateSemanticsTest {

    /** 记录所有 updateById 的入参，供断言"到底改了什么" */
    private final List<Student> updates = new ArrayList<>();

    /**
     * 构造一个只支持 selectOne / selectById / updateById 的假 Mapper。
     *
     * @param stored 数据库里的"当前"用户；updateById 会就地合并到它上面，
     *               以便模拟"写库后再查出来"的行为
     */
    private StudentMapper fakeMapper(Student stored) {
        InvocationHandler handler = (proxy, method, args) -> {
            String name = method.getName();
            switch (name) {
                case "selectOne":
                case "selectById":
                    return stored;
                case "updateById":
                    Student patch = (Student) args[0];
                    updates.add(patch);
                    /*
                     * 模拟 MyBatis-Plus 的 FieldStrategy.NOT_NULL：
                     * 只更新非 null 的列。空串是"有效值"，照常写入。
                     * 这个行为正是"清空必须写空串而不是 null"的根源。
                     */
                    if (patch.getNickname() != null) stored.setNickname(patch.getNickname());
                    if (patch.getCollege() != null) stored.setCollege(patch.getCollege());
                    if (patch.getMajor() != null) stored.setMajor(patch.getMajor());
                    if (patch.getGrade() != null) stored.setGrade(patch.getGrade());
                    if (patch.getIntro() != null) stored.setIntro(patch.getIntro());
                    if (patch.getAvatar() != null) stored.setAvatar(patch.getAvatar());
                    return 1;
                case "toString":
                    return "FakeStudentMapper";
                default:
                    // 返回类型的默认值，避免误调用时抛 NPE 掩盖真实断言
                    Class<?> rt = method.getReturnType();
                    if (rt == boolean.class) return false;
                    if (rt == int.class) return 0;
                    if (rt == long.class) return 0L;
                    return null;
            }
        };
        return (StudentMapper) Proxy.newProxyInstance(
                StudentMapper.class.getClassLoader(), new Class<?>[]{StudentMapper.class}, handler);
    }

    private AuthService serviceWith(StudentMapper mapper) {
        /*
         * AuthService 的构造顺序（Lombok @RequiredArgsConstructor 按字段声明序）：
         *   studentMapper, userSkillProfileMapper, tokenProvider, passwordEncoder
         * 本测试只走 updateProfile 这一条路径，其余依赖不会被触及，传 null 即可。
         */
        return new AuthService(mapper, null, null, new BCryptPasswordEncoder(4));
    }

    private Student sampleStudent() {
        return new Student()
                .setId(1L)
                .setSno("2024117420")
                .setSname("李泽宬")
                .setNickname("知驿·漫游")
                .setCollege("计算机学院")
                .setMajor("软件工程")
                .setGrade("2024级")
                .setIntro("原简介")
                .setCreditScore(103)
                .setRole(com.nwu.zhiyi.common.enums.UserRole.USER);
    }

    @Test
    @DisplayName("只改一个字段时，未提交的字段必须保持原值（不被 null 清空）")
    void nullMeansDoNotModify() {
        Student stored = sampleStudent();
        AuthService service = serviceWith(fakeMapper(stored));

        ProfileUpdateRequest req = new ProfileUpdateRequest();
        req.setIntro("改过的简介");   // 只改简介
        // 其余字段全部留 null

        service.updateProfile("2024117420", req);

        assertEquals("改过的简介", stored.getIntro(), "简介应被更新");
        assertEquals("知驿·漫游", stored.getNickname(), "未提交的昵称不能被清空");
        assertEquals("计算机学院", stored.getCollege(), "未提交的学院不能被清空");
        assertEquals("软件工程", stored.getMajor(), "未提交的专业不能被清空");
        assertEquals("2024级", stored.getGrade(), "未提交的年级不能被清空");
        assertEquals(1, updates.size(), "应恰好写库一次");
    }

    @Test
    @DisplayName("传空串表示清空该字段（落库为空串而非 NULL）")
    void emptyStringClears() {
        Student stored = sampleStudent();
        AuthService service = serviceWith(fakeMapper(stored));

        ProfileUpdateRequest req = new ProfileUpdateRequest();
        req.setIntro("");       // 明确要清空
        req.setNickname("   "); // 纯空白等同于清空

        service.updateProfile("2024117420", req);

        /*
         * 断言空串而不是 null，这是有意的：
         * MyBatis-Plus 的 updateById 会跳过值为 null 的字段，
         * 所以"清空"必须落成空串 —— 若写成 null，实际效果是"什么都没改"，
         * 而这个缺陷正是本测试首次运行时抓出来的。
         */
        assertEquals("", stored.getIntro(), "空串应清空简介");
        assertEquals("", stored.getNickname(), "纯空白应清空昵称");
        assertEquals("", stored.getNickname(), "清空后昵称不应为 null");
        // 展示名应回退到实名（displayName 用 isEmpty 判空，空串同样触发回退）
        assertEquals("李泽宬", stored.displayName(), "昵称清空后应回退到实名展示");
    }

    @Test
    @DisplayName("字段值首尾空白应被裁剪")
    void valuesAreTrimmed() {
        Student stored = sampleStudent();
        AuthService service = serviceWith(fakeMapper(stored));

        ProfileUpdateRequest req = new ProfileUpdateRequest();
        req.setIntro("  有内容的简介  ");
        req.setCollege("  信息学院  ");

        service.updateProfile("2024117420", req);

        assertEquals("有内容的简介", stored.getIntro());
        assertEquals("信息学院", stored.getCollege());
    }

    @Test
    @DisplayName("学号、姓名、角色、信用值不可经本接口改动")
    void protectedFieldsAreNeverTouched() {
        Student stored = sampleStudent();
        AuthService service = serviceWith(fakeMapper(stored));

        ProfileUpdateRequest req = new ProfileUpdateRequest();
        req.setIntro("随便改改");

        service.updateProfile("2024117420", req);

        assertEquals("2024117420", stored.getSno(), "学号是全平台业务关联键，不可改");
        assertEquals("李泽宬", stored.getSname(), "姓名属实名信息，需走核验流程");
        assertEquals(com.nwu.zhiyi.common.enums.UserRole.USER, stored.getRole(), "角色是治理结果");
        assertEquals(103, stored.getCreditScore(), "信用值由 M8 调整");
    }

    @Test
    @DisplayName("全部字段都未提交时不写库，也不报错")
    void emptyRequestIsNoop() {
        Student stored = sampleStudent();
        AuthService service = serviceWith(fakeMapper(stored));

        var vo = service.updateProfile("2024117420", new ProfileUpdateRequest());

        assertEquals(0, updates.size(), "无任何字段提交时不应写库");
        assertNotNull(vo, "应正常回显当前资料，而不是抛异常");
        assertEquals("知驿·漫游", vo.getDisplayName());
    }
}

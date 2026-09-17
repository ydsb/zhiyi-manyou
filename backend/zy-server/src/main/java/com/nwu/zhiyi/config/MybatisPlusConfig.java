package com.nwu.zhiyi.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.BlockAttackInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;

/**
 * MyBatis-Plus 配置：分页插件、防全表更新删除、字段自动填充。
 *
 * @author 李泽宬
 */
@Configuration
public class MybatisPlusConfig {

    /**
     * 插件链：分页 + 攻击防护（禁止无 where 的全表 update/delete）。
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        interceptor.addInnerInterceptor(new BlockAttackInnerInterceptor());
        return interceptor;
    }

    /**
     * created_at / updated_at / occurred_at 自动填充。
     *
     * <p><b>为什么不能只靠数据库默认值</b>：MyBatis-Plus 的 insert 会把实体的全部字段
     * （包括值为 null 的）都拼进 SQL，显式传 NULL 会覆盖掉 DDL 里的
     * {@code DEFAULT CURRENT_TIMESTAMP}，从而报 "Column cannot be null"。
     * 因此凡是"必须自动产生的时间戳"都要在这里填。
     * （本项目在 {@code zy_collab_event.occurred_at} 上踩过这个坑。）
     */
    @Bean
    public MetaObjectHandler metaObjectHandler() {
        return new MetaObjectHandler() {
            @Override
            public void insertFill(MetaObject metaObject) {
                LocalDateTime now = LocalDateTime.now();
                this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, now);
                this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, now);
                this.strictInsertFill(metaObject, "occurredAt", LocalDateTime.class, now);
            }

            @Override
            public void updateFill(MetaObject metaObject) {
                this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
            }
        };
    }
}

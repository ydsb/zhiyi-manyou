package com.nwu.zhiyi;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * 知驿·漫游 —— 跨学科技能交换与学习记录平台 服务端启动类。
 *
 * <p>启动后：
 * <ul>
 *   <li>接口根地址：http://localhost:8080/api</li>
 *   <li>健康检查：http://localhost:8080/api/health</li>
 *   <li>运维端点：http://localhost:8080/actuator/health</li>
 * </ul>
 *
 * <p>{@code @EnableScheduling} 用于 M5 的协作出勤提醒定时任务
 * （{@code CollaborationReminderJob}）—— 逾期是时间流逝产生的事实，没有用户动作触发，
 * 只能在时间维度上扫描。
 *
 * @author 李泽宬
 */
@SpringBootApplication
@EnableScheduling
@EnableTransactionManagement
@MapperScan("com.nwu.zhiyi.**.mapper")
public class ZhiYiApplication {

    public static void main(String[] args) {
        SpringApplication.run(ZhiYiApplication.class, args);
    }
}

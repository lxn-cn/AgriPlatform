package com.agri.platform;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 天津地方农特产推广服务平台后端启动类
 */
@SpringBootApplication
@MapperScan("com.agri.platform.mapper")
public class AgriPlatformApplication {

    public static void main(String[] args) {
        SpringApplication.run(AgriPlatformApplication.class, args);
    }
}

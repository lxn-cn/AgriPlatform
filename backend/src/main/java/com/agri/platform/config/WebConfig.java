package com.agri.platform.config;

import com.agri.platform.interceptor.JwtInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

/**
 * Web MVC 配置：注册 JWT 拦截器、静态资源映射
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private JwtInterceptor jwtInterceptor;

    /** 本地上传目录（application.yml app.upload-dir，相对路径基于工作目录） */
    @Value("${app.upload-dir:upload}")
    private String uploadDir;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtInterceptor)
                .addPathPatterns("/api/**")
                // 登录、占位图、商家入驻申请无需令牌
                //（上传接口 /api/file/upload 不再匿名，角色由 FileController 自校验）
                .excludePathPatterns("/api/auth/**", "/api/file/placeholder/**", "/api/merchant/apply");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
        // 本地上传图片：URL /upload/** → 工作目录下 upload/ 文件夹
        //（file: 映射在 jar 部署下依然可写，不受 classpath 限制）
        String location = Paths.get(uploadDir).toAbsolutePath().normalize().toUri().toString();
        if (!location.endsWith("/")) {
            // resource location 必须以 / 结尾，toUri() 对不存在的目录不带尾斜杠
            location += "/";
        }
        registry.addResourceHandler("/upload/**").addResourceLocations(location);
    }
}

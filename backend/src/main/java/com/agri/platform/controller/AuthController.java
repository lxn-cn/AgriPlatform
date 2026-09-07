package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.dto.AuthDtos;
import com.agri.platform.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.Map;

/**
 * 认证接口：小程序登录、管理端登录（WebConfig 已放行 /api/auth/**）
 */
@RestController
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /** 小程序登录（演示：code 模拟 openid，自动注册） */
    @PostMapping("/api/auth/wx-login")
    public Result<Map<String, Object>> wxLogin(@Valid @RequestBody AuthDtos.WxLoginRequest request) {
        return Result.ok(authService.wxLogin(request));
    }

    /** 管理端登录（ADMIN / MERCHANT） */
    @PostMapping("/api/auth/login")
    public Result<Map<String, Object>> login(@Valid @RequestBody AuthDtos.LoginRequest request) {
        return Result.ok(authService.login(request));
    }
}

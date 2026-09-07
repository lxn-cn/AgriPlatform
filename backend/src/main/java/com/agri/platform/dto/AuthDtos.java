package com.agri.platform.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.io.Serializable;

/**
 * 认证相关请求对象
 */
public final class AuthDtos {

    private AuthDtos() {
    }

    /** 管理端登录请求 */
    @Data
    public static class LoginRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotBlank(message = "请输入账号")
        private String username;

        @NotBlank(message = "请输入密码")
        private String password;

        /** ADMIN / MERCHANT */
        @NotBlank(message = "请选择登录角色")
        private String role;
    }

    /** 小程序登录请求 */
    @Data
    public static class WxLoginRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotBlank(message = "登录 code 不能为空")
        private String code;

        /** 昵称（首次注册时使用，可空） */
        private String nickname;
    }
}

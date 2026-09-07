package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.entity.User;
import com.agri.platform.service.UserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.io.Serializable;

/**
 * 小程序用户账号接口
 */
@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /** 当前用户信息 */
    @GetMapping("/api/user/me")
    public Result<User> me() {
        return Result.ok(userService.me());
    }

    /** 修改昵称/头像/手机号 */
    @PutMapping("/api/user/me")
    public Result<User> updateMe(@RequestBody UpdateMeRequest request) {
        return Result.ok(userService.updateMe(request.getNickname(), request.getAvatar(), request.getPhone()));
    }

    /** 个人信息修改请求 */
    @Data
    public static class UpdateMeRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        private String nickname;
        private String avatar;
        private String phone;
    }
}

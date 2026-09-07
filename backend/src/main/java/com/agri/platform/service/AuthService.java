package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.dto.AuthDtos;
import com.agri.platform.entity.Merchant;
import com.agri.platform.entity.SysAdmin;
import com.agri.platform.entity.User;
import com.agri.platform.mapper.MerchantMapper;
import com.agri.platform.mapper.SysAdminMapper;
import com.agri.platform.mapper.UserMapper;
import com.agri.platform.util.JwtUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 认证服务：小程序模拟微信登录、管理端账号密码登录
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserMapper userMapper;
    private final MerchantMapper merchantMapper;
    private final SysAdminMapper sysAdminMapper;
    private final JwtUtil jwtUtil;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * 小程序登录：演示环境将 code 模拟为 openid=mock_<code>，自动注册
     */
    public Map<String, Object> wxLogin(AuthDtos.WxLoginRequest request) {
        String openid = "mock_" + request.getCode();
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getOpenid, openid));
        if (user == null) {
            user = new User();
            user.setOpenid(openid);
            String nickname = request.getNickname();
            if (nickname == null || nickname.trim().isEmpty()) {
                nickname = "微信用户" + openid.substring(openid.length() - 4);
            }
            user.setNickname(nickname.trim());
            user.setAvatar("");
            user.setPhone("");
            user.setStatus(Constants.USER_NORMAL);
            user.setCreateTime(LocalDateTime.now());
            user.setUpdateTime(LocalDateTime.now());
            userMapper.insert(user);
        }
        if (user.getStatus() == Constants.USER_DISABLED) {
            throw new BizException("该账号已被禁用，请联系平台客服");
        }
        String token = jwtUtil.createUserToken(user.getId(), user.getNickname());
        return buildResult(token, buildUserInfo(user));
    }

    /**
     * 管理端登录：role 为 ADMIN（平台管理员）或 MERCHANT（商家）
     */
    public Map<String, Object> login(AuthDtos.LoginRequest request) {
        String role = request.getRole();
        if (Constants.ROLE_MERCHANT.equals(role)) {
            return merchantLogin(request);
        }
        if (Constants.ROLE_ADMIN.equals(role)) {
            return adminLogin(request);
        }
        throw new BizException("登录角色不合法");
    }

    private Map<String, Object> merchantLogin(AuthDtos.LoginRequest request) {
        Merchant merchant = merchantMapper.selectOne(
                new LambdaQueryWrapper<Merchant>().eq(Merchant::getUsername, request.getUsername()));
        if (merchant == null || !encoder.matches(request.getPassword(), merchant.getPasswordHash())) {
            throw new BizException("用户名或密码错误");
        }
        if (merchant.getStatus() == Constants.MERCHANT_BANNED) {
            throw new BizException("商家账号已被封禁，请联系平台");
        }
        String token = jwtUtil.createMerchantToken(merchant.getId(), merchant.getName());

        Map<String, Object> userInfo = new LinkedHashMap<String, Object>();
        userInfo.put("id", merchant.getId());
        userInfo.put("username", merchant.getUsername());
        userInfo.put("name", merchant.getName());
        userInfo.put("role", Constants.ROLE_MERCHANT);
        userInfo.put("status", merchant.getStatus());
        userInfo.put("rejectReason", merchant.getRejectReason());
        return buildResult(token, userInfo);
    }

    private Map<String, Object> adminLogin(AuthDtos.LoginRequest request) {
        SysAdmin admin = sysAdminMapper.selectOne(
                new LambdaQueryWrapper<SysAdmin>().eq(SysAdmin::getUsername, request.getUsername()));
        if (admin == null || !encoder.matches(request.getPassword(), admin.getPasswordHash())) {
            throw new BizException("用户名或密码错误");
        }
        if (admin.getStatus() != null && admin.getStatus() == 0) {
            throw new BizException("该管理员账号已被停用");
        }
        // 商家账号不允许以管理员角色登录管理端
        String token = jwtUtil.createAdminToken(admin.getId(), admin.getName(), admin.getRole());

        Map<String, Object> userInfo = new LinkedHashMap<String, Object>();
        userInfo.put("id", admin.getId());
        userInfo.put("username", admin.getUsername());
        userInfo.put("name", admin.getName());
        userInfo.put("role", admin.getRole());
        userInfo.put("status", admin.getStatus());
        return buildResult(token, userInfo);
    }

    private Map<String, Object> buildUserInfo(User user) {
        Map<String, Object> userInfo = new LinkedHashMap<String, Object>();
        userInfo.put("id", user.getId());
        userInfo.put("nickname", user.getNickname());
        userInfo.put("avatar", user.getAvatar());
        userInfo.put("phone", user.getPhone());
        userInfo.put("role", Constants.ROLE_USER);
        return userInfo;
    }

    private Map<String, Object> buildResult(String token, Map<String, Object> userInfo) {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("token", token);
        result.put("userInfo", userInfo);
        return result;
    }
}

package com.agri.platform.interceptor;

import com.agri.platform.common.Constants;
import com.agri.platform.entity.Merchant;
import com.agri.platform.mapper.MerchantMapper;
import com.agri.platform.util.JwtUtil;
import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;

/**
 * JWT 鉴权拦截器：
 * - /api/admin/** 需要 ADMIN 角色（其中 /api/admin/admins/** 仅 SUPER 可用）
 * - /api/merchant/** 需要 MERCHANT 角色且商家状态已通过（/api/merchant/apply 已在 WebConfig 放行；
 *   待审核/已驳回商家仅允许访问 /api/merchant/profile 查看审核结果与维护信息）
 * - 其余 /api/** 可选登录：游客无 token 放行，有合法 token 则把用户信息塞进 request attribute
 */
@Slf4j
@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private MerchantMapper merchantMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        // CORS 预检直接放行
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String uri = request.getRequestURI();
        String auth = request.getHeader("Authorization");
        String token = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            token = auth.substring(7).trim();
        }

        Claims claims = null;
        if (token != null && !token.isEmpty()) {
            try {
                claims = jwtUtil.parse(token);
            } catch (Exception e) {
                claims = null;
            }
        }

        // ---- 管理端：/api/admin/** ----
        if (uri.startsWith("/api/admin/")) {
            if (claims == null) {
                return reject(response, 401, "未登录或令牌失效");
            }
            String role = claims.get(JwtUtil.CLAIM_ROLE, String.class);
            if (!Constants.ROLE_ADMIN.equals(role) && !Constants.ROLE_SUPER.equals(role)) {
                return reject(response, 403, "无权限访问");
            }
            // 管理员账号管理仅 SUPER 可用
            if (uri.startsWith("/api/admin/admins") && !Constants.ROLE_SUPER.equals(role)) {
                return reject(response, 403, "仅超级管理员可操作");
            }
            fillAttrs(request, claims);
            return true;
        }

        // ---- 商家端：/api/merchant/**（/api/merchant/apply 已被 exclude） ----
        if (uri.startsWith("/api/merchant/")) {
            if (claims == null) {
                return reject(response, 401, "未登录或令牌失效");
            }
            String role = claims.get(JwtUtil.CLAIM_ROLE, String.class);
            if (!Constants.ROLE_MERCHANT.equals(role)) {
                return reject(response, 403, "无权限访问，请使用商家账号登录");
            }
            Long merchantId = claims.get(JwtUtil.CLAIM_MERCHANT_ID, Long.class);
            Merchant merchant = merchantId == null ? null : merchantMapper.selectById(merchantId);
            if (merchant == null) {
                return reject(response, 401, "商家账号不存在");
            }
            if (merchant.getStatus() == Constants.MERCHANT_BANNED) {
                return reject(response, 403, "商家账号已被封禁，请联系平台");
            }
            // 待审核/已驳回商家仅可访问 profile
            if (merchant.getStatus() != Constants.MERCHANT_APPROVED
                    && !uri.startsWith("/api/merchant/profile")) {
                return reject(response, 403, "商家尚未通过平台审核，暂无法使用该功能");
            }
            fillAttrs(request, claims);
            return true;
        }

        // ---- 其余 /api/**：可选登录（游客接口无 token 也放行） ----
        if (claims != null) {
            fillAttrs(request, claims);
        }
        return true;
    }

    private void fillAttrs(HttpServletRequest request, Claims claims) {
        String role = claims.get(JwtUtil.CLAIM_ROLE, String.class);
        request.setAttribute(Constants.ATTR_ROLE, role);
        request.setAttribute(Constants.ATTR_NAME, claims.get(JwtUtil.CLAIM_NAME, String.class));
        Long userId = claims.get(JwtUtil.CLAIM_USER_ID, Long.class);
        if (userId != null) {
            request.setAttribute(Constants.ATTR_USER_ID, userId);
        }
        Long merchantId = claims.get(JwtUtil.CLAIM_MERCHANT_ID, Long.class);
        if (merchantId != null) {
            request.setAttribute(Constants.ATTR_MERCHANT_ID, merchantId);
        }
        Long adminId = claims.get(JwtUtil.CLAIM_ADMIN_ID, Long.class);
        if (adminId != null) {
            request.setAttribute(Constants.ATTR_ADMIN_ID, adminId);
        }
    }

    private boolean reject(HttpServletResponse response, int code, String msg) throws Exception {
        response.setStatus(code);
        response.setContentType("application/json;charset=UTF-8");
        String body = "{\"code\":" + code + ",\"msg\":\"" + msg + "\",\"data\":null}";
        response.getOutputStream().write(body.getBytes(StandardCharsets.UTF_8));
        return false;
    }
}

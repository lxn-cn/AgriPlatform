package com.agri.platform.util;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

/**
 * 登录上下文工具：从 request attribute 中取当前登录主体
 * （attribute 由 JwtInterceptor 写入）
 */
public final class AuthContext {

    private AuthContext() {
    }

    private static HttpServletRequest request() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            throw new BizException("当前无请求上下文");
        }
        return attrs.getRequest();
    }

    private static Long getLong(String name) {
        Object v = request().getAttribute(name);
        return v == null ? null : (Long) v;
    }

    /** 当前登录用户 id（未登录抛出异常） */
    public static Long userId() {
        Long id = getLong(Constants.ATTR_USER_ID);
        if (id == null) {
            throw new BizException("请先登录");
        }
        return id;
    }

    /** 当前登录商家 id */
    public static Long merchantId() {
        Long id = getLong(Constants.ATTR_MERCHANT_ID);
        if (id == null) {
            throw new BizException("商家未登录");
        }
        return id;
    }

    /** 当前登录管理员 id */
    public static Long adminId() {
        Long id = getLong(Constants.ATTR_ADMIN_ID);
        if (id == null) {
            throw new BizException("管理员未登录");
        }
        return id;
    }

    /** 当前登录用户 id（未登录返回 null，游客场景） */
    public static Long currentUserIdOrNull() {
        return getLong(Constants.ATTR_USER_ID);
    }

    /** 当前登录者名称 */
    public static String name() {
        Object v = request().getAttribute(Constants.ATTR_NAME);
        return v == null ? "" : String.valueOf(v);
    }
}

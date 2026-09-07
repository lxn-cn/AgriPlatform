package com.agri.platform.util;

import com.agri.platform.common.Constants;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 工具：生成/解析令牌。
 * claims 含 role、对应主体 id（userId/merchantId/adminId）、name；有效期 7 天。
 */
@Component
public class JwtUtil {

    public static final String CLAIM_ROLE = "role";
    public static final String CLAIM_USER_ID = "userId";
    public static final String CLAIM_MERCHANT_ID = "merchantId";
    public static final String CLAIM_ADMIN_ID = "adminId";
    public static final String CLAIM_NAME = "name";

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expire-days:7}")
    private int expireDays;

    /** 小程序用户令牌 */
    public String createUserToken(Long userId, String name) {
        Map<String, Object> claims = new HashMap<String, Object>();
        claims.put(CLAIM_ROLE, Constants.ROLE_USER);
        claims.put(CLAIM_USER_ID, userId);
        claims.put(CLAIM_NAME, name == null ? "" : name);
        return build(claims);
    }

    /** 商家令牌 */
    public String createMerchantToken(Long merchantId, String name) {
        Map<String, Object> claims = new HashMap<String, Object>();
        claims.put(CLAIM_ROLE, Constants.ROLE_MERCHANT);
        claims.put(CLAIM_MERCHANT_ID, merchantId);
        claims.put(CLAIM_NAME, name == null ? "" : name);
        return build(claims);
    }

    /** 管理员令牌（role 为 ADMIN 或 SUPER） */
    public String createAdminToken(Long adminId, String name, String role) {
        Map<String, Object> claims = new HashMap<String, Object>();
        claims.put(CLAIM_ROLE, role);
        claims.put(CLAIM_ADMIN_ID, adminId);
        claims.put(CLAIM_NAME, name == null ? "" : name);
        return build(claims);
    }

    private String build(Map<String, Object> claims) {
        long now = System.currentTimeMillis();
        long exp = now + expireDays * 24L * 60L * 60L * 1000L;
        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date(now))
                .setExpiration(new Date(exp))
                .signWith(SignatureAlgorithm.HS256, secret)
                .compact();
    }

    /**
     * 解析令牌，失败（过期/伪造）抛出异常
     */
    public Claims parse(String token) {
        return Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
    }
}

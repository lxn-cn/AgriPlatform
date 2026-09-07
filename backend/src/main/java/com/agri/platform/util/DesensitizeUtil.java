package com.agri.platform.util;

/**
 * 敏感信息脱敏工具
 */
public final class DesensitizeUtil {

    private DesensitizeUtil() {
    }

    /**
     * 手机号脱敏：138****0001（保留前 3 位与后 4 位）
     */
    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone == null ? "" : phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}

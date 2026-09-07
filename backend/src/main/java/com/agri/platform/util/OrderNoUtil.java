package com.agri.platform.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 单号生成工具：
 * 订单号 SO + yyyyMMddHHmmssSSS；预约号 AP + yyyyMMddHHmmssSSS
 */
public final class OrderNoUtil {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");

    private OrderNoUtil() {
    }

    public static String next(String prefix) {
        return prefix + LocalDateTime.now().format(FMT);
    }

    /** 订单号 */
    public static String orderNo() {
        return next("SO");
    }

    /** 预约号 */
    public static String appointmentNo() {
        return next("AP");
    }
}

package com.agri.platform.common;

/**
 * 全局常量（状态枚举统一在此定义，避免业务代码中散落魔法数字）
 */
public final class Constants {

    private Constants() {
    }

    // ==================== 角色 ====================
    /** 小程序注册用户 */
    public static final String ROLE_USER = "USER";
    /** 商家 */
    public static final String ROLE_MERCHANT = "MERCHANT";
    /** 平台管理员 */
    public static final String ROLE_ADMIN = "ADMIN";
    /** 超级管理员（仅超级管理员可维护管理员账号） */
    public static final String ROLE_SUPER = "SUPER";

    // ==================== 用户状态（user.status：1 正常 0 禁用） ====================
    public static final int USER_NORMAL = 1;
    public static final int USER_DISABLED = 0;

    // ==================== 商家状态（merchant.status：0 待审核 1 已通过 2 已封禁 3 已驳回） ====================
    public static final int MERCHANT_PENDING = 0;
    public static final int MERCHANT_APPROVED = 1;
    public static final int MERCHANT_BANNED = 2;
    /** 驳回（schema 基础上的扩展状态，配合 reject_reason 使用） */
    public static final int MERCHANT_REJECTED = 3;

    // ==================== 预约状态（appointment.status） ====================
    /** 0 待支付 */
    public static final int APPOINTMENT_UNPAID = 0;
    /** 1 待使用（已支付） */
    public static final int APPOINTMENT_UNUSED = 1;
    /** 2 已使用（到园确认） */
    public static final int APPOINTMENT_USED = 2;
    /** 3 已取消 */
    public static final int APPOINTMENT_CANCELED = 3;
    /** 4 已过期 */
    public static final int APPOINTMENT_EXPIRED = 4;

    // ==================== 订单状态（orders.status） ====================
    /** 0 待付款 */
    public static final int ORDER_UNPAID = 0;
    /** 1 待发货（已支付） */
    public static final int ORDER_PAID = 1;
    /** 2 待收货（已发货） */
    public static final int ORDER_SHIPPED = 2;
    /** 3 已完成（已收货） */
    public static final int ORDER_FINISHED = 3;
    /** 4 已取消 */
    public static final int ORDER_CANCELED = 4;
    /** 5 退款中 */
    public static final int ORDER_REFUNDING = 5;
    /** 6 已退款 */
    public static final int ORDER_REFUNDED = 6;

    // ==================== 商品状态（product.status：1 上架 0 下架 2 待审核） ====================
    public static final int PRODUCT_ON = 1;
    public static final int PRODUCT_OFF = 0;
    public static final int PRODUCT_AUDITING = 2;

    // ==================== 通用上下架状态（farm / picking_project / banner / notice：1 上架/发布 0 下架/下线） ====================
    public static final int STATUS_ON = 1;
    public static final int STATUS_OFF = 0;

    // ==================== 评价关联类型 ====================
    public static final String REVIEW_TYPE_PRODUCT = "product";
    public static final String REVIEW_TYPE_FARM = "farm";

    // ==================== 操作人类型（oper_log.operator_type） ====================
    public static final String OPERATOR_ADMIN = "ADMIN";
    public static final String OPERATOR_MERCHANT = "MERCHANT";
    public static final String OPERATOR_USER = "USER";

    // ==================== 拦截器写入 request attribute 的键 ====================
    public static final String ATTR_ROLE = "attr.role";
    public static final String ATTR_USER_ID = "attr.userId";
    public static final String ATTR_MERCHANT_ID = "attr.merchantId";
    public static final String ATTR_ADMIN_ID = "attr.adminId";
    public static final String ATTR_NAME = "attr.name";

    // ==================== Redis 缓存键 ====================
    /** 首页轮播图缓存（TTL 5 分钟） */
    public static final String CACHE_KEY_BANNERS = "agri:home:banners";
    /** 首页公告缓存（TTL 5 分钟） */
    public static final String CACHE_KEY_NOTICES = "agri:home:notices";
    /** 用户收藏 hash 前缀：agri:fav:{userId}，field=productId */
    public static final String CACHE_KEY_FAVORITE_PREFIX = "agri:fav:";

    /** 缓存 TTL（秒） */
    public static final long CACHE_TTL_SECONDS = 300;
}

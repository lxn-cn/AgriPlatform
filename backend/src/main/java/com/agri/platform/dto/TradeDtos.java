package com.agri.platform.dto;

import lombok.Data;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.List;

/**
 * 交易类请求对象（预约 / 订单 / 评价 / 购物车）
 */
public final class TradeDtos {

    private TradeDtos() {
    }

    /** 提交采摘预约请求 */
    @Data
    public static class AppointmentCreateRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotNull(message = "请选择采摘项目")
        private Long projectId;

        @NotNull(message = "请选择预约日期")
        private LocalDate appointDate;

        @NotBlank(message = "请选择场次")
        private String session;

        @NotNull(message = "请选择人数")
        @Min(value = 1, message = "人数至少为 1")
        private Integer peopleCount;

        @NotBlank(message = "请填写预约人姓名")
        private String contactName;

        @NotBlank(message = "请填写联系电话")
        private String contactPhone;
    }

    /** 提交订单请求 */
    @Data
    public static class OrderCreateRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotNull(message = "请选择收货地址")
        private Long addressId;

        private String remark;

        @NotNull(message = "订单商品不能为空")
        private List<Item> items;

        /** 是否来自购物车结算（下单后清理对应购物车行） */
        private Boolean fromCart;
    }

    /** 订单商品行 */
    @Data
    public static class Item implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotNull(message = "商品 id 不能为空")
        private Long productId;

        @NotNull(message = "商品数量不能为空")
        @Min(value = 1, message = "商品数量至少为 1")
        private Integer quantity;

        private String spec;
    }

    /** 发布评价请求（商品/农园通用） */
    @Data
    public static class ReviewCreateRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        /** product / farm */
        @NotBlank(message = "评价类型不能为空")
        private String relType;

        @NotNull(message = "评价对象不能为空")
        private Long relId;

        /** 商品评价关联订单 */
        private Long orderId;

        /** 农园评价关联预约单 */
        private Long appointmentId;

        @NotNull(message = "请打分")
        @Min(value = 1, message = "评分最低 1 星")
        @Max(value = 5, message = "评分最高 5 星")
        private Integer rating;

        @NotBlank(message = "请填写评价内容")
        private String content;
    }

    /** 购物车行更新请求（数量/勾选，均可选） */
    @Data
    public static class CartUpdateRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @Min(value = 1, message = "数量至少为 1")
        private Integer quantity;

        /** 1 勾选 0 取消勾选 */
        private Integer checked;
    }

    /** 商家到园确认请求 */
    @Data
    public static class ConfirmArrivalRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        /** 用户报出的手机号后 4 位（选填，用于演示核对） */
        private String phoneTail;
    }
}

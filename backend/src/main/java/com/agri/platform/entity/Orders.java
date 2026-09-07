package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 订单主表（orders） */
@Data
@TableName("orders")
public class Orders implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String orderNo;
    private Long userId;
    private BigDecimal totalAmount;
    /** 0 待付款 1 待发货 2 待收货 3 已完成 4 已取消 5 退款中 6 已退款 */
    private Integer status;
    /** 收货人（快照） */
    private String receiver;
    /** 收货电话（快照） */
    private String phone;
    /** 收货地址（快照） */
    private String address;
    private String remark;
    private String refundReason;
    private LocalDateTime createTime;
    private LocalDateTime payTime;
    private LocalDateTime shipTime;
    private LocalDateTime finishTime;
    private LocalDateTime cancelTime;
}

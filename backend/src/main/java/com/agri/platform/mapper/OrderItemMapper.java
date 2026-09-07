package com.agri.platform.mapper;

import com.agri.platform.entity.OrderItem;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** 订单明细 Mapper（商家数据隔离与统计用注解 SQL） */
public interface OrderItemMapper extends BaseMapper<OrderItem> {

    /**
     * 与当前商家相关的订单 id（通过 order_item -> product 归属过滤）
     */
    @Select("SELECT DISTINCT oi.order_id FROM order_item oi "
            + "JOIN product p ON oi.product_id = p.id WHERE p.merchant_id=#{merchantId}")
    List<Long> selectMerchantOrderIds(@Param("merchantId") Long merchantId);

    /**
     * 商家销售额（已支付订单口径 1,2,3）
     */
    @Select("SELECT IFNULL(SUM(oi.price*oi.quantity),0) FROM order_item oi "
            + "JOIN orders o ON oi.order_id=o.id JOIN product p ON oi.product_id=p.id "
            + "WHERE p.merchant_id=#{merchantId} AND o.status IN (1,2,3)")
    BigDecimal sumMerchantAmount(@Param("merchantId") Long merchantId);

    /**
     * 商家销量（件数）
     */
    @Select("SELECT IFNULL(SUM(oi.quantity),0) FROM order_item oi "
            + "JOIN orders o ON oi.order_id=o.id JOIN product p ON oi.product_id=p.id "
            + "WHERE p.merchant_id=#{merchantId} AND o.status IN (1,2,3)")
    long sumMerchantQuantity(@Param("merchantId") Long merchantId);

    /**
     * 商家近 7 日销售额/订单数趋势（按支付时间）
     */
    @Select("SELECT DATE_FORMAT(o.pay_time,'%Y-%m-%d') d, COUNT(DISTINCT o.id) c, "
            + "IFNULL(SUM(oi.price*oi.quantity),0) amount FROM order_item oi "
            + "JOIN orders o ON oi.order_id=o.id JOIN product p ON oi.product_id=p.id "
            + "WHERE p.merchant_id=#{merchantId} AND o.status IN (1,2,3) AND o.pay_time>=#{start} GROUP BY d")
    List<Map<String, Object>> merchantTrend(@Param("merchantId") Long merchantId, @Param("start") LocalDateTime start);

    /**
     * 分类销售额占比（全平台，已支付订单口径）
     */
    @Select("SELECT c.name name, IFNULL(SUM(oi.price*oi.quantity),0) amount FROM order_item oi "
            + "JOIN orders o ON oi.order_id=o.id JOIN product p ON oi.product_id=p.id "
            + "JOIN category c ON p.category_id=c.id WHERE o.status IN (1,2,3) "
            + "GROUP BY c.name ORDER BY amount DESC")
    List<Map<String, Object>> categorySales();
}

package com.agri.platform.mapper;

import com.agri.platform.entity.Orders;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** 订单主表 Mapper（统计类查询用注解 SQL） */
public interface OrderMapper extends BaseMapper<Orders> {

    /**
     * 近 7 日订单量序列
     */
    @Select("SELECT DATE_FORMAT(create_time,'%Y-%m-%d') d, COUNT(*) c FROM orders "
            + "WHERE create_time>=#{start} GROUP BY d")
    List<Map<String, Object>> countByDay(@Param("start") LocalDateTime start);

    /**
     * 总交易额口径：已支付订单（待发货/待收货/已完成，不含退款中与已退款）
     */
    @Select("SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE status IN (1,2,3)")
    BigDecimal sumPaidAmount();
}

package com.agri.platform.mapper;

import com.agri.platform.entity.Product;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

/** 商品 Mapper（库存扣减/回滚用注解 SQL） */
public interface ProductMapper extends BaseMapper<Product> {

    /**
     * 支付扣库存、加销量（带库存条件，防超卖）
     */
    @Update("UPDATE product SET stock = stock - #{quantity}, sales = sales + #{quantity} "
            + "WHERE id = #{productId} AND stock >= #{quantity}")
    int deductStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);

    /**
     * 退款回滚库存、回退销量（销量不为负）
     */
    @Update("UPDATE product SET stock = stock + #{quantity}, sales = GREATEST(0, sales - #{quantity}) "
            + "WHERE id = #{productId}")
    int restoreStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);
}

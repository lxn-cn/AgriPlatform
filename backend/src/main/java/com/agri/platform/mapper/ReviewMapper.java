package com.agri.platform.mapper;

import com.agri.platform.entity.Review;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;

/** 评价 Mapper */
public interface ReviewMapper extends BaseMapper<Review> {

    /**
     * 农园平均评分（用于评价后回写 farm.rating）
     */
    @Select("SELECT IFNULL(AVG(rating),5) FROM review WHERE rel_type='farm' AND rel_id=#{farmId}")
    BigDecimal avgFarmRating(@Param("farmId") Long farmId);
}

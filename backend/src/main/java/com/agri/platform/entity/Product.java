package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 商城商品（product） */
@Data
@TableName("product")
public class Product implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long merchantId;
    private Long categoryId;
    private String name;
    private String mainImage;
    /** 详情图，逗号分隔 */
    private String images;
    private BigDecimal price;
    /** 可选规格，如 5斤装,10斤装 */
    private String specs;
    private Integer stock;
    private Integer sales;
    private String origin;
    private String description;
    /** 1 上架 0 下架 2 待审核 */
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}

package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 农园：果园/有机蔬菜农场（farm） */
@Data
@TableName("farm")
public class Farm implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long merchantId;
    private String name;
    /** 果园 / 有机蔬菜农场 */
    private String type;
    private String district;
    private String address;
    private String businessHours;
    private String intro;
    private String coverImage;
    /** 详情图，逗号分隔 */
    private String images;
    private BigDecimal avgPrice;
    private BigDecimal rating;
    private String trafficGuide;
    /** 1 上架 0 下架 */
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}

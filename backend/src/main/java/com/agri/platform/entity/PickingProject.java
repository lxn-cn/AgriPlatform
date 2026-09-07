package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 采摘项目（picking_project） */
@Data
@TableName("picking_project")
public class PickingProject implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long farmId;
    /** 品种名称，如红富士苹果采摘 */
    private String name;
    private LocalDate seasonStart;
    private LocalDate seasonEnd;
    /** 按人头门票 / 按采摘重量 */
    private String priceMode;
    private BigDecimal price;
    /** 可约场次，逗号分隔（上午,下午） */
    private String session;
    /** 场次库存（每场次可约总人数） */
    private Integer stock;
    /** 1 上架 0 下架 */
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}

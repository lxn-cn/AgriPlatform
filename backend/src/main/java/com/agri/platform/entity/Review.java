package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 评价（review）：商品/农园通用，关联类型 + 关联 id */
@Data
@TableName("review")
public class Review implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    /** product / farm */
    private String relType;
    private Long relId;
    private Long userId;
    /** 商品评价关联的订单 */
    private Long orderId;
    /** 农园评价关联的预约单 */
    private Long appointmentId;
    /** 1-5 星 */
    private Integer rating;
    private String content;
    private String images;
    private LocalDateTime createTime;
}

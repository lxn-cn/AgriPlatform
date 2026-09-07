package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 预约单（appointment） */
@Data
@TableName("appointment")
public class Appointment implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String appointmentNo;
    private Long userId;
    private Long farmId;
    private Long projectId;
    private LocalDate appointDate;
    /** 上午 / 下午 */
    private String session;
    private Integer peopleCount;
    private BigDecimal amount;
    private String contactName;
    /** 联系电话（供商家到园核对） */
    private String contactPhone;
    /** 0 待支付 1 待使用 2 已使用 3 已取消 4 已过期 */
    private Integer status;
    /** 商家端已读标记 */
    private Integer merchantRead;
    private LocalDateTime createTime;
    private LocalDateTime payTime;
    private LocalDateTime confirmTime;
    private LocalDateTime cancelTime;
}

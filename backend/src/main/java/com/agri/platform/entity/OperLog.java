package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 操作日志（oper_log）：审核、封禁、退款、强制下架、到园确认等关键操作 */
@Data
@TableName("oper_log")
public class OperLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    /** ADMIN/MERCHANT/USER */
    private String operatorType;
    private Long operatorId;
    private String operatorName;
    private String action;
    private String detail;
    private LocalDateTime createTime;
}

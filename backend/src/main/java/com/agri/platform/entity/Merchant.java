package com.agri.platform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 商家（merchant） */
@Data
@TableName("merchant")
public class Merchant implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    /** 管理端登录账号 */
    private String username;
    /** BCrypt 加密密码 */
    private String passwordHash;
    /** 商家/店铺名称 */
    private String name;
    /** 资质信息 */
    private String licenseInfo;
    private String contact;
    private String phone;
    private String intro;
    /** 0 待审核 1 已通过 2 已封禁 3 已驳回 */
    private Integer status;
    private String rejectReason;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}

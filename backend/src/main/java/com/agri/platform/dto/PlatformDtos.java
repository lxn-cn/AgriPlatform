package com.agri.platform.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;

/**
 * 平台侧请求对象（反馈 / 商家入驻与审核 / 管理员维护）
 */
public final class PlatformDtos {

    private PlatformDtos() {
    }

    /** 意见反馈请求 */
    @Data
    public static class FeedbackRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotBlank(message = "请填写反馈内容")
        private String content;

        private String contact;
    }

    /** 商家入驻申请请求 */
    @Data
    public static class MerchantApplyRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotBlank(message = "请填写登录账号")
        private String username;

        @NotBlank(message = "请填写密码")
        private String password;

        @NotBlank(message = "请填写商家/店铺名称")
        private String name;

        @NotBlank(message = "请填写资质信息")
        private String licenseInfo;

        private String contact;

        @NotBlank(message = "请填写联系电话")
        private String phone;

        private String intro;
    }

    /** 商家资料维护请求 */
    @Data
    public static class MerchantProfileRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        private String name;
        private String contact;
        private String phone;
        private String licenseInfo;
        private String intro;
    }

    /** 商家审核请求 */
    @Data
    public static class AuditMerchantRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotNull(message = "审核结果不能为空")
        private Boolean pass;

        /** 驳回原因（驳回时必填） */
        private String reason;
    }

    /** 状态变更请求（用户启禁用 / 管理员状态等） */
    @Data
    public static class StatusRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        private Integer status;
    }

    /** 反馈回复请求 */
    @Data
    public static class ReplyRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotBlank(message = "请填写回复内容")
        private String reply;
    }

    /** 管理员账号新增/编辑请求 */
    @Data
    public static class AdminSaveRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @NotBlank(message = "请输入账号")
        private String username;

        /** 新增必填；编辑留空表示不修改密码 */
        private String password;

        private String name;

        /** ADMIN / SUPER */
        private String role;

        private Integer status;
    }
}

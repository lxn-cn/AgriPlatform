package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.dto.PlatformDtos;
import com.agri.platform.entity.Merchant;
import com.agri.platform.mapper.MerchantMapper;
import com.agri.platform.mapper.SysAdminMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * 商家服务：入驻申请、资料维护、平台审核与封禁
 */
@Service
@RequiredArgsConstructor
public class MerchantService {

    private final MerchantMapper merchantMapper;
    private final SysAdminMapper sysAdminMapper;
    private final OperLogService operLogService;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * 入驻申请：账号唯一性校验，status=0 待审核
     */
    @Transactional(rollbackFor = Exception.class)
    public void apply(PlatformDtos.MerchantApplyRequest request) {
        String username = request.getUsername().trim();
        if (username.length() < 4) {
            throw new BizException("登录账号至少 4 位");
        }
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new BizException("密码长度不能少于 6 位");
        }
        Long exist = merchantMapper.selectCount(new LambdaQueryWrapper<Merchant>()
                .eq(Merchant::getUsername, username));
        if (exist != null && exist > 0) {
            throw new BizException("该登录账号已被占用，请更换");
        }
        Long adminExist = sysAdminMapper.selectCount(new LambdaQueryWrapper<com.agri.platform.entity.SysAdmin>()
                .eq(com.agri.platform.entity.SysAdmin::getUsername, username));
        if (adminExist != null && adminExist > 0) {
            throw new BizException("该登录账号已被占用，请更换");
        }
        Merchant merchant = new Merchant();
        merchant.setUsername(username);
        merchant.setPasswordHash(encoder.encode(request.getPassword()));
        merchant.setName(request.getName().trim());
        merchant.setLicenseInfo(request.getLicenseInfo().trim());
        merchant.setContact(request.getContact() == null ? "" : request.getContact().trim());
        merchant.setPhone(request.getPhone().trim());
        merchant.setIntro(request.getIntro() == null ? "" : request.getIntro().trim());
        merchant.setStatus(Constants.MERCHANT_PENDING);
        merchant.setRejectReason("");
        merchant.setCreateTime(LocalDateTime.now());
        merchant.setUpdateTime(LocalDateTime.now());
        merchantMapper.insert(merchant);
    }

    /** 商家资料（登录主体） */
    public Merchant profile() {
        Merchant merchant = merchantMapper.selectById(AuthContext.merchantId());
        if (merchant == null) {
            throw new BizException(401, "商家账号不存在");
        }
        return merchant;
    }

    /** 维护店铺信息（白名单字段） */
    @Transactional(rollbackFor = Exception.class)
    public Merchant updateProfile(PlatformDtos.MerchantProfileRequest request) {
        Merchant merchant = profile();
        if (StringUtils.hasText(request.getName())) {
            merchant.setName(request.getName().trim());
        }
        if (request.getContact() != null) {
            merchant.setContact(request.getContact().trim());
        }
        if (request.getPhone() != null) {
            merchant.setPhone(request.getPhone().trim());
        }
        if (request.getLicenseInfo() != null) {
            merchant.setLicenseInfo(request.getLicenseInfo().trim());
        }
        if (request.getIntro() != null) {
            merchant.setIntro(request.getIntro().trim());
        }
        merchant.setUpdateTime(LocalDateTime.now());
        merchantMapper.updateById(merchant);
        return merchant;
    }

    // ==================== 平台侧 ====================

    /** 商家分页 */
    public PageResult<Merchant> adminPage(Integer status, long pageNum, long pageSize) {
        LambdaQueryWrapper<Merchant> wrapper = new LambdaQueryWrapper<Merchant>()
                .orderByDesc(Merchant::getCreateTime);
        if (status != null) {
            wrapper.eq(Merchant::getStatus, status);
        }
        Page<Merchant> page = merchantMapper.selectPage(new Page<Merchant>(pageNum, pageSize), wrapper);
        return PageResult.from(page);
    }

    /** 入驻审核：通过 / 驳回（记录操作日志） */
    @Transactional(rollbackFor = Exception.class)
    public void audit(Long id, PlatformDtos.AuditMerchantRequest request) {
        Merchant merchant = merchantMapper.selectById(id);
        if (merchant == null) {
            throw new BizException("商家不存在");
        }
        if (merchant.getStatus() != Constants.MERCHANT_PENDING
                && merchant.getStatus() != Constants.MERCHANT_REJECTED) {
            throw new BizException("该商家当前状态无需审核");
        }
        if (Boolean.TRUE.equals(request.getPass())) {
            merchant.setStatus(Constants.MERCHANT_APPROVED);
            merchant.setRejectReason("");
        } else {
            merchant.setStatus(Constants.MERCHANT_REJECTED);
            String reason = StringUtils.hasText(request.getReason()) ? request.getReason().trim() : "资质材料不符合要求";
            merchant.setRejectReason(reason);
        }
        merchant.setUpdateTime(LocalDateTime.now());
        merchantMapper.updateById(merchant);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "MERCHANT_AUDIT", (Boolean.TRUE.equals(request.getPass()) ? "通过" : "驳回")
                        + "商家入驻申请#" + id + "（" + merchant.getName() + "）"
                        + (Boolean.TRUE.equals(request.getPass()) ? "" : "，原因：" + merchant.getRejectReason()));
    }

    /** 封禁商家 */
    @Transactional(rollbackFor = Exception.class)
    public void ban(Long id) {
        Merchant merchant = merchantMapper.selectById(id);
        if (merchant == null) {
            throw new BizException("商家不存在");
        }
        if (merchant.getStatus() != Constants.MERCHANT_APPROVED) {
            throw new BizException("仅已通过的商家可封禁");
        }
        merchant.setStatus(Constants.MERCHANT_BANNED);
        merchant.setUpdateTime(LocalDateTime.now());
        merchantMapper.updateById(merchant);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "MERCHANT_BAN", "封禁商家#" + id + "（" + merchant.getName() + "）");
    }

    /** 解禁商家 */
    @Transactional(rollbackFor = Exception.class)
    public void unban(Long id) {
        Merchant merchant = merchantMapper.selectById(id);
        if (merchant == null) {
            throw new BizException("商家不存在");
        }
        if (merchant.getStatus() != Constants.MERCHANT_BANNED) {
            throw new BizException("该商家未被封禁");
        }
        merchant.setStatus(Constants.MERCHANT_APPROVED);
        merchant.setUpdateTime(LocalDateTime.now());
        merchantMapper.updateById(merchant);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "MERCHANT_UNBAN", "解禁商家#" + id + "（" + merchant.getName() + "）");
    }
}

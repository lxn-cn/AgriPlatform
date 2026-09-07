package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.dto.PlatformDtos;
import com.agri.platform.entity.SysAdmin;
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
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理员账号维护（仅 SUPER 角色可调用，拦截器已做隔离）
 */
@Service
@RequiredArgsConstructor
public class AdminAccountService {

    private final SysAdminMapper sysAdminMapper;
    private final MerchantMapper merchantMapper;
    private final OperLogService operLogService;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /** 管理员分页（不返回密码） */
    public PageResult<Map<String, Object>> page(long pageNum, long pageSize) {
        Page<SysAdmin> page = sysAdminMapper.selectPage(new Page<SysAdmin>(pageNum, pageSize),
                new LambdaQueryWrapper<SysAdmin>().orderByAsc(SysAdmin::getId));
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (SysAdmin admin : page.getRecords()) {
            rows.add(toRow(admin));
        }
        return new PageResult<Map<String, Object>>(page.getTotal(), rows);
    }

    /** 新增管理员 */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> create(PlatformDtos.AdminSaveRequest request) {
        String username = request.getUsername().trim();
        if (!StringUtils.hasText(request.getPassword()) || request.getPassword().length() < 6) {
            throw new BizException("密码长度不能少于 6 位");
        }
        Long exist = sysAdminMapper.selectCount(new LambdaQueryWrapper<SysAdmin>()
                .eq(SysAdmin::getUsername, username));
        if (exist != null && exist > 0) {
            throw new BizException("该账号已存在");
        }
        Long merchantExist = merchantMapper.selectCount(new LambdaQueryWrapper<com.agri.platform.entity.Merchant>()
                .eq(com.agri.platform.entity.Merchant::getUsername, username));
        if (merchantExist != null && merchantExist > 0) {
            throw new BizException("该账号已被商家占用");
        }
        SysAdmin admin = new SysAdmin();
        admin.setUsername(username);
        admin.setPasswordHash(encoder.encode(request.getPassword()));
        admin.setName(StringUtils.hasText(request.getName()) ? request.getName().trim() : username);
        admin.setRole(Constants.ROLE_SUPER.equals(request.getRole()) ? Constants.ROLE_SUPER : Constants.ROLE_ADMIN);
        admin.setStatus(request.getStatus() == null || request.getStatus() == 1 ? 1 : 0);
        admin.setCreateTime(LocalDateTime.now());
        sysAdminMapper.insert(admin);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "ADMIN_CREATE", "新增管理员账号 " + username + "（" + admin.getRole() + "）");
        return toRow(admin);
    }

    /** 修改管理员（密码留空表示不修改） */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> update(Long id, PlatformDtos.AdminSaveRequest request) {
        SysAdmin admin = sysAdminMapper.selectById(id);
        if (admin == null) {
            throw new BizException("管理员不存在");
        }
        if (StringUtils.hasText(request.getName())) {
            admin.setName(request.getName().trim());
        }
        if (StringUtils.hasText(request.getRole())) {
            admin.setRole(Constants.ROLE_SUPER.equals(request.getRole()) ? Constants.ROLE_SUPER : Constants.ROLE_ADMIN);
        }
        if (request.getStatus() != null) {
            if ("admin".equals(admin.getUsername()) && request.getStatus() == 0) {
                throw new BizException("内置超级管理员不可停用");
            }
            admin.setStatus(request.getStatus());
        }
        if (StringUtils.hasText(request.getPassword())) {
            if (request.getPassword().length() < 6) {
                throw new BizException("密码长度不能少于 6 位");
            }
            admin.setPasswordHash(encoder.encode(request.getPassword()));
        }
        sysAdminMapper.updateById(admin);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "ADMIN_UPDATE", "修改管理员账号 " + admin.getUsername());
        return toRow(admin);
    }

    private Map<String, Object> toRow(SysAdmin admin) {
        Map<String, Object> row = new LinkedHashMap<String, Object>();
        row.put("id", admin.getId());
        row.put("username", admin.getUsername());
        row.put("name", admin.getName());
        row.put("role", admin.getRole());
        row.put("status", admin.getStatus());
        row.put("createTime", admin.getCreateTime());
        return row;
    }
}

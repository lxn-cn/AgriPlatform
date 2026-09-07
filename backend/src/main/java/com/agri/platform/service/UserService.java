package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.User;
import com.agri.platform.mapper.UserMapper;
import com.agri.platform.util.AuthContext;
import com.agri.platform.util.DesensitizeUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 用户服务：小程序个人信息、平台用户管理（列表手机号脱敏）
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;
    private final OperLogService operLogService;

    /** 当前登录用户信息 */
    public User me() {
        User user = userMapper.selectById(AuthContext.userId());
        if (user == null) {
            throw new BizException(401, "用户不存在或已被删除");
        }
        return user;
    }

    /** 修改昵称/头像/手机号 */
    @Transactional(rollbackFor = Exception.class)
    public User updateMe(String nickname, String avatar, String phone) {
        User user = me();
        if (StringUtils.hasText(nickname)) {
            user.setNickname(nickname.trim());
        }
        if (avatar != null) {
            user.setAvatar(avatar);
        }
        if (phone != null) {
            user.setPhone(phone.trim());
        }
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        return user;
    }

    /** 平台用户分页（手机号脱敏） */
    public PageResult<Map<String, Object>> adminPage(String keyword, long pageNum, long pageSize) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<User>()
                .orderByDesc(User::getCreateTime);
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            wrapper.and(w -> w.like(User::getNickname, kw).or().like(User::getPhone, kw));
        }
        Page<User> page = userMapper.selectPage(new Page<User>(pageNum, pageSize), wrapper);
        return new PageResult<Map<String, Object>>(page.getTotal(), toMaskRows(page.getRecords()));
    }

    /** 启用/禁用用户 */
    @Transactional(rollbackFor = Exception.class)
    public void setStatus(Long userId, Integer status) {
        if (status == null || (status != Constants.USER_NORMAL && status != Constants.USER_DISABLED)) {
            throw new BizException("状态参数不合法");
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        user.setStatus(status);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "USER_STATUS", (status == Constants.USER_NORMAL ? "启用" : "禁用") + "用户#" + userId
                        + "（" + user.getNickname() + "）");
    }

    private java.util.List<Map<String, Object>> toMaskRows(java.util.List<User> users) {
        java.util.List<Map<String, Object>> rows = new java.util.ArrayList<Map<String, Object>>();
        for (User u : users) {
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("id", u.getId());
            row.put("nickname", u.getNickname());
            row.put("openid", u.getOpenid());
            row.put("phone", DesensitizeUtil.maskPhone(u.getPhone()));
            row.put("status", u.getStatus());
            row.put("createTime", u.getCreateTime());
            rows.add(row);
        }
        return rows;
    }
}

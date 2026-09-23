package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.Appointment;
import com.agri.platform.entity.Orders;
import com.agri.platform.entity.User;
import com.agri.platform.mapper.AppointmentMapper;
import com.agri.platform.mapper.OrderMapper;
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
import java.util.UUID;

/**
 * 用户服务：小程序个人信息、平台用户管理（列表手机号脱敏）
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;
    private final OrderMapper orderMapper;
    private final AppointmentMapper appointmentMapper;
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

    /** 后台新增用户（昵称+手机号；openid 自动生成模拟值，状态默认正常） */
    @Transactional(rollbackFor = Exception.class)
    public void createUser(String nickname, String phone) {
        if (!StringUtils.hasText(nickname) || !StringUtils.hasText(phone)) {
            throw new BizException("昵称和手机号不能为空");
        }
        String tel = phone.trim();
        if (!tel.matches("^1\\d{10}$")) {
            throw new BizException("手机号格式不正确");
        }
        Long exist = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getPhone, tel));
        if (exist != null && exist > 0) {
            throw new BizException("该手机号已被注册");
        }
        User user = new User();
        user.setOpenid("mock_admin_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12));
        user.setNickname(nickname.trim());
        user.setPhone(tel);
        user.setStatus(Constants.USER_NORMAL);
        LocalDateTime now = LocalDateTime.now();
        user.setCreateTime(now);
        user.setUpdateTime(now);
        userMapper.insert(user);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "USER_CREATE", "新增用户#" + user.getId() + "（" + user.getNickname() + "）");
    }

    /** 删除用户（名下存在订单或预约记录时阻止，可改为禁用） */
    @Transactional(rollbackFor = Exception.class)
    public void deleteUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        Long orderCount = orderMapper.selectCount(new LambdaQueryWrapper<Orders>().eq(Orders::getUserId, userId));
        Long apptCount = appointmentMapper.selectCount(new LambdaQueryWrapper<Appointment>().eq(Appointment::getUserId, userId));
        if ((orderCount != null && orderCount > 0) || (apptCount != null && apptCount > 0)) {
            throw new BizException("该用户名下存在订单或预约记录，无法删除，请改为禁用");
        }
        userMapper.deleteById(userId);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "USER_DELETE", "删除用户#" + userId + "（" + user.getNickname() + "）");
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

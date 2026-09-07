package com.agri.platform.service;

import cn.hutool.core.bean.BeanUtil;
import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.entity.Appointment;
import com.agri.platform.entity.Farm;
import com.agri.platform.entity.PickingProject;
import com.agri.platform.mapper.AppointmentMapper;
import com.agri.platform.mapper.FarmMapper;
import com.agri.platform.mapper.PickingProjectMapper;
import com.agri.platform.util.AuthContext;
import com.agri.platform.util.OrderNoUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 采摘预约服务：用户预约全流程 + 商家预约通知与到园确认
 */
@Service
@RequiredArgsConstructor
public class AppointmentService {

    private final AppointmentMapper appointmentMapper;
    private final FarmMapper farmMapper;
    private final PickingProjectMapper pickingProjectMapper;
    private final OperLogService operLogService;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    /**
     * 提交预约：校验日期/场次/当季/库存，生成待支付预约单
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> create(TradeDtos.AppointmentCreateRequest request) {
        Long userId = AuthContext.userId();
        PickingProject project = pickingProjectMapper.selectById(request.getProjectId());
        if (project == null || project.getStatus() != Constants.STATUS_ON) {
            throw new BizException("采摘项目不存在或已下架");
        }
        Farm farm = farmMapper.selectById(project.getFarmId());
        if (farm == null || farm.getStatus() != Constants.STATUS_ON) {
            throw new BizException("农园不存在或已下架");
        }
        LocalDate date = request.getAppointDate();
        if (date == null || !date.isAfter(LocalDate.now())) {
            throw new BizException("预约日期必须是未来的日期");
        }
        // 当季校验
        if (project.getSeasonStart() != null && date.isBefore(project.getSeasonStart())) {
            throw new BizException("该项目 " + project.getSeasonStart().format(DATE_FMT) + " 开采，请选择当季日期");
        }
        if (project.getSeasonEnd() != null && date.isAfter(project.getSeasonEnd())) {
            throw new BizException("该项目采摘季至 " + project.getSeasonEnd().format(DATE_FMT) + "，请选择当季日期");
        }
        // 场次校验
        String session = request.getSession().trim();
        List<String> sessions = Arrays.asList(project.getSession().split(","));
        if (!sessions.contains(session)) {
            throw new BizException("该项目仅支持场次：" + project.getSession());
        }
        int people = request.getPeopleCount();
        if (people < 1) {
            throw new BizException("预约人数至少为 1 人");
        }
        // 场次库存校验（待支付 + 待使用口径）
        int booked = appointmentMapper.sumBooked(project.getId(), date, session);
        if (booked + people > project.getStock()) {
            throw new BizException("该场次仅剩 " + Math.max(0, project.getStock() - booked)
                    + " 个名额，请调整人数或更换场次");
        }
        // 金额：按人头门票直接计价；按采摘重量以人头价作为预付金额（到场按实结算）
        BigDecimal amount = project.getPrice().multiply(BigDecimal.valueOf(people));

        Appointment appointment = new Appointment();
        appointment.setAppointmentNo(OrderNoUtil.appointmentNo());
        appointment.setUserId(userId);
        appointment.setFarmId(farm.getId());
        appointment.setProjectId(project.getId());
        appointment.setAppointDate(date);
        appointment.setSession(session);
        appointment.setPeopleCount(people);
        appointment.setAmount(amount);
        appointment.setContactName(request.getContactName().trim());
        appointment.setContactPhone(request.getContactPhone().trim());
        appointment.setStatus(Constants.APPOINTMENT_UNPAID);
        appointment.setMerchantRead(0);
        appointment.setCreateTime(LocalDateTime.now());
        appointmentMapper.insert(appointment);
        return toDetailRow(appointment);
    }

    /** 我的预约分页 */
    public PageResult<Map<String, Object>> myPage(Integer status, long pageNum, long pageSize) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getUserId, AuthContext.userId())
                .orderByDesc(Appointment::getCreateTime);
        if (status != null) {
            wrapper.eq(Appointment::getStatus, status);
        }
        Page<Appointment> page = appointmentMapper.selectPage(new Page<Appointment>(pageNum, pageSize), wrapper);
        return new PageResult<Map<String, Object>>(page.getTotal(), toDetailRows(page.getRecords()));
    }

    /** 预约详情（校验归属） */
    public Map<String, Object> detail(Long id) {
        Appointment appointment = appointmentMapper.selectById(id);
        if (appointment == null || !appointment.getUserId().equals(AuthContext.userId())) {
            throw new BizException("预约单不存在");
        }
        return toDetailRow(appointment);
    }

    /** 模拟支付：待支付 → 待使用，并触发商家未读通知 */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> pay(Long id) {
        Appointment appointment = ownedOrThrow(id);
        if (appointment.getStatus() != Constants.APPOINTMENT_UNPAID) {
            throw new BizException("当前状态不可支付");
        }
        // 支付前再次校验场次库存
        PickingProject project = pickingProjectMapper.selectById(appointment.getProjectId());
        if (project == null) {
            throw new BizException("采摘项目已不存在");
        }
        int booked = appointmentMapper.sumBooked(project.getId(), appointment.getAppointDate(), appointment.getSession());
        if (booked + appointment.getPeopleCount() > project.getStock()) {
            throw new BizException("该场次名额已约满，请取消后重新预约其他场次");
        }
        appointment.setStatus(Constants.APPOINTMENT_UNUSED);
        appointment.setPayTime(LocalDateTime.now());
        appointment.setMerchantRead(0);
        appointmentMapper.updateById(appointment);
        return toDetailRow(appointment);
    }

    /** 取消预约：待支付随时可取消；待使用需在预约日期前一天 24:00 前 */
    @Transactional(rollbackFor = Exception.class)
    public void cancel(Long id) {
        Appointment appointment = ownedOrThrow(id);
        int status = appointment.getStatus();
        if (status == Constants.APPOINTMENT_UNPAID) {
            // 待支付：直接取消
        } else if (status == Constants.APPOINTMENT_UNUSED) {
            LocalDateTime deadline = appointment.getAppointDate().atStartOfDay().minusDays(1);
            if (LocalDateTime.now().isAfter(deadline)) {
                throw new BizException("已超过取消时限（需在预约日期前一天 24:00 前取消）");
            }
        } else {
            throw new BizException("当前状态不可取消");
        }
        appointment.setStatus(Constants.APPOINTMENT_CANCELED);
        appointment.setCancelTime(LocalDateTime.now());
        appointmentMapper.updateById(appointment);
    }

    // ==================== 商家侧 ====================

    /** 商家预约单分页（含预约人、电话、人数、场次，供到园核对） */
    public PageResult<Map<String, Object>> merchantPage(Integer status, LocalDate date,
                                                        long pageNum, long pageSize) {
        Long merchantId = AuthContext.merchantId();
        IPage<Appointment> page = appointmentMapper.selectMerchantPage(
                new Page<Appointment>(pageNum, pageSize), merchantId, status, date);
        return new PageResult<Map<String, Object>>(page.getTotal(), toDetailRows(page.getRecords()));
    }

    /** 商家未读预约通知数 */
    public int unreadCount() {
        return appointmentMapper.countUnread(AuthContext.merchantId());
    }

    /** 商家标记预约通知已读 */
    @Transactional(rollbackFor = Exception.class)
    public void markRead(Long id) {
        Appointment appointment = merchantOwnedOrThrow(id);
        appointment.setMerchantRead(1);
        appointmentMapper.updateById(appointment);
    }

    /**
     * 到园确认：核对用户报出的手机号后，预约单 → 已使用（记录操作日志）
     */
    @Transactional(rollbackFor = Exception.class)
    public void confirmArrival(Long id, String phoneTail) {
        Appointment appointment = merchantOwnedOrThrow(id);
        if (appointment.getStatus() != Constants.APPOINTMENT_UNUSED) {
            throw new BizException("仅“待使用”的预约可执行到园确认");
        }
        if (StringUtils.hasText(phoneTail)) {
            String tail = phoneTail.trim();
            String phone = appointment.getContactPhone() == null ? "" : appointment.getContactPhone();
            if (!phone.endsWith(tail)) {
                throw new BizException("手机尾号核对不一致，请与用户再次确认（预留尾号 "
                        + phone.substring(Math.max(0, phone.length() - 4)) + "）");
            }
        }
        appointment.setStatus(Constants.APPOINTMENT_USED);
        appointment.setConfirmTime(LocalDateTime.now());
        appointment.setMerchantRead(1);
        appointmentMapper.updateById(appointment);
        operLogService.record(Constants.OPERATOR_MERCHANT, AuthContext.merchantId(), AuthContext.name(),
                "APPOINTMENT_CONFIRM", "到园确认预约单 " + appointment.getAppointmentNo()
                        + "（预约人 " + appointment.getContactName() + "，" + appointment.getPeopleCount() + " 人）");
    }

    // ==================== 平台侧 ====================

    /** 全平台预约总览分页（keyword 匹配预约编号/预约人） */
    public PageResult<Map<String, Object>> adminPage(Integer status, String keyword,
                                                     long pageNum, long pageSize) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<Appointment>()
                .orderByDesc(Appointment::getId);
        if (status != null) {
            wrapper.eq(Appointment::getStatus, status);
        }
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            wrapper.and(w -> w.like(Appointment::getAppointmentNo, kw)
                    .or().like(Appointment::getContactName, kw));
        }
        Page<Appointment> page = appointmentMapper.selectPage(new Page<Appointment>(pageNum, pageSize), wrapper);
        return new PageResult<Map<String, Object>>(page.getTotal(), toDetailRows(page.getRecords()));
    }

    // ==================== 私有辅助 ====================

    private Appointment ownedOrThrow(Long id) {
        Appointment appointment = appointmentMapper.selectById(id);
        if (appointment == null || !appointment.getUserId().equals(AuthContext.userId())) {
            throw new BizException("预约单不存在");
        }
        return appointment;
    }

    private Appointment merchantOwnedOrThrow(Long id) {
        Appointment appointment = appointmentMapper.selectById(id);
        if (appointment == null) {
            throw new BizException("预约单不存在");
        }
        Farm farm = farmMapper.selectById(appointment.getFarmId());
        if (farm == null || !farm.getMerchantId().equals(AuthContext.merchantId())) {
            throw new BizException("无权操作该预约单");
        }
        return appointment;
    }

    /** 预约单 → 展示行（附农园/项目名称） */
    private List<Map<String, Object>> toDetailRows(List<Appointment> appointments) {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Appointment a : appointments) {
            rows.add(toDetailRow(a));
        }
        return rows;
    }

    private Map<String, Object> toDetailRow(Appointment a) {
        Map<String, Object> row = new LinkedHashMap<String, Object>(BeanUtil.beanToMap(a));
        Farm farm = farmMapper.selectById(a.getFarmId());
        row.put("farmName", farm == null ? "" : farm.getName());
        PickingProject project = pickingProjectMapper.selectById(a.getProjectId());
        row.put("projectName", project == null ? "" : project.getName());
        return row;
    }
}

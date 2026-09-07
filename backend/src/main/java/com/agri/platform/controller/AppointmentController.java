package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.service.AppointmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.Map;

/**
 * 采摘预约接口（用户侧）
 */
@RestController
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    /** 提交预约（待支付） */
    @PostMapping("/api/appointments")
    public Result<Map<String, Object>> create(
            @Valid @RequestBody TradeDtos.AppointmentCreateRequest request) {
        return Result.ok(appointmentService.create(request));
    }

    /** 我的预约列表 */
    @GetMapping("/api/appointments/my")
    public Result<PageResult<Map<String, Object>>> my(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") long pageNum,
            @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(appointmentService.myPage(status, pageNum, pageSize));
    }

    /** 预约详情 */
    @GetMapping("/api/appointments/{id}")
    public Result<Map<String, Object>> detail(@PathVariable Long id) {
        return Result.ok(appointmentService.detail(id));
    }

    /** 模拟支付（待使用，触发商家通知） */
    @PostMapping("/api/appointments/{id}/pay")
    public Result<Map<String, Object>> pay(@PathVariable Long id) {
        return Result.ok(appointmentService.pay(id));
    }

    /** 取消预约（待使用需在预约日期前一天 24:00 前） */
    @PostMapping("/api/appointments/{id}/cancel")
    public Result<Void> cancel(@PathVariable Long id) {
        appointmentService.cancel(id);
        return Result.ok("预约已取消", null);
    }
}

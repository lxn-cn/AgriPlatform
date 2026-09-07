package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.service.OrderService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.io.Serializable;
import java.util.Map;

/**
 * 订单接口（用户侧）
 */
@RestController
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    /** 提交订单（快照地址与价格，生成订单号） */
    @PostMapping("/api/orders")
    public Result<Map<String, Object>> create(@Valid @RequestBody TradeDtos.OrderCreateRequest request) {
        return Result.ok(orderService.create(request));
    }

    /** 我的订单列表 */
    @GetMapping("/api/orders/my")
    public Result<PageResult<Map<String, Object>>> my(@RequestParam(required = false) Integer status,
                                                      @RequestParam(defaultValue = "1") long pageNum,
                                                      @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(orderService.myPage(status, pageNum, pageSize));
    }

    /** 订单详情（含明细） */
    @GetMapping("/api/orders/{id}")
    public Result<Map<String, Object>> detail(@PathVariable Long id) {
        return Result.ok(orderService.detail(id));
    }

    /** 模拟支付（扣库存、加销量） */
    @PostMapping("/api/orders/{id}/pay")
    public Result<Void> pay(@PathVariable Long id) {
        orderService.pay(id);
        return Result.ok("支付成功", null);
    }

    /** 取消订单（仅待付款） */
    @PostMapping("/api/orders/{id}/cancel")
    public Result<Void> cancel(@PathVariable Long id) {
        orderService.cancel(id);
        return Result.ok("订单已取消", null);
    }

    /** 确认收货（待收货 → 已完成） */
    @PostMapping("/api/orders/{id}/confirm")
    public Result<Void> confirm(@PathVariable Long id) {
        orderService.confirm(id);
        return Result.ok("确认收货成功", null);
    }

    /** 申请退款 */
    @PostMapping("/api/orders/{id}/refund")
    public Result<Void> refund(@PathVariable Long id, @Valid @RequestBody RefundRequest request) {
        orderService.refund(id, request.getReason());
        return Result.ok("退款申请已提交，等待商家处理", null);
    }

    /** 退款请求 */
    @Data
    public static class RefundRequest implements Serializable {
        private static final long serialVersionUID = 1L;

        @javax.validation.constraints.NotBlank(message = "请填写退款原因")
        private String reason;
    }
}

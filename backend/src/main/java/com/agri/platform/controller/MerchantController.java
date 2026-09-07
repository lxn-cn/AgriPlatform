package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.dto.PlatformDtos;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.entity.Farm;
import com.agri.platform.entity.Merchant;
import com.agri.platform.entity.PickingProject;
import com.agri.platform.entity.Product;
import com.agri.platform.service.AppointmentService;
import com.agri.platform.service.MerchantFarmService;
import com.agri.platform.service.MerchantService;
import com.agri.platform.service.OrderService;
import com.agri.platform.service.ProductService;
import com.agri.platform.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.time.LocalDate;
import java.util.Map;

/**
 * 商家端接口：入驻申请（免登录）、店铺资料、农园与采摘项目、预约通知与到园确认、
 * 商品与订单管理、经营统计。角色隔离由 JwtInterceptor 完成。
 */
@RestController
@RequestMapping("/api/merchant")
@RequiredArgsConstructor
public class MerchantController {

    private final MerchantService merchantService;
    private final MerchantFarmService merchantFarmService;
    private final ProductService productService;
    private final AppointmentService appointmentService;
    private final OrderService orderService;
    private final StatsService statsService;

    // ==================== 入驻与资料 ====================

    /** 入驻申请（WebConfig 已放行，无需登录） */
    @PostMapping("/apply")
    public Result<Void> apply(@Valid @RequestBody PlatformDtos.MerchantApplyRequest request) {
        merchantService.apply(request);
        return Result.ok("入驻申请已提交，请等待平台审核", null);
    }

    /** 店铺信息 */
    @GetMapping("/profile")
    public Result<Merchant> profile() {
        return Result.ok(merchantService.profile());
    }

    /** 维护店铺信息 */
    @PutMapping("/profile")
    public Result<Merchant> updateProfile(@RequestBody PlatformDtos.MerchantProfileRequest request) {
        return Result.ok(merchantService.updateProfile(request));
    }

    // ==================== 经营统计 ====================

    /** 经营统计：销量、销售额、预约人次、近 7 日趋势 */
    @GetMapping("/stats")
    public Result<Map<String, Object>> stats() {
        return Result.ok(statsService.merchantStats());
    }

    // ==================== 商品管理 ====================

    /** 本商家商品列表 */
    @GetMapping("/products")
    public Result<PageResult<Map<String, Object>>> products(@RequestParam(required = false) Integer status,
                                                            @RequestParam(required = false) String keyword,
                                                            @RequestParam(defaultValue = "1") long pageNum,
                                                            @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(productService.merchantPage(status, keyword, pageNum, pageSize));
    }

    /** 商品详情（编辑回显，含分类路径） */
    @GetMapping("/products/{id}")
    public Result<Map<String, Object>> productDetail(@PathVariable Long id) {
        return Result.ok(productService.merchantDetail(id));
    }

    /** 新建商品（默认待审核） */
    @PostMapping("/products")
    public Result<Product> createProduct(@RequestBody Product product) {
        return Result.ok(productService.create(product));
    }

    /** 修改商品 */
    @PutMapping("/products/{id}")
    public Result<Product> updateProduct(@PathVariable Long id, @RequestBody Product product) {
        return Result.ok(productService.update(id, product));
    }

    /** 删除商品（逻辑下架） */
    @DeleteMapping("/products/{id}")
    public Result<Void> deleteProduct(@PathVariable Long id) {
        productService.delete(id);
        return Result.ok("已下架", null);
    }

    // ==================== 农园与采摘项目 ====================

    /** 本商家农园列表 */
    @GetMapping("/farms")
    public Result<PageResult<Farm>> farms(@RequestParam(required = false) String keyword,
                                          @RequestParam(defaultValue = "1") long pageNum,
                                          @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(merchantFarmService.farmPage(keyword, pageNum, pageSize));
    }

    /** 新建农园 */
    @PostMapping("/farms")
    public Result<Farm> createFarm(@RequestBody Farm farm) {
        return Result.ok(merchantFarmService.createFarm(farm));
    }

    /** 农园详情 */
    @GetMapping("/farms/{id}")
    public Result<Farm> farmDetail(@PathVariable Long id) {
        return Result.ok(merchantFarmService.farmDetail(id));
    }

    /** 修改农园（含交通指引） */
    @PutMapping("/farms/{id}")
    public Result<Farm> updateFarm(@PathVariable Long id, @RequestBody Farm farm) {
        return Result.ok(merchantFarmService.updateFarm(id, farm));
    }

    /** 采摘项目列表（按 farmId） */
    @GetMapping("/picking-projects")
    public Result<PageResult<PickingProject>> projects(@RequestParam Long farmId) {
        return Result.ok(merchantFarmService.projectPage(farmId));
    }

    /** 新建采摘项目 */
    @PostMapping("/picking-projects")
    public Result<PickingProject> createProject(@RequestBody PickingProject project) {
        return Result.ok(merchantFarmService.createProject(project));
    }

    /** 修改采摘项目（含场次库存） */
    @PutMapping("/picking-projects/{id}")
    public Result<PickingProject> updateProject(@PathVariable Long id, @RequestBody PickingProject project) {
        return Result.ok(merchantFarmService.updateProject(id, project));
    }

    /** 下架采摘项目 */
    @DeleteMapping("/picking-projects/{id}")
    public Result<Void> deleteProject(@PathVariable Long id) {
        merchantFarmService.deleteProject(id);
        return Result.ok("已下架", null);
    }

    // ==================== 预约管理 ====================

    /** 预约单列表（含预约人、电话、场次、人数） */
    @GetMapping("/appointments")
    public Result<PageResult<Map<String, Object>>> appointments(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "1") long pageNum,
            @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(appointmentService.merchantPage(status, date, pageNum, pageSize));
    }

    /** 未读预约通知数 */
    @GetMapping("/appointments/unread-count")
    public Result<Integer> unreadCount() {
        return Result.ok(appointmentService.unreadCount());
    }

    /** 标记预约通知已读 */
    @PostMapping("/appointments/{id}/read")
    public Result<Void> markRead(@PathVariable Long id) {
        appointmentService.markRead(id);
        return Result.ok();
    }

    /** 到园确认（可选核对手机尾号） */
    @PostMapping("/appointments/{id}/confirm")
    public Result<Void> confirmArrival(@PathVariable Long id,
                                       @RequestBody(required = false) TradeDtos.ConfirmArrivalRequest request) {
        appointmentService.confirmArrival(id, request == null ? null : request.getPhoneTail());
        return Result.ok("到园确认成功", null);
    }

    // ==================== 订单管理 ====================

    /** 本商家订单列表（含明细） */
    @GetMapping("/orders")
    public Result<PageResult<Map<String, Object>>> orders(@RequestParam(required = false) Integer status,
                                                          @RequestParam(defaultValue = "1") long pageNum,
                                                          @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(orderService.merchantPage(status, pageNum, pageSize));
    }

    /** 发货 */
    @PostMapping("/orders/{id}/ship")
    public Result<Void> ship(@PathVariable Long id) {
        orderService.ship(id);
        return Result.ok("发货成功", null);
    }

    /** 同意退款（回滚库存） */
    @PostMapping("/orders/{id}/refund-agree")
    public Result<Void> refundAgree(@PathVariable Long id) {
        orderService.refundAgree(id);
        return Result.ok("已同意退款，库存已回滚", null);
    }
}

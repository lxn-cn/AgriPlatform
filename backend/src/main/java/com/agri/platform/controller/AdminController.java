package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.dto.PlatformDtos;
import com.agri.platform.entity.Banner;
import com.agri.platform.entity.Category;
import com.agri.platform.entity.Merchant;
import com.agri.platform.entity.Notice;
import com.agri.platform.entity.OperLog;
import com.agri.platform.mapper.OperLogMapper;
import com.agri.platform.service.AdminAccountService;
import com.agri.platform.service.BannerService;
import com.agri.platform.service.CategoryService;
import com.agri.platform.service.FeedbackService;
import com.agri.platform.service.MerchantService;
import com.agri.platform.service.NoticeService;
import com.agri.platform.service.OrderService;
import com.agri.platform.service.AppointmentService;
import com.agri.platform.service.ProductService;
import com.agri.platform.service.StatsService;
import com.agri.platform.service.UserService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
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
import java.util.List;
import java.util.Map;

/**
 * 平台管理端接口（ADMIN/SUPER；管理员账号管理仅 SUPER，由拦截器隔离）
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final MerchantService merchantService;
    private final UserService userService;
    private final ProductService productService;
    private final BannerService bannerService;
    private final NoticeService noticeService;
    private final CategoryService categoryService;
    private final OrderService orderService;
    private final AppointmentService appointmentService;
    private final FeedbackService feedbackService;
    private final StatsService statsService;
    private final AdminAccountService adminAccountService;
    private final OperLogMapper operLogMapper;

    // ==================== 数据看板 ====================

    /** 总览统计（交易额/订单/预约/用户 + 近 7 日趋势 + 分类占比） */
    @GetMapping("/stats/overview")
    public Result<Map<String, Object>> overview() {
        return Result.ok(statsService.adminOverview());
    }

    // ==================== 商家审核 ====================

    /** 商家列表 */
    @GetMapping("/merchants")
    public Result<PageResult<Merchant>> merchants(@RequestParam(required = false) Integer status,
                                                  @RequestParam(defaultValue = "1") long pageNum,
                                                  @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(merchantService.adminPage(status, pageNum, pageSize));
    }

    /** 入驻审核（通过/驳回） */
    @PostMapping("/merchants/{id}/audit")
    public Result<Void> audit(@PathVariable Long id, @Valid @RequestBody PlatformDtos.AuditMerchantRequest request) {
        merchantService.audit(id, request);
        return Result.ok("审核完成", null);
    }

    /** 封禁商家 */
    @PostMapping("/merchants/{id}/ban")
    public Result<Void> ban(@PathVariable Long id) {
        merchantService.ban(id);
        return Result.ok("已封禁", null);
    }

    /** 解禁商家 */
    @PostMapping("/merchants/{id}/unban")
    public Result<Void> unban(@PathVariable Long id) {
        merchantService.unban(id);
        return Result.ok("已解禁", null);
    }

    // ==================== 用户管理 ====================

    /** 用户列表（手机号脱敏） */
    @GetMapping("/users")
    public Result<PageResult<Map<String, Object>>> users(@RequestParam(required = false) String keyword,
                                                         @RequestParam(defaultValue = "1") long pageNum,
                                                         @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(userService.adminPage(keyword, pageNum, pageSize));
    }

    /** 启用/禁用用户 */
    @PostMapping("/users/{id}/status")
    public Result<Void> setUserStatus(@PathVariable Long id, @RequestBody PlatformDtos.StatusRequest request) {
        userService.setStatus(id, request.getStatus());
        return Result.ok();
    }

    // ==================== 商品巡检 ====================

    /** 全平台商品列表 */
    @GetMapping("/products")
    public Result<PageResult<Map<String, Object>>> products(@RequestParam(required = false) Integer status,
                                                            @RequestParam(required = false) String keyword,
                                                            @RequestParam(defaultValue = "1") long pageNum,
                                                            @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(productService.adminPage(status, keyword, pageNum, pageSize));
    }

    /** 违规强制下架 */
    @PostMapping("/products/{id}/force-off")
    public Result<Void> forceOff(@PathVariable Long id) {
        productService.forceOff(id);
        return Result.ok("已强制下架", null);
    }

    // ==================== 内容管理 ====================

    /** 轮播图列表（全部） */
    @GetMapping("/banners")
    public Result<List<Banner>> banners() {
        return Result.ok(bannerService.adminList());
    }

    @PostMapping("/banners")
    public Result<Banner> createBanner(@Valid @RequestBody Banner banner) {
        return Result.ok(bannerService.create(banner));
    }

    @PutMapping("/banners/{id}")
    public Result<Banner> updateBanner(@PathVariable Long id, @RequestBody Banner banner) {
        return Result.ok(bannerService.update(id, banner));
    }

    @DeleteMapping("/banners/{id}")
    public Result<Void> deleteBanner(@PathVariable Long id) {
        bannerService.delete(id);
        return Result.ok("已删除", null);
    }

    /** 公告分页 */
    @GetMapping("/notices")
    public Result<PageResult<Notice>> notices(@RequestParam(required = false) Integer status,
                                              @RequestParam(defaultValue = "1") long pageNum,
                                              @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(noticeService.adminPage(status, pageNum, pageSize));
    }

    @PostMapping("/notices")
    public Result<Notice> createNotice(@Valid @RequestBody Notice notice) {
        return Result.ok(noticeService.create(notice));
    }

    @PutMapping("/notices/{id}")
    public Result<Notice> updateNotice(@PathVariable Long id, @RequestBody Notice notice) {
        return Result.ok(noticeService.update(id, notice));
    }

    @DeleteMapping("/notices/{id}")
    public Result<Void> deleteNotice(@PathVariable Long id) {
        noticeService.delete(id);
        return Result.ok("已删除", null);
    }

    /** 分类树（含下线分类） */
    @GetMapping("/categories")
    public Result<List<Map<String, Object>>> categories() {
        return Result.ok(categoryService.adminTree());
    }

    @PostMapping("/categories")
    public Result<Category> createCategory(@Valid @RequestBody Category category) {
        return Result.ok(categoryService.create(category));
    }

    @PutMapping("/categories/{id}")
    public Result<Category> updateCategory(@PathVariable Long id, @RequestBody Category category) {
        return Result.ok(categoryService.update(id, category));
    }

    @DeleteMapping("/categories/{id}")
    public Result<Void> deleteCategory(@PathVariable Long id) {
        categoryService.delete(id);
        return Result.ok("已删除", null);
    }

    // ==================== 订单与预约总览 ====================

    /** 全平台订单总览 */
    @GetMapping("/orders")
    public Result<PageResult<Map<String, Object>>> orders(@RequestParam(required = false) Integer status,
                                                          @RequestParam(required = false) String orderNo,
                                                          @RequestParam(defaultValue = "1") long pageNum,
                                                          @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(orderService.adminPage(status, orderNo, pageNum, pageSize));
    }

    /** 全平台预约总览 */
    @GetMapping("/appointments")
    public Result<PageResult<Map<String, Object>>> appointments(
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") long pageNum,
            @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(appointmentService.adminPage(status, keyword, pageNum, pageSize));
    }

    // ==================== 反馈与日志 ====================

    /** 反馈列表 */
    @GetMapping("/feedbacks")
    public Result<PageResult<com.agri.platform.entity.Feedback>> feedbacks(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") long pageNum,
            @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(feedbackService.adminPage(status, pageNum, pageSize));
    }

    /** 回复反馈 */
    @PostMapping("/feedbacks/{id}/reply")
    public Result<Void> replyFeedback(@PathVariable Long id, @Valid @RequestBody PlatformDtos.ReplyRequest request) {
        feedbackService.reply(id, request);
        return Result.ok("回复成功", null);
    }

    /** 操作日志分页 */
    @GetMapping("/logs")
    public Result<PageResult<OperLog>> logs(@RequestParam(defaultValue = "1") long pageNum,
                                            @RequestParam(defaultValue = "10") long pageSize) {
        Page<OperLog> page = operLogMapper.selectPage(new Page<OperLog>(pageNum, pageSize),
                new LambdaQueryWrapper<OperLog>().orderByDesc(OperLog::getId));
        return Result.ok(PageResult.from(page));
    }

    // ==================== 管理员账号（仅 SUPER） ====================

    /** 管理员列表 */
    @GetMapping("/admins")
    public Result<PageResult<Map<String, Object>>> admins(@RequestParam(defaultValue = "1") long pageNum,
                                                          @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(adminAccountService.page(pageNum, pageSize));
    }

    /** 新增管理员 */
    @PostMapping("/admins")
    public Result<Map<String, Object>> createAdmin(@Valid @RequestBody PlatformDtos.AdminSaveRequest request) {
        return Result.ok(adminAccountService.create(request));
    }

    /** 修改管理员 */
    @PutMapping("/admins/{id}")
    public Result<Map<String, Object>> updateAdmin(@PathVariable Long id,
                                                   @Valid @RequestBody PlatformDtos.AdminSaveRequest request) {
        return Result.ok(adminAccountService.update(id, request));
    }
}

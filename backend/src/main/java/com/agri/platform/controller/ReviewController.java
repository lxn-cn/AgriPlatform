package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.service.ReviewService;
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
 * 评价接口：商品/农园通用发布 + 商品评价分页
 */
@RestController
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    /** 发布评价（商品需已完成订单；农园需已使用预约） */
    @PostMapping("/api/reviews")
    public Result<Void> create(@Valid @RequestBody TradeDtos.ReviewCreateRequest request) {
        reviewService.create(request);
        return Result.ok("评价发布成功", null);
    }

    /** 商品评价分页 */
    @GetMapping("/api/products/{id}/reviews")
    public Result<PageResult<Map<String, Object>>> productReviews(@PathVariable Long id,
                                                                  @RequestParam(defaultValue = "1") long pageNum,
                                                                  @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(reviewService.productReviews(id, pageNum, pageSize));
    }
}

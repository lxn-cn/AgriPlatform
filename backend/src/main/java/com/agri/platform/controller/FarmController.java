package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.service.FarmService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 农园浏览接口（游客可用）
 */
@RestController
@RequiredArgsConstructor
public class FarmController {

    private final FarmService farmService;

    /** 农园列表：区县/类型/关键词 + 排序（rating/price_asc/price_desc） */
    @GetMapping("/api/farms")
    public Result<PageResult<?>> page(@RequestParam(required = false) String district,
                                      @RequestParam(required = false) String type,
                                      @RequestParam(required = false) String keyword,
                                      @RequestParam(required = false) String sort,
                                      @RequestParam(defaultValue = "1") long pageNum,
                                      @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(farmService.page(district, type, keyword, sort, pageNum, pageSize));
    }

    /** 农园详情（含地址复制、交通指引、联系电话与当季项目） */
    @GetMapping("/api/farms/{id}")
    public Result<Map<String, Object>> detail(@PathVariable Long id) {
        return Result.ok(farmService.detail(id));
    }

    /** 农园评价分页 */
    @GetMapping("/api/farms/{id}/reviews")
    public Result<PageResult<Map<String, Object>>> reviews(@PathVariable Long id,
                                                           @RequestParam(defaultValue = "1") long pageNum,
                                                           @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(farmService.reviews(id, pageNum, pageSize));
    }
}

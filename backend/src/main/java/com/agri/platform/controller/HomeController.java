package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.service.HomeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 首页与通用接口（游客可用）
 */
@RestController
@RequiredArgsConstructor
public class HomeController {

    private final HomeService homeService;

    /** 轮播图列表 */
    @GetMapping("/api/home/banners")
    public Result<?> banners() {
        return Result.ok(homeService.banners());
    }

    /** 公告列表（最新 5 条） */
    @GetMapping("/api/home/notices")
    public Result<?> notices() {
        return Result.ok(homeService.notices());
    }

    /** 推荐当季商品（销量前 10） */
    @GetMapping("/api/home/recommended")
    public Result<?> recommended() {
        return Result.ok(homeService.recommended());
    }

    /** 农园入口卡片（前 6） */
    @GetMapping("/api/home/farms-brief")
    public Result<?> farmsBrief() {
        return Result.ok(homeService.farmsBrief());
    }

    /** 关键词聚合搜索 {products, farms} */
    @GetMapping("/api/search")
    public Result<Map<String, Object>> search(@RequestParam(required = false) String keyword) {
        return Result.ok(homeService.search(keyword));
    }
}

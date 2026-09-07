package com.agri.platform.controller;

import com.agri.platform.common.PageResult;
import com.agri.platform.common.Result;
import com.agri.platform.service.FavoriteService;
import com.agri.platform.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 商城商品接口（游客可浏览）+ 商品收藏
 */
@RestController
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final FavoriteService favoriteService;

    /** 商品列表：分类/关键词 + 排序 */
    @GetMapping("/api/products")
    public Result<PageResult<?>> page(@RequestParam(required = false) Long categoryId,
                                      @RequestParam(required = false) String keyword,
                                      @RequestParam(required = false) String sort,
                                      @RequestParam(defaultValue = "1") long pageNum,
                                      @RequestParam(defaultValue = "10") long pageSize) {
        return Result.ok(productService.page(categoryId, keyword, sort, pageNum, pageSize));
    }

    /** 商品详情（含规格、产地、商家名称、收藏状态） */
    @GetMapping("/api/products/{id}")
    public Result<Map<String, Object>> detail(@PathVariable Long id) {
        return Result.ok(productService.detail(id));
    }

    /** 收藏商品 */
    @PostMapping("/api/products/{id}/favorite")
    public Result<Void> addFavorite(@PathVariable Long id) {
        favoriteService.add(id);
        return Result.ok("已收藏", null);
    }

    /** 取消收藏 */
    @DeleteMapping("/api/products/{id}/favorite")
    public Result<Void> removeFavorite(@PathVariable Long id) {
        favoriteService.remove(id);
        return Result.ok("已取消收藏", null);
    }

    /** 我的收藏（含商品快照） */
    @GetMapping("/api/favorites/my")
    public Result<PageResult<Map<String, Object>>> myFavorites() {
        return Result.ok(favoriteService.myPage());
    }
}

package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 商品分类接口（游客可用：两级分类树）
 */
@RestController
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    /** 分类树（仅启用的分类） */
    @GetMapping("/api/categories")
    public Result<List<Map<String, Object>>> tree() {
        return Result.ok(categoryService.tree());
    }
}

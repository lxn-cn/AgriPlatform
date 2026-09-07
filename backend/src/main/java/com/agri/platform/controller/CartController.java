package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.Map;

/**
 * 购物车接口
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/cart")
public class CartController {

    private final CartService cartService;

    /** 购物车列表（含商品实时信息） */
    @GetMapping
    public Result<Map<String, Object>> list() {
        return Result.ok(cartService.list());
    }

    /** 加入购物车 */
    @PostMapping
    public Result<Void> add(@Valid @RequestBody AddRequest request) {
        cartService.add(request.getProductId(), request.getSpec(), request.getQuantity());
        return Result.ok("已加入购物车", null);
    }

    /** 修改数量/勾选 */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody TradeDtos.CartUpdateRequest request) {
        cartService.update(id, request.getQuantity(), request.getChecked());
        return Result.ok();
    }

    /** 删除购物车行 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cartService.delete(id);
        return Result.ok("已删除", null);
    }

    /** 加购请求 */
    @lombok.Data
    public static class AddRequest implements java.io.Serializable {
        private static final long serialVersionUID = 1L;

        @javax.validation.constraints.NotNull(message = "商品不能为空")
        private Long productId;

        private String spec;

        private Integer quantity;
    }
}

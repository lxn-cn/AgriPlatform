package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.entity.Cart;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.CartMapper;
import com.agri.platform.mapper.ProductMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 购物车服务：加购、改数量/勾选、删除；列表带实时价格与商品快照
 */
@Service
@RequiredArgsConstructor
public class CartService {

    private final CartMapper cartMapper;
    private final ProductMapper productMapper;

    /** 购物车列表（实时小计由前端 price×quantity 计算） */
    public Map<String, Object> list() {
        Long userId = AuthContext.userId();
        List<Cart> carts = cartMapper.selectList(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId)
                .orderByDesc(Cart::getUpdateTime)
                .orderByDesc(Cart::getId));
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Cart c : carts) {
            Product product = productMapper.selectById(c.getProductId());
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("id", c.getId());
            row.put("productId", c.getProductId());
            row.put("spec", c.getSpec());
            row.put("quantity", c.getQuantity());
            row.put("checked", c.getChecked());
            if (product != null) {
                row.put("productName", product.getName());
                row.put("mainImage", product.getMainImage());
                row.put("price", product.getPrice());
                row.put("stock", product.getStock());
                row.put("productStatus", product.getStatus());
            } else {
                // 商品已被删除时保留占位，前端可提示失效
                row.put("productName", "商品已失效");
                row.put("mainImage", "");
                row.put("price", 0);
                row.put("stock", 0);
                row.put("productStatus", Constants.PRODUCT_OFF);
            }
            rows.add(row);
        }
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("total", rows.size());
        result.put("list", rows);
        return result;
    }

    /** 加入购物车（同商品同规格合并数量） */
    @Transactional(rollbackFor = Exception.class)
    public void add(Long productId, String spec, Integer quantity) {
        Long userId = AuthContext.userId();
        Product product = productMapper.selectById(productId);
        if (product == null || product.getStatus() != Constants.PRODUCT_ON) {
            throw new BizException("商品不存在或已下架");
        }
        int qty = quantity == null ? 1 : quantity;
        if (qty < 1) {
            throw new BizException("数量至少为 1");
        }
        if (product.getStock() != null && product.getStock() > 0 && qty > product.getStock()) {
            throw new BizException("商品库存仅剩 " + product.getStock() + " 件");
        }
        String specVal = spec == null ? "" : spec.trim();
        Cart exist = cartMapper.selectOne(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId)
                .eq(Cart::getProductId, productId)
                .eq(Cart::getSpec, specVal)
                .last("LIMIT 1"));
        if (exist != null) {
            exist.setQuantity(exist.getQuantity() + qty);
            exist.setUpdateTime(LocalDateTime.now());
            cartMapper.updateById(exist);
        } else {
            Cart cart = new Cart();
            cart.setUserId(userId);
            cart.setProductId(productId);
            cart.setSpec(specVal);
            cart.setQuantity(qty);
            cart.setChecked(1);
            cart.setCreateTime(LocalDateTime.now());
            cart.setUpdateTime(LocalDateTime.now());
            cartMapper.insert(cart);
        }
    }

    /** 修改数量/勾选 */
    @Transactional(rollbackFor = Exception.class)
    public void update(Long id, Integer quantity, Integer checked) {
        Cart cart = ownedOrThrow(id);
        if (quantity != null) {
            if (quantity < 1) {
                throw new BizException("数量至少为 1");
            }
            Product product = productMapper.selectById(cart.getProductId());
            if (product != null && product.getStock() != null && product.getStock() > 0
                    && quantity > product.getStock()) {
                throw new BizException("商品库存仅剩 " + product.getStock() + " 件");
            }
            cart.setQuantity(quantity);
        }
        if (checked != null) {
            cart.setChecked(checked == 1 ? 1 : 0);
        }
        cart.setUpdateTime(LocalDateTime.now());
        cartMapper.updateById(cart);
    }

    /** 删除购物车行 */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        Cart cart = ownedOrThrow(id);
        cartMapper.deleteById(cart.getId());
    }

    /** 清理已结算的购物车行（下单 fromCart 时调用） */
    @Transactional(rollbackFor = Exception.class)
    public void removeCheckedAfterOrder(Long userId, List<com.agri.platform.dto.TradeDtos.Item> items) {
        if (items == null) {
            return;
        }
        for (com.agri.platform.dto.TradeDtos.Item item : items) {
            String spec = item.getSpec() == null ? "" : item.getSpec().trim();
            cartMapper.delete(new LambdaQueryWrapper<Cart>()
                    .eq(Cart::getUserId, userId)
                    .eq(Cart::getProductId, item.getProductId())
                    .eq(Cart::getSpec, spec)
                    .eq(Cart::getChecked, 1));
        }
    }

    private Cart ownedOrThrow(Long id) {
        Cart cart = cartMapper.selectById(id);
        if (cart == null || !cart.getUserId().equals(AuthContext.userId())) {
            throw new BizException("购物车记录不存在");
        }
        return cart;
    }
}

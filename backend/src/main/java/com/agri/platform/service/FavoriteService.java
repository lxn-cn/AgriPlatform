package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.ProductMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 商品收藏服务：收藏关系存 Redis hash（agri:fav:{userId}，field=productId，value=收藏时间戳）
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final ProductMapper productMapper;
    private final StringRedisTemplate stringRedisTemplate;

    /** 收藏商品 */
    public void add(Long productId) {
        Long userId = AuthContext.userId();
        Product product = productMapper.selectById(productId);
        if (product == null || product.getStatus() != Constants.PRODUCT_ON) {
            throw new BizException("商品不存在或已下架");
        }
        try {
            stringRedisTemplate.opsForHash().put(favKey(userId), String.valueOf(productId),
                    String.valueOf(System.currentTimeMillis()));
        } catch (Exception e) {
            log.error("收藏写入 Redis 失败: {}", e.getMessage());
            throw new BizException("收藏服务暂不可用，请稍后重试");
        }
    }

    /** 取消收藏 */
    public void remove(Long productId) {
        Long userId = AuthContext.userId();
        try {
            stringRedisTemplate.opsForHash().delete(favKey(userId), String.valueOf(productId));
        } catch (Exception e) {
            log.error("取消收藏失败: {}", e.getMessage());
            throw new BizException("收藏服务暂不可用，请稍后重试");
        }
    }

    /** 我的收藏（含商品快照，按收藏时间倒序） */
    public PageResult<Map<String, Object>> myPage() {
        Long userId = AuthContext.userId();
        Map<String, String> raw;
        try {
            Map<Object, Object> entries = stringRedisTemplate.opsForHash().entries(favKey(userId));
            raw = new HashMap<String, String>();
            for (Map.Entry<Object, Object> e : entries.entrySet()) {
                raw.put(String.valueOf(e.getKey()), String.valueOf(e.getValue()));
            }
        } catch (Exception e) {
            log.error("读取收藏失败: {}", e.getMessage());
            throw new BizException("收藏服务暂不可用，请稍后重试");
        }
        // 按收藏时间倒序
        List<Map.Entry<String, String>> sorted = new ArrayList<Map.Entry<String, String>>(raw.entrySet());
        sorted.sort((a, b) -> Long.compare(Long.parseLong(b.getValue()), Long.parseLong(a.getValue())));

        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
        for (Map.Entry<String, String> entry : sorted) {
            Long productId = Long.valueOf(entry.getKey());
            Product product = productMapper.selectById(productId);
            if (product == null) {
                continue;
            }
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("productId", product.getId());
            row.put("name", product.getName());
            row.put("mainImage", product.getMainImage());
            row.put("price", product.getPrice());
            row.put("specs", product.getSpecs());
            row.put("spec", firstSpec(product.getSpecs()));
            row.put("stock", product.getStock());
            row.put("sales", product.getSales());
            row.put("status", product.getStatus());
            row.put("favoriteTime", Long.parseLong(entry.getValue()));
            list.add(row);
        }
        return new PageResult<Map<String, Object>>(list.size(), list);
    }

    /** 是否已收藏（商品详情角标用） */
    public boolean isFavored(Long userId, Long productId) {
        try {
            Object hit = stringRedisTemplate.opsForHash().get(favKey(userId), String.valueOf(productId));
            return hit != null;
        } catch (Exception e) {
            log.warn("查询收藏状态失败: {}", e.getMessage());
            return false;
        }
    }

    private String favKey(Long userId) {
        return Constants.CACHE_KEY_FAVORITE_PREFIX + userId;
    }

    private String firstSpec(String specs) {
        if (specs == null || specs.isEmpty()) {
            return "";
        }
        String[] arr = specs.split(",");
        return arr.length > 0 ? arr[0].trim() : "";
    }
}

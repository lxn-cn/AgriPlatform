package com.agri.platform.service;

import cn.hutool.json.JSONUtil;
import com.agri.platform.common.Constants;
import com.agri.platform.entity.Banner;
import com.agri.platform.entity.Farm;
import com.agri.platform.entity.Notice;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.BannerMapper;
import com.agri.platform.mapper.FarmMapper;
import com.agri.platform.mapper.NoticeMapper;
import com.agri.platform.mapper.ProductMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页服务：轮播/公告（Redis 5 分钟缓存）、推荐商品、农园入口、聚合搜索
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HomeService {

    private final BannerMapper bannerMapper;
    private final NoticeMapper noticeMapper;
    private final ProductMapper productMapper;
    private final FarmMapper farmMapper;
    private final StringRedisTemplate stringRedisTemplate;

    /** 首页轮播图（按 sort 升序，仅展示中） */
    public List<Banner> banners() {
        String cache = cacheGet(Constants.CACHE_KEY_BANNERS);
        if (cache != null) {
            return JSONUtil.toList(cache, Banner.class);
        }
        List<Banner> list = bannerMapper.selectList(new LambdaQueryWrapper<Banner>()
                .eq(Banner::getStatus, Constants.STATUS_ON)
                .orderByAsc(Banner::getSort)
                .orderByAsc(Banner::getId));
        cachePut(Constants.CACHE_KEY_BANNERS, list);
        return list;
    }

    /** 首页公告（最新 5 条） */
    public List<Notice> notices() {
        String cache = cacheGet(Constants.CACHE_KEY_NOTICES);
        if (cache != null) {
            return JSONUtil.toList(cache, Notice.class);
        }
        List<Notice> list = noticeMapper.selectList(new LambdaQueryWrapper<Notice>()
                .eq(Notice::getStatus, Constants.STATUS_ON)
                .orderByDesc(Notice::getPublishTime)
                .last("LIMIT 5"));
        cachePut(Constants.CACHE_KEY_NOTICES, list);
        return list;
    }

    /** 推荐当季商品（按销量前 10） */
    public List<Product> recommended() {
        return productMapper.selectList(new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, Constants.PRODUCT_ON)
                .orderByDesc(Product::getSales)
                .last("LIMIT 10"));
    }

    /** 首页农园入口卡片（评分前 6） */
    public List<Farm> farmsBrief() {
        return farmMapper.selectList(new LambdaQueryWrapper<Farm>()
                .eq(Farm::getStatus, Constants.STATUS_ON)
                .orderByDesc(Farm::getRating)
                .last("LIMIT 6"));
    }

    /**
     * 关键词聚合搜索：同时匹配商品名与农园名
     */
    public Map<String, Object> search(String keyword) {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        if (!StringUtils.hasText(keyword)) {
            result.put("products", productMapper.selectList(new LambdaQueryWrapper<Product>()
                    .eq(Product::getStatus, Constants.PRODUCT_ON)
                    .orderByDesc(Product::getSales)
                    .last("LIMIT 10")));
            result.put("farms", farmsBrief());
            return result;
        }
        String kw = keyword.trim();
        result.put("products", productMapper.selectList(new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, Constants.PRODUCT_ON)
                .like(Product::getName, kw)
                .orderByDesc(Product::getSales)
                .last("LIMIT 10")));
        result.put("farms", farmMapper.selectList(new LambdaQueryWrapper<Farm>()
                .eq(Farm::getStatus, Constants.STATUS_ON)
                .and(w -> w.like(Farm::getName, kw).or().like(Farm::getDistrict, kw))
                .orderByDesc(Farm::getRating)
                .last("LIMIT 6")));
        return result;
    }

    /** 读取缓存（Redis 异常时降级为直接查库） */
    private String cacheGet(String key) {
        try {
            return stringRedisTemplate.opsForValue().get(key);
        } catch (Exception e) {
            log.warn("Redis 读取失败，降级查库: {}", e.getMessage());
            return null;
        }
    }

    /** 写入缓存（失败不影响主流程） */
    private void cachePut(String key, Object value) {
        try {
            stringRedisTemplate.opsForValue().set(key, JSONUtil.toJsonStr(value),
                    Duration.ofSeconds(Constants.CACHE_TTL_SECONDS));
        } catch (Exception e) {
            log.warn("Redis 写入失败: {}", e.getMessage());
        }
    }
}

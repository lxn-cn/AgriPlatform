package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.entity.Banner;
import com.agri.platform.mapper.BannerMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 轮播图维护：管理端增删改，变更后清除首页缓存
 */
@Service
@RequiredArgsConstructor
public class BannerService {

    private final BannerMapper bannerMapper;
    private final StringRedisTemplate stringRedisTemplate;

    /** 管理端列表（全部） */
    public List<Banner> adminList() {
        return bannerMapper.selectList(new LambdaQueryWrapper<Banner>()
                .orderByAsc(Banner::getSort).orderByAsc(Banner::getId));
    }

    @Transactional(rollbackFor = Exception.class)
    public Banner create(Banner input) {
        validate(input);
        input.setId(null);
        if (input.getSort() == null) {
            input.setSort(0);
        }
        if (input.getStatus() == null) {
            input.setStatus(Constants.STATUS_ON);
        }
        bannerMapper.insert(input);
        evictCache();
        return input;
    }

    @Transactional(rollbackFor = Exception.class)
    public Banner update(Long id, Banner input) {
        Banner db = bannerMapper.selectById(id);
        if (db == null) {
            throw new BizException("轮播图不存在");
        }
        if (StringUtils.hasText(input.getTitle())) {
            db.setTitle(input.getTitle().trim());
        }
        if (StringUtils.hasText(input.getImage())) {
            db.setImage(input.getImage().trim());
        }
        if (input.getLinkType() != null) {
            db.setLinkType(input.getLinkType());
        }
        if (input.getLinkValue() != null) {
            db.setLinkValue(input.getLinkValue());
        }
        if (input.getSort() != null) {
            db.setSort(input.getSort());
        }
        if (input.getStatus() != null) {
            db.setStatus(input.getStatus());
        }
        bannerMapper.updateById(db);
        evictCache();
        return db;
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        if (bannerMapper.selectById(id) == null) {
            throw new BizException("轮播图不存在");
        }
        bannerMapper.deleteById(id);
        evictCache();
    }

    private void validate(Banner input) {
        if (!StringUtils.hasText(input.getImage())) {
            throw new BizException("请填写轮播图图片地址");
        }
    }

    private void evictCache() {
        try {
            stringRedisTemplate.delete(Constants.CACHE_KEY_BANNERS);
        } catch (Exception ignored) {
            // Redis 异常不阻断业务
        }
    }
}

package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.Notice;
import com.agri.platform.mapper.NoticeMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * 公告维护：管理端增删改（支持仅切换状态），变更后清除首页缓存
 */
@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeMapper noticeMapper;
    private final StringRedisTemplate stringRedisTemplate;

    /** 管理端公告分页 */
    public PageResult<Notice> adminPage(Integer status, long pageNum, long pageSize) {
        LambdaQueryWrapper<Notice> wrapper = new LambdaQueryWrapper<Notice>()
                .orderByDesc(Notice::getPublishTime);
        if (status != null) {
            wrapper.eq(Notice::getStatus, status);
        }
        Page<Notice> page = noticeMapper.selectPage(new Page<Notice>(pageNum, pageSize), wrapper);
        return PageResult.from(page);
    }

    @Transactional(rollbackFor = Exception.class)
    public Notice create(Notice input) {
        if (!StringUtils.hasText(input.getTitle())) {
            throw new BizException("公告标题不能为空");
        }
        input.setId(null);
        input.setPublishTime(LocalDateTime.now());
        if (input.getStatus() == null) {
            input.setStatus(Constants.STATUS_ON);
        }
        noticeMapper.insert(input);
        evictCache();
        return input;
    }

    @Transactional(rollbackFor = Exception.class)
    public Notice update(Long id, Notice input) {
        Notice db = noticeMapper.selectById(id);
        if (db == null) {
            throw new BizException("公告不存在");
        }
        if (StringUtils.hasText(input.getTitle())) {
            db.setTitle(input.getTitle().trim());
        }
        if (input.getContent() != null) {
            db.setContent(input.getContent());
        }
        if (input.getStatus() != null) {
            db.setStatus(input.getStatus());
        }
        noticeMapper.updateById(db);
        evictCache();
        return db;
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        if (noticeMapper.selectById(id) == null) {
            throw new BizException("公告不存在");
        }
        noticeMapper.deleteById(id);
        evictCache();
    }

    private void evictCache() {
        try {
            stringRedisTemplate.delete(Constants.CACHE_KEY_NOTICES);
        } catch (Exception ignored) {
            // Redis 异常不阻断业务
        }
    }
}

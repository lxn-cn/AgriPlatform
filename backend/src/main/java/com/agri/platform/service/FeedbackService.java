package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.PageResult;
import com.agri.platform.dto.PlatformDtos;
import com.agri.platform.entity.Feedback;
import com.agri.platform.mapper.FeedbackMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * 意见反馈服务：用户提交、平台回复
 */
@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackMapper feedbackMapper;

    /** 用户提交反馈 */
    @Transactional(rollbackFor = Exception.class)
    public void create(PlatformDtos.FeedbackRequest request) {
        AuthContext.userId();
        Feedback feedback = new Feedback();
        feedback.setUserId(AuthContext.userId());
        feedback.setContent(request.getContent().trim());
        feedback.setContact(request.getContact() == null ? "" : request.getContact().trim());
        feedback.setStatus(0);
        feedback.setReply("");
        feedback.setCreateTime(LocalDateTime.now());
        feedbackMapper.insert(feedback);
    }

    /** 平台反馈分页 */
    public PageResult<Feedback> adminPage(Integer status, long pageNum, long pageSize) {
        LambdaQueryWrapper<Feedback> wrapper = new LambdaQueryWrapper<Feedback>()
                .orderByDesc(Feedback::getCreateTime);
        if (status != null) {
            wrapper.eq(Feedback::getStatus, status);
        }
        Page<Feedback> page = feedbackMapper.selectPage(new Page<Feedback>(pageNum, pageSize), wrapper);
        return PageResult.from(page);
    }

    /** 平台回复反馈 */
    @Transactional(rollbackFor = Exception.class)
    public void reply(Long id, PlatformDtos.ReplyRequest request) {
        Feedback feedback = feedbackMapper.selectById(id);
        if (feedback == null) {
            throw new BizException("反馈不存在");
        }
        if (!StringUtils.hasText(request.getReply())) {
            throw new BizException("请填写回复内容");
        }
        feedback.setReply(request.getReply().trim());
        feedback.setStatus(1);
        feedbackMapper.updateById(feedback);
    }
}

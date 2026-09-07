package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.dto.PlatformDtos;
import com.agri.platform.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

/**
 * 意见反馈接口（用户侧提交）
 */
@RestController
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    /** 提交意见反馈 */
    @PostMapping("/api/feedback")
    public Result<Void> create(@Valid @RequestBody PlatformDtos.FeedbackRequest request) {
        feedbackService.create(request);
        return Result.ok("反馈已提交，感谢您的意见", null);
    }
}

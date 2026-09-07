package com.agri.platform.service;

import com.agri.platform.entity.OperLog;
import com.agri.platform.mapper.OperLogMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 操作日志服务：审核、封禁、退款、强制下架、到园确认等关键操作落库
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OperLogService {

    private final OperLogMapper operLogMapper;

    /**
     * 记录一条操作日志（日志失败不影响主流程）
     */
    public void record(String operatorType, Long operatorId, String operatorName, String action, String detail) {
        try {
            OperLog entity = new OperLog();
            entity.setOperatorType(operatorType);
            entity.setOperatorId(operatorId == null ? 0L : operatorId);
            entity.setOperatorName(operatorName == null ? "" : operatorName);
            entity.setAction(action);
            entity.setDetail(detail == null ? "" : detail);
            entity.setCreateTime(LocalDateTime.now());
            operLogMapper.insert(entity);
        } catch (Exception e) {
            log.warn("操作日志记录失败: {}", e.getMessage());
        }
    }
}

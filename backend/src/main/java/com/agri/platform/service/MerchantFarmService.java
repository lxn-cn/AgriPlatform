package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.Farm;
import com.agri.platform.entity.PickingProject;
import com.agri.platform.mapper.FarmMapper;
import com.agri.platform.mapper.PickingProjectMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 商家农园与采摘项目管理：农园信息维护、项目场次库存维护
 */
@Service
@RequiredArgsConstructor
public class MerchantFarmService {

    private final FarmMapper farmMapper;
    private final PickingProjectMapper pickingProjectMapper;

    // ==================== 农园 ====================

    /** 本商家农园分页 */
    public PageResult<Farm> farmPage(String keyword, long pageNum, long pageSize) {
        LambdaQueryWrapper<Farm> wrapper = new LambdaQueryWrapper<Farm>()
                .eq(Farm::getMerchantId, AuthContext.merchantId())
                .orderByDesc(Farm::getId);
        if (StringUtils.hasText(keyword)) {
            wrapper.like(Farm::getName, keyword.trim());
        }
        Page<Farm> page = farmMapper.selectPage(new Page<Farm>(pageNum, pageSize), wrapper);
        return PageResult.from(page);
    }

    /** 农园详情（校验归属） */
    public Farm farmDetail(Long id) {
        return farmOwnedOrThrow(id);
    }

    /** 新建农园 */
    @Transactional(rollbackFor = Exception.class)
    public Farm createFarm(Farm input) {
        validateFarm(input);
        Long merchantId = AuthContext.merchantId();
        Farm farm = new Farm();
        copyFarm(farm, input);
        farm.setMerchantId(merchantId);
        farm.setStatus(input.getStatus() != null && input.getStatus() == Constants.STATUS_OFF
                ? Constants.STATUS_OFF : Constants.STATUS_ON);
        farm.setCreateTime(LocalDateTime.now());
        farm.setUpdateTime(LocalDateTime.now());
        farmMapper.insert(farm);
        return farm;
    }

    /** 修改农园（含交通指引；非空字段生效） */
    @Transactional(rollbackFor = Exception.class)
    public Farm updateFarm(Long id, Farm input) {
        Farm farm = farmOwnedOrThrow(id);
        if (StringUtils.hasText(input.getName())) {
            farm.setName(input.getName().trim());
        }
        if (StringUtils.hasText(input.getType())) {
            farm.setType(input.getType().trim());
        }
        if (StringUtils.hasText(input.getDistrict())) {
            farm.setDistrict(input.getDistrict().trim());
        }
        if (StringUtils.hasText(input.getAddress())) {
            farm.setAddress(input.getAddress().trim());
        }
        if (input.getBusinessHours() != null) {
            farm.setBusinessHours(input.getBusinessHours().trim());
        }
        if (input.getIntro() != null) {
            farm.setIntro(input.getIntro());
        }
        if (input.getCoverImage() != null) {
            farm.setCoverImage(input.getCoverImage());
        }
        if (input.getImages() != null) {
            farm.setImages(input.getImages());
        }
        if (input.getAvgPrice() != null) {
            farm.setAvgPrice(input.getAvgPrice());
        }
        if (input.getTrafficGuide() != null) {
            farm.setTrafficGuide(input.getTrafficGuide());
        }
        if (input.getStatus() != null) {
            farm.setStatus(input.getStatus() == Constants.STATUS_OFF ? Constants.STATUS_OFF : Constants.STATUS_ON);
        }
        farm.setUpdateTime(LocalDateTime.now());
        farmMapper.updateById(farm);
        return farm;
    }

    // ==================== 采摘项目 ====================

    /** 采摘项目列表（按 farmId，须为本商家农园） */
    public PageResult<PickingProject> projectPage(Long farmId) {
        Farm farm = farmOwnedOrThrow(farmId);
        List<PickingProject> list = pickingProjectMapper.selectList(
                new LambdaQueryWrapper<PickingProject>()
                        .eq(PickingProject::getFarmId, farm.getId())
                        .orderByDesc(PickingProject::getId));
        return new PageResult<PickingProject>(list.size(), list);
    }

    /** 新建采摘项目 */
    @Transactional(rollbackFor = Exception.class)
    public PickingProject createProject(PickingProject input) {
        Farm farm = farmOwnedOrThrow(input.getFarmId());
        validateProject(input);
        PickingProject project = new PickingProject();
        copyProject(project, input);
        project.setFarmId(farm.getId());
        project.setStatus(input.getStatus() != null && input.getStatus() == Constants.STATUS_OFF
                ? Constants.STATUS_OFF : Constants.STATUS_ON);
        project.setCreateTime(LocalDateTime.now());
        project.setUpdateTime(LocalDateTime.now());
        pickingProjectMapper.insert(project);
        return project;
    }

    /** 修改采摘项目（含场次库存） */
    @Transactional(rollbackFor = Exception.class)
    public PickingProject updateProject(Long id, PickingProject input) {
        PickingProject project = projectOwnedOrThrow(id);
        if (StringUtils.hasText(input.getName())) {
            project.setName(input.getName().trim());
        }
        if (input.getSeasonStart() != null) {
            project.setSeasonStart(input.getSeasonStart());
        }
        if (input.getSeasonEnd() != null) {
            project.setSeasonEnd(input.getSeasonEnd());
        }
        if (StringUtils.hasText(input.getPriceMode())) {
            project.setPriceMode(input.getPriceMode().trim());
        }
        if (input.getPrice() != null) {
            project.setPrice(input.getPrice());
        }
        if (StringUtils.hasText(input.getSession())) {
            project.setSession(input.getSession().trim());
        }
        if (input.getStock() != null) {
            if (input.getStock() < 0) {
                throw new BizException("库存不能为负数");
            }
            project.setStock(input.getStock());
        }
        if (input.getStatus() != null) {
            project.setStatus(input.getStatus() == Constants.STATUS_OFF ? Constants.STATUS_OFF : Constants.STATUS_ON);
        }
        project.setUpdateTime(LocalDateTime.now());
        pickingProjectMapper.updateById(project);
        return project;
    }

    /** 下架采摘项目（逻辑删除入口，实为下架） */
    @Transactional(rollbackFor = Exception.class)
    public void deleteProject(Long id) {
        PickingProject project = projectOwnedOrThrow(id);
        project.setStatus(Constants.STATUS_OFF);
        project.setUpdateTime(LocalDateTime.now());
        pickingProjectMapper.updateById(project);
    }

    // ==================== 私有辅助 ====================

    private Farm farmOwnedOrThrow(Long id) {
        Farm farm = farmMapper.selectById(id);
        if (farm == null || !farm.getMerchantId().equals(AuthContext.merchantId())) {
            throw new BizException("农园不存在或无权操作");
        }
        return farm;
    }

    private PickingProject projectOwnedOrThrow(Long id) {
        PickingProject project = pickingProjectMapper.selectById(id);
        if (project == null) {
            throw new BizException("采摘项目不存在");
        }
        farmOwnedOrThrow(project.getFarmId());
        return project;
    }

    private void validateFarm(Farm input) {
        if (!StringUtils.hasText(input.getName())) {
            throw new BizException("农园名称不能为空");
        }
        if (!StringUtils.hasText(input.getType())) {
            throw new BizException("请选择农园类型");
        }
        if (!StringUtils.hasText(input.getDistrict())) {
            throw new BizException("请选择所在区县");
        }
        if (!StringUtils.hasText(input.getAddress())) {
            throw new BizException("请填写详细地址");
        }
    }

    private void copyFarm(Farm farm, Farm input) {
        farm.setName(input.getName().trim());
        farm.setType(input.getType().trim());
        farm.setDistrict(input.getDistrict().trim());
        farm.setAddress(input.getAddress().trim());
        farm.setBusinessHours(input.getBusinessHours() == null ? "08:30-17:00" : input.getBusinessHours().trim());
        farm.setIntro(input.getIntro() == null ? "" : input.getIntro());
        farm.setCoverImage(input.getCoverImage() == null ? "" : input.getCoverImage());
        farm.setImages(input.getImages() == null ? "" : input.getImages());
        farm.setAvgPrice(input.getAvgPrice() == null ? java.math.BigDecimal.ZERO : input.getAvgPrice());
        farm.setRating(new java.math.BigDecimal("5.0"));
        farm.setTrafficGuide(input.getTrafficGuide() == null ? "" : input.getTrafficGuide());
    }

    private void validateProject(PickingProject input) {
        if (!StringUtils.hasText(input.getName())) {
            throw new BizException("项目名称不能为空");
        }
        if (!StringUtils.hasText(input.getPriceMode())) {
            throw new BizException("请选择计价方式");
        }
        if (input.getPrice() == null || input.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0) {
            throw new BizException("价格不能为负数");
        }
        if (!StringUtils.hasText(input.getSession())) {
            throw new BizException("请至少选择一个场次");
        }
        if (input.getStock() == null || input.getStock() < 0) {
            throw new BizException("库存不能为负数");
        }
    }

    private void copyProject(PickingProject project, PickingProject input) {
        project.setName(input.getName().trim());
        project.setSeasonStart(input.getSeasonStart());
        project.setSeasonEnd(input.getSeasonEnd());
        project.setPriceMode(input.getPriceMode().trim());
        project.setPrice(input.getPrice());
        project.setSession(input.getSession().trim());
        project.setStock(input.getStock());
    }
}

package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.Farm;
import com.agri.platform.entity.Merchant;
import com.agri.platform.entity.PickingProject;
import com.agri.platform.entity.Review;
import com.agri.platform.mapper.FarmMapper;
import com.agri.platform.mapper.MerchantMapper;
import com.agri.platform.mapper.PickingProjectMapper;
import com.agri.platform.mapper.ReviewMapper;
import com.agri.platform.mapper.UserMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 农园服务：用户侧农园浏览（列表/详情/评价）
 */
@Service
@RequiredArgsConstructor
public class FarmService {

    private final FarmMapper farmMapper;
    private final MerchantMapper merchantMapper;
    private final PickingProjectMapper pickingProjectMapper;
    private final ReviewMapper reviewMapper;
    private final UserMapper userMapper;

    /**
     * 农园列表：区县/类型/关键词筛选 + 排序（rating/price_asc/price_desc）
     */
    public PageResult<Farm> page(String district, String type, String keyword, String sort,
                                 long pageNum, long pageSize) {
        LambdaQueryWrapper<Farm> wrapper = new LambdaQueryWrapper<Farm>()
                .eq(Farm::getStatus, Constants.STATUS_ON);
        if (StringUtils.hasText(district)) {
            wrapper.eq(Farm::getDistrict, district.trim());
        }
        if (StringUtils.hasText(type)) {
            wrapper.eq(Farm::getType, type.trim());
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Farm::getName, keyword.trim())
                    .or().like(Farm::getDistrict, keyword.trim()));
        }
        if ("price_asc".equals(sort)) {
            wrapper.orderByAsc(Farm::getAvgPrice);
        } else if ("price_desc".equals(sort)) {
            wrapper.orderByDesc(Farm::getAvgPrice);
        } else {
            // 默认按评分（人气）降序
            wrapper.orderByDesc(Farm::getRating);
        }
        wrapper.orderByDesc(Farm::getId);
        Page<Farm> page = farmMapper.selectPage(new Page<Farm>(pageNum, pageSize), wrapper);
        return PageResult.from(page);
    }

    /**
     * 农园详情：基础信息 + 商家联系电话（一键拨打）+ 当季上架项目列表
     */
    public Map<String, Object> detail(Long id) {
        Farm farm = farmMapper.selectById(id);
        if (farm == null || farm.getStatus() != Constants.STATUS_ON) {
            throw new BizException("农园不存在或已下架");
        }
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("id", farm.getId());
        result.put("merchantId", farm.getMerchantId());
        result.put("name", farm.getName());
        result.put("type", farm.getType());
        result.put("district", farm.getDistrict());
        result.put("address", farm.getAddress());
        result.put("businessHours", farm.getBusinessHours());
        result.put("intro", farm.getIntro());
        result.put("coverImage", farm.getCoverImage());
        result.put("images", farm.getImages());
        result.put("avgPrice", farm.getAvgPrice());
        result.put("rating", farm.getRating());
        result.put("trafficGuide", farm.getTrafficGuide());
        // 农园联系电话取所属商家电话（farm 表不单设电话字段）
        Merchant merchant = merchantMapper.selectById(farm.getMerchantId());
        result.put("phone", merchant == null ? "" : merchant.getPhone());
        List<PickingProject> projects = pickingProjectMapper.selectList(
                new LambdaQueryWrapper<PickingProject>()
                        .eq(PickingProject::getFarmId, id)
                        .eq(PickingProject::getStatus, Constants.STATUS_ON)
                        .orderByAsc(PickingProject::getId));
        result.put("projects", projects);
        return result;
    }

    /** 农园评价分页（附用户昵称） */
    public PageResult<Map<String, Object>> reviews(Long farmId, long pageNum, long pageSize) {
        Page<Review> page = reviewMapper.selectPage(new Page<Review>(pageNum, pageSize),
                new LambdaQueryWrapper<Review>()
                        .eq(Review::getRelType, Constants.REVIEW_TYPE_FARM)
                        .eq(Review::getRelId, farmId)
                        .orderByDesc(Review::getCreateTime));
        return new PageResult<Map<String, Object>>(page.getTotal(), ReviewService.withNickname(page.getRecords(), userMapper));
    }
}

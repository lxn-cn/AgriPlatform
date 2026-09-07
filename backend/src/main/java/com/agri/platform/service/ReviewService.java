package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.entity.Appointment;
import com.agri.platform.entity.Farm;
import com.agri.platform.entity.OrderItem;
import com.agri.platform.entity.Orders;
import com.agri.platform.entity.Review;
import com.agri.platform.entity.User;
import com.agri.platform.mapper.AppointmentMapper;
import com.agri.platform.mapper.FarmMapper;
import com.agri.platform.mapper.OrderItemMapper;
import com.agri.platform.mapper.OrderMapper;
import com.agri.platform.mapper.ReviewMapper;
import com.agri.platform.mapper.UserMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 评价服务：商品评价（已完成订单）与农园评价（已使用预约）通用
 */
@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewMapper reviewMapper;
    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final AppointmentMapper appointmentMapper;
    private final FarmMapper farmMapper;
    private final UserMapper userMapper;

    /**
     * 发布评价：
     * - relType=product：需已完成订单（status=3），relId 为该订单内商品
     * - relType=farm：需已使用预约（status=2），relId 为该预约的农园
     */
    @Transactional(rollbackFor = Exception.class)
    public void create(TradeDtos.ReviewCreateRequest request) {
        Long userId = AuthContext.userId();
        String relType = request.getRelType().trim();
        Review review = new Review();
        review.setRelType(relType);
        review.setRelId(request.getRelId());
        review.setUserId(userId);
        review.setRating(request.getRating());
        review.setContent(request.getContent().trim());
        review.setImages("");
        review.setCreateTime(LocalDateTime.now());

        if (Constants.REVIEW_TYPE_PRODUCT.equals(relType)) {
            reviewProduct(review, request);
        } else if (Constants.REVIEW_TYPE_FARM.equals(relType)) {
            reviewFarm(review, request);
        } else {
            throw new BizException("评价类型不合法");
        }
        reviewMapper.insert(review);

        // 农园评价后回写平均评分
        if (Constants.REVIEW_TYPE_FARM.equals(relType)) {
            Farm farm = farmMapper.selectById(review.getRelId());
            if (farm != null) {
                farm.setRating(reviewMapper.avgFarmRating(farm.getId()));
                farm.setUpdateTime(LocalDateTime.now());
                farmMapper.updateById(farm);
            }
        }
    }

    private void reviewProduct(Review review, TradeDtos.ReviewCreateRequest request) {
        if (request.getOrderId() == null) {
            throw new BizException("商品评价必须关联订单");
        }
        Orders order = orderMapper.selectById(request.getOrderId());
        if (order == null || !order.getUserId().equals(review.getUserId())) {
            throw new BizException("订单不存在");
        }
        if (order.getStatus() != Constants.ORDER_FINISHED) {
            throw new BizException("仅已完成的订单可评价");
        }
        Long itemCount = orderItemMapper.selectCount(new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, order.getId())
                .eq(OrderItem::getProductId, review.getRelId()));
        if (itemCount == null || itemCount == 0) {
            throw new BizException("该商品不在本次订单中");
        }
        Long exist = reviewMapper.selectCount(new LambdaQueryWrapper<Review>()
                .eq(Review::getRelType, Constants.REVIEW_TYPE_PRODUCT)
                .eq(Review::getUserId, review.getUserId())
                .eq(Review::getOrderId, order.getId())
                .eq(Review::getRelId, review.getRelId()));
        if (exist != null && exist > 0) {
            throw new BizException("您已评价过该商品，无需重复评价");
        }
        review.setOrderId(order.getId());
    }

    private void reviewFarm(Review review, TradeDtos.ReviewCreateRequest request) {
        if (request.getAppointmentId() == null) {
            throw new BizException("农园评价必须关联预约单");
        }
        Appointment appointment = appointmentMapper.selectById(request.getAppointmentId());
        if (appointment == null || !appointment.getUserId().equals(review.getUserId())) {
            throw new BizException("预约单不存在");
        }
        if (appointment.getStatus() != Constants.APPOINTMENT_USED) {
            throw new BizException("仅“已使用”的预约可评价农园");
        }
        if (!appointment.getFarmId().equals(review.getRelId())) {
            throw new BizException("该农园与预约单不匹配");
        }
        Long exist = reviewMapper.selectCount(new LambdaQueryWrapper<Review>()
                .eq(Review::getRelType, Constants.REVIEW_TYPE_FARM)
                .eq(Review::getUserId, review.getUserId())
                .eq(Review::getAppointmentId, appointment.getId()));
        if (exist != null && exist > 0) {
            throw new BizException("您已评价过该次采摘体验");
        }
        review.setAppointmentId(appointment.getId());
    }

    /** 商品评价分页 */
    public PageResult<Map<String, Object>> productReviews(Long productId, long pageNum, long pageSize) {
        Page<Review> page = reviewMapper.selectPage(new Page<Review>(pageNum, pageSize),
                new LambdaQueryWrapper<Review>()
                        .eq(Review::getRelType, Constants.REVIEW_TYPE_PRODUCT)
                        .eq(Review::getRelId, productId)
                        .orderByDesc(Review::getCreateTime));
        return new PageResult<Map<String, Object>>(page.getTotal(), withNickname(page.getRecords(), userMapper));
    }

    /** 评价列表补充用户昵称（Farm/Product 评价分页共用） */
    public static List<Map<String, Object>> withNickname(List<Review> reviews, UserMapper userMapper) {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Review r : reviews) {
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("id", r.getId());
            row.put("relType", r.getRelType());
            row.put("relId", r.getRelId());
            row.put("userId", r.getUserId());
            row.put("rating", r.getRating());
            row.put("content", r.getContent());
            row.put("images", r.getImages());
            row.put("createTime", r.getCreateTime());
            User user = userMapper.selectById(r.getUserId());
            row.put("nickname", user == null ? "匿名用户" : user.getNickname());
            row.put("avatar", user == null ? "" : user.getAvatar());
            rows.add(row);
        }
        return rows;
    }
}

package com.agri.platform.service;

import com.agri.platform.common.Constants;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.AppointmentMapper;
import com.agri.platform.mapper.OrderItemMapper;
import com.agri.platform.mapper.OrderMapper;
import com.agri.platform.mapper.ProductMapper;
import com.agri.platform.mapper.UserMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 统计服务：平台数据看板 + 商家经营统计（近 7 日趋势补零对齐）
 */
@Service
@RequiredArgsConstructor
public class StatsService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final AppointmentMapper appointmentMapper;
    private final UserMapper userMapper;
    private final ProductMapper productMapper;

    private static final DateTimeFormatter DAY_FMT = DateTimeFormatter.ofPattern("MM-dd");

    /**
     * 平台总览：总交易额/订单量/预约量/用户数 + 近 7 日趋势 + 分类销售额占比
     */
    public Map<String, Object> adminOverview() {
        LocalDateTime start = LocalDate.now().minusDays(6).atStartOfDay();

        Map<String, Long> orderCount = groupByDay(orderMapper.countByDay(start));
        Map<String, Long> apptCount = groupByDay(appointmentMapper.countByDay(start));

        List<Map<String, Object>> trend = new ArrayList<Map<String, Object>>();
        for (int i = 6; i >= 0; i--) {
            LocalDate day = LocalDate.now().minusDays(i);
            String key = day.format(DateTimeFormatter.ISO_LOCAL_DATE);
            Map<String, Object> point = new LinkedHashMap<String, Object>();
            point.put("date", day.format(DAY_FMT));
            point.put("orderCount", orderCount.getOrDefault(key, 0L));
            point.put("appointmentCount", apptCount.getOrDefault(key, 0L));
            trend.add(point);
        }

        List<Map<String, Object>> categoryShare = new ArrayList<Map<String, Object>>();
        for (Map<String, Object> row : orderItemMapper.categorySales()) {
            Map<String, Object> item = new LinkedHashMap<String, Object>();
            item.put("name", row.get("name"));
            item.put("value", row.get("amount"));
            categoryShare.add(item);
        }

        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("totalAmount", orderMapper.sumPaidAmount());
        result.put("totalOrders", orderMapper.selectCount(null));
        result.put("totalAppointments", appointmentMapper.selectCount(null));
        result.put("totalUsers", userMapper.selectCount(null));
        result.put("trend", trend);
        result.put("categoryShare", categoryShare);
        return result;
    }

    /**
     * 商家经营统计：销量/销售额/预约人次/在售商品 + 近 7 日趋势
     */
    public Map<String, Object> merchantStats() {
        Long merchantId = AuthContext.merchantId();
        LocalDateTime start = LocalDate.now().minusDays(6).atStartOfDay();

        Map<String, Map<String, Object>> orderTrend = new HashMap<String, Map<String, Object>>();
        for (Map<String, Object> row : orderItemMapper.merchantTrend(merchantId, start)) {
            orderTrend.put(String.valueOf(row.get("d")), row);
        }
        Map<String, Long> apptTrend = groupByDay(appointmentMapper.merchantTrend(merchantId, start));

        List<Map<String, Object>> trend = new ArrayList<Map<String, Object>>();
        for (int i = 6; i >= 0; i--) {
            LocalDate day = LocalDate.now().minusDays(i);
            String key = day.format(DateTimeFormatter.ISO_LOCAL_DATE);
            Map<String, Object> sales = orderTrend.get(key);
            Map<String, Object> point = new LinkedHashMap<String, Object>();
            point.put("date", day.format(DAY_FMT));
            point.put("salesCount", sales == null ? 0L : toLong(sales.get("c")));
            point.put("salesAmount", sales == null ? BigDecimal.ZERO : sales.get("amount"));
            point.put("appointmentCount", apptTrend.getOrDefault(key, 0L));
            trend.add(point);
        }

        Long productCount = productMapper.selectCount(new LambdaQueryWrapper<Product>()
                .eq(Product::getMerchantId, merchantId)
                .eq(Product::getStatus, Constants.PRODUCT_ON));

        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("salesCount", orderItemMapper.sumMerchantQuantity(merchantId));
        result.put("salesAmount", orderItemMapper.sumMerchantAmount(merchantId));
        result.put("appointmentCount", appointmentMapper.sumMerchantPeople(merchantId));
        result.put("productCount", productCount == null ? 0 : productCount);
        result.put("trend", trend);
        return result;
    }

    private Map<String, Long> groupByDay(List<Map<String, Object>> rows) {
        Map<String, Long> result = new HashMap<String, Long>();
        for (Map<String, Object> row : rows) {
            result.put(String.valueOf(row.get("d")), toLong(row.get("c")));
        }
        return result;
    }

    private long toLong(Object value) {
        if (value == null) {
            return 0L;
        }
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException e) {
            return 0L;
        }
    }
}

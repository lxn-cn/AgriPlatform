package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.dto.TradeDtos;
import com.agri.platform.entity.Address;
import com.agri.platform.entity.OrderItem;
import com.agri.platform.entity.Orders;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.AddressMapper;
import com.agri.platform.mapper.OrderItemMapper;
import com.agri.platform.mapper.OrderMapper;
import com.agri.platform.mapper.ProductMapper;
import com.agri.platform.util.AuthContext;
import com.agri.platform.util.OrderNoUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 订单服务：下单/支付/收货/退款全流程 + 商家发货与退款处理
 */
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final ProductMapper productMapper;
    private final AddressMapper addressMapper;
    private final CartService cartService;
    private final OperLogService operLogService;

    /**
     * 提交订单：校验库存、快照地址与商品价格、生成订单号
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> create(TradeDtos.OrderCreateRequest request) {
        Long userId = AuthContext.userId();
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BizException("订单商品不能为空");
        }
        Address address = addressMapper.selectById(request.getAddressId());
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BizException("收货地址不存在");
        }
        // 校验商品并计算金额
        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<OrderItem>();
        for (TradeDtos.Item param : request.getItems()) {
            Product product = productMapper.selectById(param.getProductId());
            if (product == null || product.getStatus() != Constants.PRODUCT_ON) {
                throw new BizException("商品「#" + param.getProductId() + "」不存在或已下架");
            }
            int qty = param.getQuantity() == null ? 1 : param.getQuantity();
            if (product.getStock() == null || product.getStock() < qty) {
                throw new BizException("商品「" + product.getName() + "」库存不足");
            }
            OrderItem item = new OrderItem();
            item.setProductId(product.getId());
            item.setProductName(product.getName());
            item.setMainImage(product.getMainImage());
            item.setPrice(product.getPrice());
            item.setQuantity(qty);
            item.setSpec(param.getSpec() == null ? "" : param.getSpec().trim());
            items.add(item);
            total = total.add(product.getPrice().multiply(BigDecimal.valueOf(qty)));
        }
        // 生成订单
        Orders order = new Orders();
        order.setOrderNo(OrderNoUtil.orderNo());
        order.setUserId(userId);
        order.setTotalAmount(total);
        order.setStatus(Constants.ORDER_UNPAID);
        order.setReceiver(address.getReceiver());
        order.setPhone(address.getPhone());
        order.setAddress("天津市" + address.getDistrict() + address.getDetail());
        order.setRemark(request.getRemark() == null ? "" : request.getRemark().trim());
        order.setCreateTime(LocalDateTime.now());
        orderMapper.insert(order);
        for (OrderItem item : items) {
            item.setOrderId(order.getId());
            orderItemMapper.insert(item);
        }
        // 购物车结算：清理对应已勾选行
        if (Boolean.TRUE.equals(request.getFromCart())) {
            cartService.removeCheckedAfterOrder(userId, request.getItems());
        }
        return toRow(order, items);
    }

    /** 我的订单分页（附明细） */
    public PageResult<Map<String, Object>> myPage(Integer status, long pageNum, long pageSize) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<Orders>()
                .eq(Orders::getUserId, AuthContext.userId())
                .orderByDesc(Orders::getCreateTime);
        if (status != null) {
            wrapper.eq(Orders::getStatus, status);
        }
        Page<Orders> page = orderMapper.selectPage(new Page<Orders>(pageNum, pageSize), wrapper);
        return new PageResult<Map<String, Object>>(page.getTotal(), toRows(page.getRecords()));
    }

    /** 订单详情（校验归属，附明细） */
    public Map<String, Object> detail(Long id) {
        Orders order = orderMapper.selectById(id);
        if (order == null || !order.getUserId().equals(AuthContext.userId())) {
            throw new BizException("订单不存在");
        }
        return toRow(order, itemsOf(order.getId()));
    }

    /** 模拟支付：待付款 → 待发货（扣库存、加销量） */
    @Transactional(rollbackFor = Exception.class)
    public void pay(Long id) {
        Orders order = userOwnedOrThrow(id);
        if (order.getStatus() != Constants.ORDER_UNPAID) {
            throw new BizException("当前订单状态不可支付");
        }
        List<OrderItem> items = itemsOf(order.getId());
        for (OrderItem item : items) {
            int updated = productMapper.deductStock(item.getProductId(), item.getQuantity());
            if (updated == 0) {
                throw new BizException("商品「" + item.getProductName() + "」库存不足，支付失败");
            }
        }
        order.setStatus(Constants.ORDER_PAID);
        order.setPayTime(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    /** 取消订单（仅待付款） */
    @Transactional(rollbackFor = Exception.class)
    public void cancel(Long id) {
        Orders order = userOwnedOrThrow(id);
        if (order.getStatus() != Constants.ORDER_UNPAID) {
            throw new BizException("仅待付款订单可取消");
        }
        order.setStatus(Constants.ORDER_CANCELED);
        order.setCancelTime(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    /** 确认收货：待收货 → 已完成 */
    @Transactional(rollbackFor = Exception.class)
    public void confirm(Long id) {
        Orders order = userOwnedOrThrow(id);
        if (order.getStatus() != Constants.ORDER_SHIPPED) {
            throw new BizException("当前订单状态不可确认收货");
        }
        order.setStatus(Constants.ORDER_FINISHED);
        order.setFinishTime(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    /** 申请退款：待发货/待收货 → 退款中 */
    @Transactional(rollbackFor = Exception.class)
    public void refund(Long id, String reason) {
        Orders order = userOwnedOrThrow(id);
        if (order.getStatus() != Constants.ORDER_PAID && order.getStatus() != Constants.ORDER_SHIPPED) {
            throw new BizException("当前订单状态不可申请退款");
        }
        if (!StringUtils.hasText(reason)) {
            throw new BizException("请填写退款原因");
        }
        order.setStatus(Constants.ORDER_REFUNDING);
        order.setRefundReason(reason.trim());
        orderMapper.updateById(order);
    }

    // ==================== 商家侧 ====================

    /** 商家订单分页（通过 order_item→product 归属过滤，附明细） */
    public PageResult<Map<String, Object>> merchantPage(Integer status, long pageNum, long pageSize) {
        Long merchantId = AuthContext.merchantId();
        List<Long> orderIds = orderItemMapper.selectMerchantOrderIds(merchantId);
        if (orderIds.isEmpty()) {
            return PageResult.empty();
        }
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<Orders>()
                .in(Orders::getId, orderIds)
                .orderByDesc(Orders::getCreateTime);
        if (status != null) {
            wrapper.eq(Orders::getStatus, status);
        }
        Page<Orders> page = orderMapper.selectPage(new Page<Orders>(pageNum, pageSize), wrapper);
        return new PageResult<Map<String, Object>>(page.getTotal(), toRows(page.getRecords()));
    }

    /** 发货：待发货 → 待收货 */
    @Transactional(rollbackFor = Exception.class)
    public void ship(Long id) {
        Orders order = merchantOwnedOrThrow(id);
        if (order.getStatus() != Constants.ORDER_PAID) {
            throw new BizException("仅待发货订单可发货");
        }
        order.setStatus(Constants.ORDER_SHIPPED);
        order.setShipTime(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    /** 同意退款：退款中 → 已退款（回滚库存，记录日志） */
    @Transactional(rollbackFor = Exception.class)
    public void refundAgree(Long id) {
        Orders order = merchantOwnedOrThrow(id);
        if (order.getStatus() != Constants.ORDER_REFUNDING) {
            throw new BizException("该订单当前无退款申请");
        }
        for (OrderItem item : itemsOf(order.getId())) {
            productMapper.restoreStock(item.getProductId(), item.getQuantity());
        }
        order.setStatus(Constants.ORDER_REFUNDED);
        orderMapper.updateById(order);
        operLogService.record(Constants.OPERATOR_MERCHANT, AuthContext.merchantId(), AuthContext.name(),
                "ORDER_REFUND_AGREE", "同意退款订单 " + order.getOrderNo() + "，金额 "
                        + order.getTotalAmount() + " 元，库存已回滚");
    }

    // ==================== 平台侧 ====================

    /** 全平台订单分页（附明细） */
    public PageResult<Map<String, Object>> adminPage(Integer status, String orderNo,
                                                     long pageNum, long pageSize) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<Orders>()
                .orderByDesc(Orders::getCreateTime);
        if (status != null) {
            wrapper.eq(Orders::getStatus, status);
        }
        if (StringUtils.hasText(orderNo)) {
            wrapper.like(Orders::getOrderNo, orderNo.trim());
        }
        Page<Orders> page = orderMapper.selectPage(new Page<Orders>(pageNum, pageSize), wrapper);
        return new PageResult<Map<String, Object>>(page.getTotal(), toRows(page.getRecords()));
    }

    // ==================== 私有辅助 ====================

    private Orders userOwnedOrThrow(Long id) {
        Orders order = orderMapper.selectById(id);
        if (order == null || !order.getUserId().equals(AuthContext.userId())) {
            throw new BizException("订单不存在");
        }
        return order;
    }

    private Orders merchantOwnedOrThrow(Long id) {
        Orders order = orderMapper.selectById(id);
        if (order == null) {
            throw new BizException("订单不存在");
        }
        List<Long> orderIds = orderItemMapper.selectMerchantOrderIds(AuthContext.merchantId());
        Set<Long> idSet = new HashSet<Long>(orderIds);
        if (!idSet.contains(order.getId())) {
            throw new BizException("无权操作该订单");
        }
        return order;
    }

    private List<OrderItem> itemsOf(Long orderId) {
        return orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, orderId));
    }

    private List<Map<String, Object>> toRows(List<Orders> orders) {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Orders o : orders) {
            rows.add(toRow(o, itemsOf(o.getId())));
        }
        return rows;
    }

    private Map<String, Object> toRow(Orders order, List<OrderItem> items) {
        Map<String, Object> row = new LinkedHashMap<String, Object>(
                cn.hutool.core.bean.BeanUtil.beanToMap(order));
        row.put("items", items);
        return row;
    }
}

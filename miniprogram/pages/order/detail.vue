<template>
    <view>
    <view class="container" v-if="d">
        <!-- 状态卡 -->
        <view class="card status-card">
            <text class="tag" :class="tagClass(d.status)">{{ statusText(d.status) }}</text>
            <text class="status-amount price">¥{{ d.priceText }}</text>
        </view>

        <!-- 收货信息 -->
        <view class="card">
            <text class="card-title">收货信息</text>
            <view class="d-row"><text class="d-label">收货人</text><text>{{ d.receiver }}</text></view>
            <view class="d-row"><text class="d-label">联系电话</text><text>{{ d.phone }}</text></view>
            <view class="d-row"><text class="d-label">收货地址</text><text class="d-value">{{ d.address }}</text></view>
            <view class="d-row" v-if="d.remark"><text class="d-label">买家留言</text><text class="d-value">{{ d.remark }}</text></view>
            <view class="d-row" v-if="d.refundReason"><text class="d-label">退款原因</text><text class="d-value">{{ d.refundReason }}</text></view>
        </view>

        <!-- 商品明细 -->
        <view class="card">
            <text class="card-title">商品明细</text>
            <view class="item-row" v-for="(it, i) in d.items" :key="i">
                <image class="item-img" :src="it.imageUrl" mode="aspectFill" @click="goProduct(it.productId)" />
                <view class="item-body">
                    <text class="item-name ellipsis2">{{ it.productName }}</text>
                    <text v-if="it.spec" class="small gray">规格：{{ it.spec }}</text>
                    <view class="flex-between">
                        <text class="price">¥{{ it.priceText }}</text>
                        <text class="small gray">× {{ it.quantity }}</text>
                    </view>
                    <view class="item-review" v-if="d.status === 3">
                        <text class="small green" @click.stop="goReview(it)">评价该商品</text>
                    </view>
                </view>
            </view>
            <view class="divider"></view>
            <view class="d-row"><text class="d-label">订单金额</text><text class="price">¥{{ d.priceText }}</text></view>
        </view>

        <!-- 时间线 -->
        <view class="card">
            <text class="card-title">订单时间线</text>
            <view class="timeline">
                <view class="tl-item">
                    <view class="tl-dot"></view>
                    <view class="tl-info">
                        <text>下单时间</text>
                        <text class="small gray">{{ d.createTime || '-' }}</text>
                    </view>
                </view>
                <view class="tl-item" v-if="d.payTime">
                    <view class="tl-dot"></view>
                    <view class="tl-info">
                        <text>支付时间</text>
                        <text class="small gray">{{ d.payTime }}</text>
                    </view>
                </view>
                <view class="tl-item" v-if="d.shipTime">
                    <view class="tl-dot"></view>
                    <view class="tl-info">
                        <text>发货时间</text>
                        <text class="small gray">{{ d.shipTime }}</text>
                    </view>
                </view>
                <view class="tl-item" v-if="d.finishTime">
                    <view class="tl-dot"></view>
                    <view class="tl-info">
                        <text>完成时间</text>
                        <text class="small gray">{{ d.finishTime }}</text>
                    </view>
                </view>
                <view class="tl-item" v-if="d.cancelTime">
                    <view class="tl-dot"></view>
                    <view class="tl-info">
                        <text>取消时间</text>
                        <text class="small gray">{{ d.cancelTime }}</text>
                    </view>
                </view>
            </view>
        </view>

        <!-- 操作 -->
        <view class="card">
            <button v-if="d.status === 0" class="btn btn-primary op-btn" @click="goPay">去支付</button>
            <button v-if="d.status === 0" class="btn btn-outline op-btn" @click="onCancel">取消订单</button>
            <button v-if="d.status === 1 || d.status === 2" class="btn btn-outline op-btn" @click="onRefund">申请退款</button>
            <button v-if="d.status === 2" class="btn btn-primary op-btn" @click="onConfirm">确认收货</button>
        </view>
    </view>
    <view v-else-if="!loading" class="container">
        <empty text="未找到该订单"></empty>
    </view>
    </view>
</template>

<script>
import { getOrderDetail, cancelOrder, confirmOrder, refundOrder } from '@/common/api.js'
import { priceText, orderStatusText, orderTagClass, imgUrl } from '@/common/util.js'

export default {
    data() {
        return {
            id: null,
            d: null,
            loading: true
        }
    },
    onLoad(query) {
        var that = this
        that.id = query.id
        that.load()
    },
    methods: {
        statusText(s) { return orderStatusText(s) },
        tagClass(s) { return orderTagClass(s) },
        load() {
            var that = this
            that.loading = true
            getOrderDetail(that.id).then(function (res) {
                res.priceText = priceText(res.totalAmount)
                var items = res.items || []
                for (var i = 0; i < items.length; i++) {
                    items[i].priceText = priceText(items[i].price)
                    items[i].imageUrl = imgUrl(items[i].mainImage, 'p' + items[i].productId)
                }
                that.d = res
                that.loading = false
            }).catch(function () {
                that.loading = false
            })
        },
        goProduct(id) {
            uni.navigateTo({ url: '/pages/product/detail?id=' + id })
        },
        goPay() {
            uni.navigateTo({ url: '/pages/order/pay?id=' + this.id })
        },
        goReview(it) {
            uni.navigateTo({
                url: '/pages/review/post?relType=product&relId=' + it.productId +
                    '&orderId=' + this.d.id + '&name=' + encodeURIComponent(it.productName)
            })
        },
        onCancel() {
            var that = this
            uni.showModal({
                title: '取消订单',
                content: '确定取消该订单吗？取消后不可恢复。',
                confirmText: '确定取消',
                cancelText: '再想想',
                success: function (r) {
                    if (!r.confirm) { return }
                    cancelOrder(that.id).then(function () {
                        uni.showToast({ title: '订单已取消', icon: 'success' })
                        that.load()
                    }).catch(function () { })
                }
            })
        },
        onConfirm() {
            var that = this
            uni.showModal({
                title: '确认收货',
                content: '请确认已收到商品，确认后订单将完成。',
                confirmText: '确认收货',
                cancelText: '再等等',
                success: function (r) {
                    if (!r.confirm) { return }
                    confirmOrder(that.id).then(function () {
                        uni.showToast({ title: '已确认收货', icon: 'success' })
                        that.load()
                    }).catch(function () { })
                }
            })
        },
        onRefund() {
            var that = this
            uni.showModal({
                title: '申请退款',
                content: '确定对该订单发起退款申请吗？提交后由商家处理。',
                confirmText: '申请退款',
                cancelText: '取消',
                success: function (r) {
                    if (!r.confirm) { return }
                    refundOrder(that.id, '用户申请退款').then(function () {
                        uni.showToast({ title: '已提交退款申请', icon: 'success' })
                        that.load()
                    }).catch(function () { })
                }
            })
        }
    }
}
</script>

<style scoped>
.status-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.status-amount {
    font-size: 40rpx;
}
.card-title {
    display: block;
    font-size: 30rpx;
    font-weight: 700;
    margin-bottom: 14rpx;
}
.d-row {
    display: flex;
    padding: 12rpx 0;
    font-size: 27rpx;
    border-bottom: 2rpx solid #F8F8F8;
}
.d-row:last-child {
    border-bottom: none;
}
.d-label {
    width: 160rpx;
    color: #999;
    flex-shrink: 0;
}
.d-value {
    flex: 1;
    word-break: break-all;
}
.item-row {
    display: flex;
    margin-bottom: 20rpx;
}
.item-img {
    width: 140rpx;
    height: 140rpx;
    border-radius: 12rpx;
    flex-shrink: 0;
    margin-right: 16rpx;
}
.item-body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.item-name {
    font-size: 27rpx;
}
.item-review {
    align-self: flex-end;
}
.timeline {
    padding-left: 8rpx;
}
.tl-item {
    display: flex;
    align-items: flex-start;
    padding: 12rpx 0;
}
.tl-dot {
    width: 18rpx;
    height: 18rpx;
    border-radius: 50%;
    background: #2E8B57;
    margin: 10rpx 20rpx 0 0;
    flex-shrink: 0;
}
.tl-info {
    display: flex;
    flex-direction: column;
    font-size: 27rpx;
}
.op-btn {
    width: 100%;
    margin-bottom: 16rpx;
}
.op-btn:last-child {
    margin-bottom: 0;
}
</style>

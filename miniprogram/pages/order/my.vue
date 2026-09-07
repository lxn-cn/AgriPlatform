<template>
    <view>
        <!-- 状态 tab -->
        <view class="tabs">
            <view
                v-for="t in tabs"
                :key="t.value"
                class="tab-item"
                :class="{ active: status === t.value }"
                @click="onTab(t.value)"
            >{{ t.label }}</view>
        </view>

        <view class="container">
            <!-- 订单卡片 -->
            <view class="card order-card" v-for="o in list" :key="o.id" @click="goDetail(o.id)">
                <view class="flex-between">
                    <text class="small gray">订单号：{{ o.orderNo }}</text>
                    <text class="tag" :class="tagClass(o.status)">{{ statusText(o.status) }}</text>
                </view>

                <!-- 商品缩略 -->
                <view class="item-row" v-for="(it, i) in o.items" :key="i">
                    <image class="item-img" :src="it.imageUrl" mode="aspectFill" />
                    <view class="item-body">
                        <text class="item-name ellipsis2">{{ it.productName }}</text>
                        <text v-if="it.spec" class="small gray">规格：{{ it.spec }}</text>
                        <view class="flex-between">
                            <text class="price">¥{{ it.priceText }}</text>
                            <text class="small gray">× {{ it.quantity }}</text>
                        </view>
                        <view class="item-review" v-if="o.status === 3">
                            <text class="small green" @click.stop="goReview(o, it)">评价该商品</text>
                        </view>
                    </view>
                </view>

                <view class="divider"></view>
                <view class="flex-between">
                    <text>合计：<text class="price">¥{{ o.priceText }}</text></text>
                    <view class="o-actions">
                        <button
                            v-if="o.status === 0"
                            class="btn btn-mini btn-mini-primary o-btn"
                            size="mini"
                            @click.stop="goPay(o)"
                        >去支付</button>
                        <button
                            v-if="o.status === 0"
                            class="btn btn-mini btn-mini-gray o-btn"
                            size="mini"
                            @click.stop="onCancel(o)"
                        >取消订单</button>
                        <button
                            v-if="o.status === 1 || o.status === 2"
                            class="btn btn-mini btn-mini-outline o-btn"
                            size="mini"
                            @click.stop="onRefund(o)"
                        >申请退款</button>
                        <button
                            v-if="o.status === 2"
                            class="btn btn-mini btn-mini-primary o-btn"
                            size="mini"
                            @click.stop="onConfirm(o)"
                        >确认收货</button>
                        <button
                            class="btn btn-mini btn-mini-gray o-btn"
                            size="mini"
                            @click.stop="goDetail(o.id)"
                        >查看详情</button>
                    </view>
                </view>
            </view>

            <empty v-if="!loading && list.length === 0" text="暂无订单" />
            <view v-if="finished && list.length > 0" class="load-tip">没有更多了</view>
        </view>
    </view>
</template>

<script>
import { getMyOrders, cancelOrder, confirmOrder, refundOrder } from '@/common/api.js'
import { priceText, orderStatusText, orderTagClass, parsePage, imgUrl } from '@/common/util.js'

export default {
    data() {
        return {
            tabs: [
                { label: '全部', value: '' },
                { label: '待付款', value: '0' },
                { label: '待发货', value: '1' },
                { label: '待收货', value: '2' },
                { label: '已完成', value: '3' }
            ],
            status: '',
            list: [],
            pageNum: 1,
            total: 0,
            loading: false,
            finished: false
        }
    },
    onLoad(query) {
        if (query.status !== undefined && query.status !== '') {
            this.status = String(query.status)
        }
        this.load(true)
    },
    onReachBottom() {
        if (!this.finished && !this.loading) {
            this.load(false)
        }
    },
    methods: {
        statusText(s) { return orderStatusText(s) },
        tagClass(s) { return orderTagClass(s) },
        load(reset) {
            var that = this
            if (reset) {
                that.pageNum = 1
                that.list = []
                that.finished = false
            } else {
                that.pageNum = that.pageNum + 1
            }
            that.loading = true
            var params = { pageNum: that.pageNum, pageSize: 10 }
            if (that.status !== '') { params.status = that.status }
            getMyOrders(params).then(function (res) {
                var page = parsePage(res)
                var rows = page.list.map(function (o) {
                    o.priceText = priceText(o.totalAmount)
                    var items = o.items || []
                    for (var i = 0; i < items.length; i++) {
                        items[i].priceText = priceText(items[i].price)
                        items[i].imageUrl = imgUrl(items[i].mainImage, 'p' + items[i].productId)
                    }
                    return o
                })
                that.list = reset ? rows : that.list.concat(rows)
                that.total = page.total
                if (that.list.length >= that.total || rows.length === 0) {
                    that.finished = true
                }
                that.loading = false
            }).catch(function () {
                that.loading = false
            })
        },
        onTab(v) {
            if (this.status === v) { return }
            this.status = v
            this.load(true)
        },
        goDetail(id) {
            uni.navigateTo({ url: '/pages/order/detail?id=' + id })
        },
        goPay(o) {
            uni.navigateTo({ url: '/pages/order/pay?id=' + o.id })
        },
        goReview(o, it) {
            uni.navigateTo({
                url: '/pages/review/post?relType=product&relId=' + it.productId +
                    '&orderId=' + o.id + '&name=' + encodeURIComponent(it.productName)
            })
        },
        onCancel(o) {
            var that = this
            uni.showModal({
                title: '取消订单',
                content: '确定取消该订单吗？取消后不可恢复。',
                confirmText: '确定取消',
                cancelText: '再想想',
                success: function (r) {
                    if (!r.confirm) { return }
                    cancelOrder(o.id).then(function () {
                        uni.showToast({ title: '订单已取消', icon: 'success' })
                        that.load(true)
                    }).catch(function () { })
                }
            })
        },
        onConfirm(o) {
            var that = this
            uni.showModal({
                title: '确认收货',
                content: '请确认已收到商品，确认后订单将完成。',
                confirmText: '确认收货',
                cancelText: '再等等',
                success: function (r) {
                    if (!r.confirm) { return }
                    confirmOrder(o.id).then(function () {
                        uni.showToast({ title: '已确认收货', icon: 'success' })
                        that.load(true)
                    }).catch(function () { })
                }
            })
        },
        onRefund(o) {
            var that = this
            uni.showModal({
                title: '申请退款',
                content: '确定对该订单发起退款申请吗？提交后由商家处理。',
                confirmText: '申请退款',
                cancelText: '取消',
                success: function (r) {
                    if (!r.confirm) { return }
                    refundOrder(o.id, '用户申请退款').then(function () {
                        uni.showToast({ title: '已提交退款申请', icon: 'success' })
                        that.load(true)
                    }).catch(function () { })
                }
            })
        }
    }
}
</script>

<style scoped>
.item-row {
    display: flex;
    margin: 20rpx 0;
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
.o-actions {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    justify-content: flex-end;
}
.o-btn {
    margin-left: 14rpx;
    margin-top: 6rpx;
}
.load-tip {
    text-align: center;
    color: #999;
    font-size: 24rpx;
    padding: 20rpx 0;
}
</style>

<template>
    <view class="container">
        <view class="pay-head card">
            <text class="pay-title">模拟支付</text>
            <text class="small gray">课程设计环境为模拟支付，不产生真实资金往来</text>
        </view>

        <view class="card" v-if="d">
            <view class="pay-amount">
                <text class="pay-amount-num">¥{{ d.priceText }}</text>
                <text class="small gray">待支付金额</text>
            </view>
            <view class="divider"></view>
            <view class="pay-row"><text class="gray">订单类型</text><text>农特产商城订单</text></view>
            <view class="pay-row"><text class="gray">订单号</text><text>{{ d.orderNo }}</text></view>
            <view class="pay-row">
                <text class="gray">支付方式</text>
                <text>模拟支付（演示）</text>
            </view>
        </view>

        <!-- 商品摘要 -->
        <view class="card" v-if="d && d.items && d.items.length">
            <view class="item-row" v-for="(it, i) in d.items" :key="i">
                <image class="item-img" :src="it.imageUrl" mode="aspectFill" />
                <view class="item-body">
                    <text class="item-name ellipsis2">{{ it.productName }}</text>
                    <text v-if="it.spec" class="small gray">规格：{{ it.spec }}</text>
                    <view class="flex-between">
                        <text class="price">¥{{ it.priceText }}</text>
                        <text class="small gray">× {{ it.quantity }}</text>
                    </view>
                </view>
            </view>
        </view>
        <empty v-if="!loading && !d" text="未找到订单信息" />

        <button
            v-if="d && d.status === 0"
            class="btn btn-primary pay-btn"
            :disabled="paying"
            @click="doPay"
        >{{ paying ? '支付中...' : '确认支付（模拟）' }}</button>
        <view v-if="d && d.status !== 0" class="paid-tip">
            <text class="small gray">该订单当前状态：{{ statusText(d.status) }}，无需支付</text>
        </view>
    </view>
</template>

<script>
import { getOrderDetail, payOrder } from '@/common/api.js'
import { priceText, orderStatusText, imgUrl } from '@/common/util.js'

export default {
    data() {
        return {
            id: null,
            d: null,
            loading: true,
            paying: false
        }
    },
    onLoad(query) {
        var that = this
        that.id = query.id
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
    methods: {
        statusText(s) { return orderStatusText(s) },
        doPay() {
            var that = this
            if (that.paying) { return }
            that.paying = true
            payOrder(that.id).then(function () {
                that.paying = false
                uni.showToast({ title: '支付成功', icon: 'success' })
                setTimeout(function () {
                    uni.redirectTo({ url: '/pages/order/my?status=1' })
                }, 900)
            }).catch(function () {
                that.paying = false
            })
        }
    }
}
</script>

<style scoped>
.pay-head {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
}
.pay-title {
    font-size: 34rpx;
    font-weight: 700;
    margin-bottom: 8rpx;
}
.pay-amount {
    text-align: center;
    padding: 20rpx 0 30rpx;
    display: flex;
    flex-direction: column;
}
.pay-amount-num {
    font-size: 64rpx;
    font-weight: 700;
    color: #FF5722;
    margin-bottom: 8rpx;
}
.pay-row {
    display: flex;
    justify-content: space-between;
    font-size: 26rpx;
    padding: 14rpx 0;
}
.item-row {
    display: flex;
    margin-bottom: 20rpx;
}
.item-img {
    width: 130rpx;
    height: 130rpx;
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
.pay-btn {
    margin-top: 40rpx;
    width: 100%;
}
.paid-tip {
    text-align: center;
    padding: 30rpx 0;
}
</style>

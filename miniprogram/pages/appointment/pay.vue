<template>
    <view class="container">
        <view class="pay-head card">
            <text class="pay-title">模拟支付</text>
            <text class="small gray">课程设计环境为模拟支付，不产生真实资金往来</text>
        </view>

        <view class="card" v-if="detail">
            <view class="pay-amount">
                <text class="pay-amount-num">¥{{ detail.priceText }}</text>
                <text class="small gray">待支付金额</text>
            </view>
            <view class="divider"></view>
            <view class="pay-row"><text class="gray">订单类型</text><text>采摘预约单</text></view>
            <view class="pay-row"><text class="gray">预约编号</text><text>{{ detail.appointmentNo || detail.id }}</text></view>
            <view class="pay-row"><text class="gray">农园</text><text>{{ detail.farmName || '农园' }}</text></view>
            <view class="pay-row"><text class="gray">采摘项目</text><text>{{ detail.projectName || '采摘项目' }}</text></view>
            <view class="pay-row"><text class="gray">预约时间</text><text>{{ detail.appointDate }} {{ detail.session }}</text></view>
            <view class="pay-row"><text class="gray">人数</text><text>{{ detail.peopleCount }} 人</text></view>
            <view class="pay-row"><text class="gray">联系手机号</text><text>{{ detail.contactPhone }}</text></view>
            <view class="pay-row">
                <text class="gray">支付方式</text>
                <text>模拟支付（演示）</text>
            </view>
        </view>
        <empty v-if="!loading && !detail" text="未找到预约单信息" />

        <button
            v-if="detail && detail.status === 0"
            class="btn btn-primary pay-btn"
            :disabled="paying"
            @click="doPay"
        >{{ paying ? '支付中...' : '确认支付（模拟）' }}</button>
        <view v-if="detail && detail.status !== 0" class="paid-tip">
            <text class="small gray">该预约单当前状态：{{ statusText(detail.status) }}，无需支付</text>
        </view>
    </view>
</template>

<script>
import { getAppointmentDetail, payAppointment } from '@/common/api.js'
import { priceText, appointStatusText } from '@/common/util.js'

export default {
    data() {
        return {
            id: null,
            detail: null,
            loading: true,
            paying: false
        }
    },
    onLoad(query) {
        var that = this
        that.id = query.id
        getAppointmentDetail(that.id).then(function (res) {
            res.priceText = priceText(res.amount)
            that.detail = res
            that.loading = false
        }).catch(function () {
            that.loading = false
        })
    },
    methods: {
        statusText(s) {
            return appointStatusText(s)
        },
        doPay() {
            var that = this
            if (that.paying) { return }
            that.paying = true
            payAppointment(that.id).then(function () {
                that.paying = false
                uni.showToast({ title: '支付成功', icon: 'success' })
                setTimeout(function () {
                    uni.redirectTo({ url: '/pages/appointment/my?status=1' })
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
.pay-btn {
    margin-top: 40rpx;
    width: 100%;
}
.paid-tip {
    text-align: center;
    padding: 30rpx 0;
}
</style>

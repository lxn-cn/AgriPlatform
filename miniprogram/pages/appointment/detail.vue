<template>
    <view class="container" v-if="d">
        <!-- 状态卡 -->
        <view class="card status-card">
            <text class="tag" :class="tagClass(d.status)">{{ statusText(d.status) }}</text>
            <text class="status-amount price">¥{{ d.priceText }}</text>
        </view>

        <!-- 预约信息 -->
        <view class="card">
            <text class="card-title">预约信息</text>
            <view class="d-row"><text class="d-label">预约编号</text><text>{{ d.appointmentNo || d.id }}</text></view>
            <view class="d-row"><text class="d-label">农园</text><text>{{ d.farmName || '农园' }}</text></view>
            <view class="d-row"><text class="d-label">采摘项目</text><text>{{ d.projectName || '采摘项目' }}</text></view>
            <view class="d-row"><text class="d-label">预约日期</text><text>{{ d.appointDate }}</text></view>
            <view class="d-row"><text class="d-label">预约场次</text><text>{{ d.session }}</text></view>
            <view class="d-row"><text class="d-label">人数</text><text>{{ d.peopleCount }} 人</text></view>
            <view class="d-row"><text class="d-label">预约人</text><text>{{ d.contactName }}</text></view>
            <view class="d-row">
                <text class="d-label">联系手机号</text>
                <text>{{ d.contactPhone }}（到场报手机号确认）</text>
            </view>
            <view class="d-row"><text class="d-label">下单时间</text><text>{{ d.createTime || '-' }}</text></view>
            <view class="d-row" v-if="d.payTime"><text class="d-label">支付时间</text><text>{{ d.payTime }}</text></view>
            <view class="d-row" v-if="d.confirmTime"><text class="d-label">到园确认</text><text>{{ d.confirmTime }}</text></view>
            <view class="d-row" v-if="d.cancelTime"><text class="d-label">取消时间</text><text>{{ d.cancelTime }}</text></view>
        </view>

        <!-- 操作 -->
        <view class="card">
            <button
                v-if="d.status === 0"
                class="btn btn-primary op-btn"
                @click="goPay"
            >去支付</button>
            <button
                v-if="d.status === 1 && canCancel(d)"
                class="btn btn-outline op-btn"
                @click="onCancel"
            >取消预约（需在预约日期前一天24:00前）</button>
            <button
                v-if="d.status === 2"
                class="btn btn-primary op-btn"
                @click="goReview"
            >去评价</button>
            <text v-if="d.status === 1 && !canCancel(d)" class="small gray center-tip">
                已过取消期限（需在预约日期前一天的 24:00 前取消），如需帮助请联系农园
            </text>
        </view>
    </view>
    <view v-else-if="!loading" class="container">
        <empty text="未找到预约单"></empty>
    </view>
</template>

<script>
import { getAppointmentDetail, cancelAppointment } from '@/common/api.js'
import { priceText, appointStatusText, appointTagClass, canCancelAppointment } from '@/common/util.js'

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
        getAppointmentDetail(that.id).then(function (res) {
            res.priceText = priceText(res.amount)
            that.d = res
            that.loading = false
        }).catch(function () {
            that.loading = false
        })
    },
    methods: {
        statusText(s) { return appointStatusText(s) },
        tagClass(s) { return appointTagClass(s) },
        canCancel(a) { return canCancelAppointment(a) },
        goPay() {
            uni.navigateTo({ url: '/pages/appointment/pay?id=' + this.id })
        },
        goReview() {
            uni.navigateTo({
                url: '/pages/review/post?relType=farm&relId=' + this.d.farmId +
                    '&appointmentId=' + this.d.id + '&name=' + encodeURIComponent(this.d.farmName || '农园')
            })
        },
        onCancel() {
            var that = this
            uni.showModal({
                title: '取消预约',
                content: '确定取消该预约吗？取消后不可恢复。',
                confirmText: '确定取消',
                cancelText: '再想想',
                success: function (r) {
                    if (!r.confirm) { return }
                    cancelAppointment(that.id).then(function () {
                        uni.showToast({ title: '已取消预约', icon: 'success' })
                        setTimeout(function () {
                            uni.redirectTo({ url: '/pages/appointment/my?status=' + that.d.status })
                        }, 800)
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
    width: 180rpx;
    color: #999;
    flex-shrink: 0;
}
.op-btn {
    width: 100%;
    margin-bottom: 16rpx;
}
.op-btn:last-child {
    margin-bottom: 0;
}
.center-tip {
    display: block;
    text-align: center;
    line-height: 1.6;
}
</style>

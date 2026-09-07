<template>
    <view class="container">
        <!-- 评价对象 -->
        <view class="card">
            <text class="small gray">评价对象</text>
            <text class="bold target-name">{{ name }}</text>
            <text class="small gray target-type">{{ typeText }}</text>
        </view>

        <!-- 星级评分 -->
        <view class="card">
            <view class="flex-between rate-head">
                <text class="bold">总体评分</text>
                <text class="rate-text">{{ rating }}.0 分</text>
            </view>
            <view class="rate-stars">
                <star-rate :value="rating" :size="56" @change="onRate"></star-rate>
            </view>
            <view class="rate-labels">
                <text v-for="(lb, i) in rateLabels" :key="i" class="small gray">{{ lb }}</text>
            </view>
        </view>

        <!-- 文字内容 -->
        <view class="card">
            <textarea
                v-model="content"
                class="content-input"
                placeholder="说说您的体验感受吧（至少 5 个字）"
                maxlength="500"
                :auto-height="false"
            ></textarea>
            <view class="flex-between">
                <text class="small gray">评价提交后无法修改</text>
                <text class="small gray">{{ content.length }}/500</text>
            </view>
        </view>

        <button class="btn btn-primary submit-btn" :disabled="submitting" @click="submit">
            {{ submitting ? '提交中...' : '提交评价' }}
        </button>
    </view>
</template>

<script>
import { postReview } from '@/common/api.js'
import { requireLogin } from '@/common/util.js'

export default {
    data() {
        return {
            relType: 'product',
            relId: null,
            appointmentId: null,
            orderId: null,
            name: '',
            rating: 5,
            content: '',
            submitting: false,
            rateLabels: ['很差', '较差', '一般', '满意', '非常满意']
        }
    },
    computed: {
        typeText() {
            return this.relType === 'farm' ? '农园采摘体验评价' : '商品评价'
        }
    },
    onLoad(query) {
        this.relType = query.relType || 'product'
        this.relId = query.relId
        this.appointmentId = query.appointmentId || null
        this.orderId = query.orderId || null
        this.name = query.name ? decodeURIComponent(query.name) : ''
    },
    methods: {
        onRate(v) {
            this.rating = v
        },
        submit() {
            var that = this
            if (!requireLogin()) { return }
            if (!that.relId) {
                uni.showToast({ title: '缺少评价对象', icon: 'none' })
                return
            }
            if (!that.content || that.content.trim().length < 5) {
                uni.showToast({ title: '评价内容至少 5 个字', icon: 'none' })
                return
            }
            var data = {
                relType: that.relType,
                relId: that.relId,
                rating: that.rating,
                content: that.content.trim()
            }
            if (that.appointmentId) { data.appointmentId = that.appointmentId }
            if (that.orderId) { data.orderId = that.orderId }
            that.submitting = true
            postReview(data).then(function () {
                that.submitting = false
                uni.showToast({ title: '评价成功，感谢反馈', icon: 'success' })
                setTimeout(function () {
                    uni.navigateBack()
                }, 900)
            }).catch(function () {
                that.submitting = false
            })
        }
    }
}
</script>

<style scoped>
.target-name {
    display: block;
    margin: 10rpx 0 4rpx;
    font-size: 32rpx;
}
.target-type {
    display: block;
}
.rate-head {
    margin-bottom: 20rpx;
}
.rate-text {
    color: #FFB800;
    font-weight: 700;
}
.rate-stars {
    display: flex;
    justify-content: center;
    padding: 10rpx 0 20rpx;
}
.rate-labels {
    display: flex;
    justify-content: space-between;
}
.content-input {
    width: 100%;
    height: 240rpx;
    font-size: 28rpx;
    line-height: 1.6;
    margin-bottom: 16rpx;
}
.submit-btn {
    margin-top: 30rpx;
    width: 100%;
}
</style>

<template>
    <view class="container">
        <view class="card">
            <text class="card-title">意见内容</text>
            <textarea
                v-model="content"
                class="fb-input"
                placeholder="欢迎您提出宝贵的意见或建议（10-500字）"
                maxlength="500"
            ></textarea>
            <view class="flex-between">
                <text class="small gray">您的反馈将帮助我们持续改进</text>
                <text class="small gray">{{ content.length }}/500</text>
            </view>
        </view>

        <view class="card">
            <view class="form-item no-border">
                <text class="form-label">联系方式</text>
                <input class="form-input" v-model="contact" placeholder="手机号或邮箱（选填，便于我们回复您）" maxlength="30" />
            </view>
        </view>

        <button class="btn btn-primary submit-btn" :disabled="submitting" @click="submit">
            {{ submitting ? '提交中...' : '提交反馈' }}
        </button>
    </view>
</template>

<script>
import { postFeedback } from '@/common/api.js'
import { requireLogin } from '@/common/util.js'

export default {
    data() {
        return {
            content: '',
            contact: '',
            submitting: false
        }
    },
    methods: {
        submit() {
            var that = this
            if (!requireLogin()) { return }
            if (!that.content || that.content.trim().length < 10) {
                uni.showToast({ title: '反馈内容至少 10 个字', icon: 'none' })
                return
            }
            that.submitting = true
            postFeedback({
                content: that.content.trim(),
                contact: that.contact.trim()
            }).then(function () {
                that.submitting = false
                uni.showToast({ title: '提交成功，感谢反馈', icon: 'success' })
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
.card-title {
    display: block;
    font-size: 30rpx;
    font-weight: 700;
    margin-bottom: 16rpx;
}
.fb-input {
    width: 100%;
    height: 280rpx;
    font-size: 28rpx;
    line-height: 1.6;
    margin-bottom: 16rpx;
}
.no-border {
    border-bottom: none;
}
.submit-btn {
    margin-top: 30rpx;
    width: 100%;
}
</style>

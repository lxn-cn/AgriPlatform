<template>
    <view class="login-page">
        <!-- 品牌区 -->
        <view class="brand">
            <view class="brand-logo">津</view>
            <text class="brand-name">天津地方农特产推广服务平台</text>
            <text class="brand-sub">买农特产 · 摘当季鲜果 · 逛有机农场</text>
        </view>

        <!-- 登录区 -->
        <view class="login-box card">
            <text class="login-tip">登录后可下单购买农特产、预约采摘体验</text>
            <view class="form-item">
                <text class="form-label">昵称</text>
                <input class="form-input" v-model="nickname" placeholder="请输入昵称（不填则自动生成）" maxlength="20" />
            </view>
            <button class="btn btn-primary login-btn" :disabled="submitting" @click="wxLogin">
                {{ submitting ? '登录中...' : '微信一键登录（演示）' }}
            </button>
            <view class="guest-entry" @click="guestBrowse">暂不登录，先逛逛</view>
            <text class="agree-tip">登录即代表同意平台相关服务条款</text>
        </view>
    </view>
</template>

<script>
import { wxLogin } from '@/common/api.js'

export default {
    data() {
        return {
            nickname: '',
            submitting: false
        }
    },
    methods: {
        wxLogin() {
            var that = this
            if (that.submitting) { return }
            that.submitting = true
            // 调用 uni.login 获取 code；失败（如开发者工具环境异常）则用随机数模拟
            uni.login({
                provider: 'weixin',
                success: function (res) {
                    that.doLogin(res.code || ('mock' + Date.now()))
                },
                fail: function () {
                    that.doLogin('mock' + Date.now())
                }
            })
        },
        doLogin(code) {
            var that = this
            var data = { code: code }
            if (that.nickname && that.nickname.trim()) {
                data.nickname = that.nickname.trim()
            }
            wxLogin(data.code, data.nickname).then(function (res) {
                that.submitting = false
                var token = res.token || (res.userInfo && res.userInfo.token)
                if (!token) {
                    uni.showToast({ title: '登录失败：未返回 token', icon: 'none' })
                    return
                }
                uni.setStorageSync('token', token)
                uni.setStorageSync('userInfo', res.userInfo || {})
                uni.showToast({ title: '登录成功', icon: 'success' })
                setTimeout(function () {
                    uni.reLaunch({ url: '/pages/index/index' })
                }, 800)
            }).catch(function () {
                that.submitting = false
            })
        },
        guestBrowse() {
            // 游客浏览：不登录直接回首页
            uni.reLaunch({ url: '/pages/index/index' })
        }
    }
}
</script>

<style scoped>
.login-page {
    padding: 120rpx 40rpx 40rpx;
}
.brand {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 80rpx;
}
.brand-logo {
    width: 160rpx;
    height: 160rpx;
    border-radius: 40rpx;
    background: #2E8B57;
    color: #fff;
    font-size: 88rpx;
    font-weight: bold;
    text-align: center;
    line-height: 160rpx;
    margin-bottom: 30rpx;
}
.brand-name {
    font-size: 36rpx;
    font-weight: 700;
    margin-bottom: 12rpx;
}
.brand-sub {
    font-size: 26rpx;
    color: #999;
}
.login-box {
    padding: 40rpx;
}
.login-tip {
    display: block;
    font-size: 26rpx;
    color: #666;
    margin-bottom: 20rpx;
}
.login-btn {
    margin-top: 40rpx;
    width: 100%;
}
.guest-entry {
    text-align: center;
    color: #2E8B57;
    font-size: 28rpx;
    margin-top: 36rpx;
}
.agree-tip {
    display: block;
    text-align: center;
    color: #BBB;
    font-size: 22rpx;
    margin-top: 30rpx;
}
</style>

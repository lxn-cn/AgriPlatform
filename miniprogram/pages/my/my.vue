<template>
    <view class="my-page page-tab">
        <!-- 用户信息卡 -->
        <view class="user-card" @click="onUserCard">
            <view class="avatar">{{ logged ? avatarChar : '客' }}</view>
            <view class="user-info">
                <text class="user-name">{{ logged ? (userInfo.nickname || '用户') : '点击登录' }}</text>
                <text class="user-sub">{{ logged ? (userInfo.phone || '未绑定手机号') : '游客可浏览，登录后可下单预约' }}</text>
            </view>
            <text v-if="!logged" class="login-arrow">&gt;</text>
        </view>

        <!-- 我的订单九宫格 -->
        <view class="card">
            <view class="flex-between card-head" @click="goOrders('')">
                <text class="bold">我的订单</text>
                <text class="small gray">全部订单 &gt;</text>
            </view>
            <view class="order-grid">
                <view class="grid-item" v-for="g in orderEntries" :key="g.status" @click="goOrders(g.status)">
                    <view class="grid-icon">{{ g.icon }}</view>
                    <text class="grid-name">{{ g.label }}</text>
                </view>
            </view>
        </view>

        <!-- 功能菜单 -->
        <view class="card">
            <view class="menu-item" v-for="m in menus" :key="m.label" @click="goMenu(m)">
                <text class="menu-icon">{{ m.icon }}</text>
                <text class="menu-label">{{ m.label }}</text>
                <text class="menu-arrow">&gt;</text>
            </view>
        </view>

        <!-- 退出登录 -->
        <view class="card" v-if="logged">
            <view class="logout-btn" @click="logout">退出登录</view>
        </view>

        <tab-bar current="my"></tab-bar>
    </view>
</template>

<script>
import { getUserMe } from '@/common/api.js'
import { isLoggedIn, requireLogin, imgUrl } from '@/common/util.js'

export default {
    data() {
        return {
            logged: false,
            userInfo: {},
            orderEntries: [
                { label: '待付款', status: '0', icon: '付' },
                { label: '待发货', status: '1', icon: '发' },
                { label: '待收货', status: '2', icon: '收' },
                { label: '已完成', status: '3', icon: '完' }
            ],
            menus: [
                { label: '我的预约', icon: '预', url: '/pages/appointment/my', login: true },
                { label: '我的收藏', icon: '藏', url: '/pages/favorite/my', login: true },
                { label: '收货地址', icon: '址', url: '/pages/address/list', login: true },
                { label: '意见反馈', icon: '馈', url: '/pages/feedback/post', login: true },
                { label: '帮助中心', icon: '助', url: '/pages/help/help', login: false }
            ]
        }
    },
    computed: {
        avatarChar() {
            var n = this.userInfo.nickname || '用'
            return n.substring(0, 1)
        }
    },
    onShow() {
        var that = this
        that.logged = isLoggedIn()
        if (that.logged) {
            that.userInfo = uni.getStorageSync('userInfo') || {}
            getUserMe().then(function (res) {
                that.userInfo = res || {}
                uni.setStorageSync('userInfo', res || {})
            }).catch(function () { })
        } else {
            that.userInfo = {}
        }
    },
    methods: {
        onUserCard() {
            if (!this.logged) {
                uni.navigateTo({ url: '/pages/login/login' })
            }
        },
        goOrders(status) {
            if (!requireLogin()) { return }
            var url = '/pages/order/my'
            if (status !== '') { url += '?status=' + status }
            uni.navigateTo({ url: url })
        },
        goMenu(m) {
            if (m.login && !requireLogin()) { return }
            uni.navigateTo({ url: m.url })
        },
        logout() {
            var that = this
            uni.showModal({
                title: '退出登录',
                content: '确定退出当前账号吗？',
                confirmText: '退出',
                cancelText: '取消',
                success: function (r) {
                    if (!r.confirm) { return }
                    uni.removeStorageSync('token')
                    uni.removeStorageSync('userInfo')
                    uni.removeStorageSync('confirmAddressId')
                    that.logged = false
                    that.userInfo = {}
                    uni.showToast({ title: '已退出登录', icon: 'none' })
                }
            })
        }
    }
}
</script>

<style scoped>
.user-card {
    background: #2E8B57;
    padding: 60rpx 40rpx 50rpx;
    display: flex;
    align-items: center;
}
.avatar {
    width: 130rpx;
    height: 130rpx;
    border-radius: 50%;
    background: #fff;
    color: #2E8B57;
    font-size: 52rpx;
    font-weight: bold;
    text-align: center;
    line-height: 130rpx;
    margin-right: 26rpx;
}
.user-info {
    flex: 1;
    display: flex;
    flex-direction: column;
}
.user-name {
    color: #fff;
    font-size: 36rpx;
    font-weight: 700;
    margin-bottom: 10rpx;
}
.user-sub {
    color: rgba(255, 255, 255, 0.85);
    font-size: 24rpx;
}
.login-arrow {
    color: #fff;
    font-size: 40rpx;
}
.card-head {
    margin-bottom: 20rpx;
}
.order-grid {
    display: flex;
}
.grid-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
}
.grid-icon {
    width: 80rpx;
    height: 80rpx;
    border-radius: 50%;
    background: #E8F5EE;
    color: #2E8B57;
    font-size: 30rpx;
    font-weight: bold;
    text-align: center;
    line-height: 80rpx;
    margin-bottom: 12rpx;
}
.grid-name {
    font-size: 24rpx;
    color: #555;
}
.menu-item {
    display: flex;
    align-items: center;
    padding: 26rpx 0;
    border-bottom: 2rpx solid #F5F5F5;
}
.menu-item:last-child {
    border-bottom: none;
}
.menu-icon {
    width: 60rpx;
    height: 60rpx;
    border-radius: 14rpx;
    background: #E8F5EE;
    color: #2E8B57;
    font-size: 26rpx;
    text-align: center;
    line-height: 60rpx;
    margin-right: 20rpx;
}
.menu-label {
    flex: 1;
    font-size: 28rpx;
}
.menu-arrow {
    color: #CCC;
    font-size: 30rpx;
}
.logout-btn {
    text-align: center;
    color: #E53935;
    font-size: 28rpx;
    padding: 10rpx 0;
}
</style>

<template>
    <view class="tabbar">
        <view
            v-for="item in tabs"
            :key="item.key"
            class="tabbar-item"
            :class="{ active: current === item.key }"
            @click="go(item)"
        >
            <view class="tabbar-icon">{{ item.icon }}</view>
            <text class="tabbar-txt">{{ item.text }}</text>
        </view>
    </view>
</template>

<script>
// 自定义底部导航（不使用原生 tabBar，避免 iconPath 必须为图片资源的问题）
// 页面中使用：<tab-bar current="index"></tab-bar>，current 取 index/farm/shop/my
export default {
    name: 'tab-bar',
    props: {
        current: {
            type: String,
            default: 'index'
        }
    },
    data() {
        return {
            tabs: [
                { key: 'index', text: '首页', icon: '首', url: '/pages/index/index' },
                { key: 'farm', text: '农园', icon: '园', url: '/pages/farm/list' },
                { key: 'shop', text: '商城', icon: '购', url: '/pages/product/list' },
                { key: 'my', text: '我的', icon: '我', url: '/pages/my/my' }
            ]
        }
    },
    methods: {
        go(item) {
            if (item.key === this.current) { return }
            // redirectTo 保持页面栈深度不变，避免频繁切换导致栈溢出
            uni.redirectTo({ url: item.url })
        }
    }
}
</script>

<style scoped>
.tabbar {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    height: 110rpx;
    background: #fff;
    display: flex;
    border-top: 2rpx solid #EFEFEF;
    padding-bottom: env(safe-area-inset-bottom);
    z-index: 999;
}
.tabbar-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}
.tabbar-icon {
    width: 52rpx;
    height: 52rpx;
    border-radius: 12rpx;
    background: #EEE;
    color: #999;
    font-size: 26rpx;
    text-align: center;
    line-height: 52rpx;
    margin-bottom: 4rpx;
}
.tabbar-txt {
    font-size: 22rpx;
    color: #999;
}
.tabbar-item.active .tabbar-icon {
    background: #2E8B57;
    color: #fff;
}
.tabbar-item.active .tabbar-txt {
    color: #2E8B57;
    font-weight: 700;
}
</style>

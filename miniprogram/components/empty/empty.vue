<template>
    <view class="empty">
        <view class="empty-icon">空</view>
        <text>{{ text }}</text>
    </view>
</template>

<script>
// 空状态占位：<empty text="暂无数据"></empty>
export default {
    name: 'empty',
    props: {
        text: { type: String, default: '暂无数据' }
    }
}
</script>

<style scoped>
.empty {
    padding: 90rpx 0;
    text-align: center;
    color: #999;
    font-size: 26rpx;
}
.empty-icon {
    width: 120rpx;
    height: 120rpx;
    border-radius: 50%;
    background: #E8F5EE;
    color: #2E8B57;
    line-height: 120rpx;
    margin: 0 auto 20rpx;
    font-size: 48rpx;
    font-weight: bold;
}
</style>

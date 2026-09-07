<script>
export default {
    onLaunch: function () {
        console.log('App Launch')
    },
    onShow: function () {
        console.log('App Show')
    },
    onHide: function () {
        console.log('App Hide')
    }
}
</script>

<style>
/* 全局公共样式（App.vue 中不使用 scoped，保证全局生效） */
page {
    background-color: #F5F6F2;
    color: #333;
    font-size: 28rpx;
}

/* 布局 */
.container {
    padding: 20rpx 24rpx 40rpx;
}
/* 有自定义底部导航的页面需留出导航高度 */
.page-tab {
    padding-bottom: 140rpx;
}
.flex {
    display: flex;
    align-items: center;
}
.flex-between {
    display: flex;
    align-items: center;
    justify-content: space-between;
}

/* 卡片 */
.card {
    background: #fff;
    border-radius: 16rpx;
    padding: 24rpx;
    margin-bottom: 20rpx;
}

/* 区块标题 */
.section-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 28rpx 0 16rpx;
}
.section-title {
    font-size: 32rpx;
    font-weight: 700;
}
.section-more {
    color: #999;
    font-size: 24rpx;
}

/* 价格 */
.price {
    color: #FF5722;
    font-weight: 700;
}

/* 标签 */
.tag {
    display: inline-block;
    font-size: 22rpx;
    padding: 2rpx 14rpx;
    border-radius: 8rpx;
    margin-right: 10rpx;
}
.tag-green { color: #2E8B57; background: #E8F5EE; }
.tag-blue { color: #1E88E5; background: #E3F2FD; }
.tag-orange { color: #FF8C00; background: #FFF3E0; }
.tag-red { color: #E53935; background: #FFEBEE; }
.tag-gray { color: #888; background: #F2F2F2; }

/* 按钮 */
.btn {
    text-align: center;
    border-radius: 44rpx;
    font-size: 30rpx;
}
.btn-primary {
    background: #2E8B57;
    color: #fff;
    height: 84rpx;
    line-height: 84rpx;
}
.btn-outline {
    border: 2rpx solid #2E8B57;
    color: #2E8B57;
    background: #fff;
    height: 84rpx;
    line-height: 80rpx;
}
.btn-mini {
    display: inline-block;
    font-size: 24rpx;
    padding: 0 26rpx;
    height: 56rpx;
    line-height: 56rpx;
    border-radius: 28rpx;
}
.btn-mini-primary {
    background: #2E8B57;
    color: #fff;
}
.btn-mini-outline {
    border: 2rpx solid #2E8B57;
    color: #2E8B57;
    background: #fff;
}
.btn-mini-gray {
    border: 2rpx solid #ddd;
    color: #999;
    background: #fff;
}
.btn-disabled {
    opacity: 0.5;
}

/* 筛选 chips */
.chip {
    display: inline-block;
    font-size: 24rpx;
    color: #666;
    background: #fff;
    border: 2rpx solid #E5E5E5;
    border-radius: 28rpx;
    padding: 6rpx 24rpx;
    margin-right: 16rpx;
}
.chip.active {
    color: #fff;
    background: #2E8B57;
    border-color: #2E8B57;
}

/* 空状态 */
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

/* 文本 */
.gray { color: #999; }
.small { font-size: 24rpx; }
.bold { font-weight: 700; }
.green { color: #2E8B57; }
.ellipsis {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.ellipsis2 {
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}
.divider {
    height: 2rpx;
    background: #F0F0F0;
    margin: 16rpx 0;
}

/* 表单 */
.form-item {
    display: flex;
    align-items: center;
    padding: 24rpx 0;
    border-bottom: 2rpx solid #F5F5F5;
}
.form-label {
    width: 180rpx;
    color: #666;
    font-size: 28rpx;
}
.form-input {
    flex: 1;
    font-size: 28rpx;
}

/* 状态条（tab 选项卡） */
.tabs {
    display: flex;
    background: #fff;
    padding: 0 10rpx;
}
.tab-item {
    flex: 1;
    text-align: center;
    height: 88rpx;
    line-height: 88rpx;
    font-size: 28rpx;
    color: #666;
    position: relative;
}
.tab-item.active {
    color: #2E8B57;
    font-weight: 700;
}
.tab-item.active::after {
    content: '';
    position: absolute;
    left: 50%;
    bottom: 8rpx;
    transform: translateX(-50%);
    width: 48rpx;
    height: 6rpx;
    border-radius: 3rpx;
    background: #2E8B57;
}
</style>

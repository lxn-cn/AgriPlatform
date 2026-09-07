<template>
    <view class="container addr-page">
        <view
            class="card addr-item"
            v-for="a in list"
            :key="a.id"
            @click="onSelect(a)"
        >
            <view class="addr-top">
                <text class="bold">{{ a.receiver }}</text>
                <text class="small gray">{{ a.phone }}</text>
                <text v-if="a.isDefault" class="tag tag-green default-tag">默认</text>
            </view>
            <text class="addr-detail">{{ a.district }} {{ a.detail }}</text>
            <view class="addr-actions" v-if="!selectMode">
                <text class="small green" @click.stop="onSetDefault(a)">设为默认</text>
                <text class="small gray" @click.stop="onEdit(a)">编辑</text>
                <text class="small red" @click.stop="onDelete(a)">删除</text>
            </view>
            <view class="addr-actions select-hint" v-else>
                <text class="small green">点击选择该地址</text>
            </view>
        </view>

        <empty v-if="!loading && list.length === 0" text="暂无收货地址，快去新增一个吧"></empty>

        <view class="add-bar" v-if="!selectMode">
            <button class="btn btn-primary" @click="onAdd">新增收货地址</button>
        </view>
    </view>
</template>

<script>
import { getAddresses, setDefaultAddress, deleteAddress } from '@/common/api.js'
import { requireLogin } from '@/common/util.js'

export default {
    data() {
        return {
            list: [],
            loading: false,
            selectMode: false // 选择模式：供订单确认页选地址
        }
    },
    onLoad(query) {
        if (query.select === '1') {
            this.selectMode = true
        }
    },
    onShow() {
        this.load()
    },
    methods: {
        load() {
            var that = this
            that.loading = true
            getAddresses().then(function (res) {
                var rows = res && res.list ? res.list : (res || [])
                that.list = rows
                that.loading = false
            }).catch(function () {
                that.loading = false
            })
        },
        onSelect(a) {
            if (!this.selectMode) { return }
            uni.setStorageSync('confirmAddressId', a.id)
            uni.navigateBack()
        },
        onSetDefault(a) {
            var that = this
            if (a.isDefault) { return }
            setDefaultAddress(a.id).then(function () {
                uni.showToast({ title: '已设为默认地址', icon: 'success' })
                that.load()
            }).catch(function () { })
        },
        onEdit(a) {
            uni.navigateTo({ url: '/pages/address/edit?id=' + a.id })
        },
        onAdd() {
            if (!requireLogin()) { return }
            uni.navigateTo({ url: '/pages/address/edit' })
        },
        onDelete(a) {
            var that = this
            uni.showModal({
                title: '删除地址',
                content: '确定删除该收货地址吗？',
                confirmText: '删除',
                cancelText: '取消',
                success: function (r) {
                    if (!r.confirm) { return }
                    deleteAddress(a.id).then(function () {
                        uni.showToast({ title: '已删除', icon: 'none' })
                        that.load()
                    }).catch(function () { })
                }
            })
        }
    }
}
</script>

<style scoped>
.addr-item {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}
.addr-top {
    display: flex;
    align-items: center;
    margin-bottom: 10rpx;
}
.addr-top text {
    margin-right: 16rpx;
}
.default-tag {
    margin-left: 0;
}
.addr-detail {
    font-size: 26rpx;
    color: #666;
    line-height: 1.6;
    word-break: break-all;
}
.addr-actions {
    display: flex;
    justify-content: flex-end;
    width: 100%;
    margin-top: 16rpx;
    padding-top: 16rpx;
    border-top: 2rpx solid #F5F5F5;
}
.addr-actions text {
    margin-left: 36rpx;
}
.red {
    color: #E53935;
}
.select-hint {
    justify-content: center;
}
.add-bar {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    padding: 20rpx 24rpx;
    background: #fff;
    border-top: 2rpx solid #EFEFEF;
    padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
    z-index: 999;
}
.addr-page {
    padding-bottom: 160rpx;
}
</style>

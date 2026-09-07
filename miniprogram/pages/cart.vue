<template>
    <view class="cart-page" v-if="logged">
        <view class="container">
            <!-- 购物车列表 -->
            <view class="card cart-item" v-for="item in list" :key="item.id">
                <!-- 勾选 -->
                <view class="check-box" :class="{ on: item.checked }" @click="toggleCheck(item)">
                    <text v-if="item.checked" class="check-mark">✓</text>
                </view>
                <image class="cart-img" :src="item.imageUrl" mode="aspectFill" @click="goDetail(item.productId)" />
                <view class="cart-body">
                    <text class="cart-name ellipsis2">{{ item.productName }}</text>
                    <text v-if="item.spec" class="small gray spec-text">规格：{{ item.spec }}</text>
                    <view class="flex-between cart-bottom">
                        <text class="price">¥{{ item.priceText }}</text>
                        <stepper :value="item.quantity" :min="1" :max="99" @change="onQty(item, $event)"></stepper>
                    </view>
                </view>
                <view class="del-btn" @click="onDelete(item)">删除</view>
            </view>

            <empty v-if="!loading && list.length === 0" text="购物车空空如也，快去逛逛吧"></empty>

            <!-- 合计与结算 -->
            <view class="total-bar" v-if="list.length">
                <view class="check-box" :class="{ on: allChecked }" @click="toggleAll">
                    <text v-if="allChecked" class="check-mark">✓</text>
                </view>
                <text class="small all-txt">全选</text>
                <text class="total-txt">合计：<text class="price total-price">¥{{ totalText }}</text></text>
                <view class="go-pay" :class="{ 'btn-disabled': checkedCount === 0 }" @click="goConfirm">
                    去结算（{{ checkedCount }}）
                </view>
            </view>
        </view>
    </view>

    <!-- 未登录 -->
    <view v-else class="container">
        <view class="card login-tip-card">
            <empty text="登录后可使用购物车"></empty>
            <button class="btn btn-primary" @click="goLogin">去登录</button>
        </view>
    </view>
</template>

<script>
import { getCart, updateCart, deleteCart } from '@/common/api.js'
import { imgUrl, priceText, isLoggedIn } from '@/common/util.js'

export default {
    data() {
        return {
            logged: false,
            list: [],
            loading: false
        }
    },
    computed: {
        checkedItems() {
            var arr = []
            for (var i = 0; i < this.list.length; i++) {
                if (this.list[i].checked) { arr.push(this.list[i]) }
            }
            return arr
        },
        checkedCount() {
            return this.checkedItems.length
        },
        allChecked() {
            return this.list.length > 0 && this.checkedCount === this.list.length
        },
        totalText() {
            var total = 0
            for (var i = 0; i < this.checkedItems.length; i++) {
                total += Number(this.checkedItems[i].price || 0) * Number(this.checkedItems[i].quantity || 0)
            }
            return total.toFixed(2)
        }
    },
    onShow() {
        this.logged = isLoggedIn()
        if (this.logged) {
            this.load()
        }
    },
    methods: {
        load() {
            var that = this
            that.loading = true
            getCart().then(function (res) {
                var rows = res && res.list ? res.list : (res || [])
                that.list = rows.map(function (item) {
                    item.imageUrl = imgUrl(item.mainImage, 'p' + item.productId)
                    item.priceText = priceText(item.price)
                    return item
                })
                that.loading = false
            }).catch(function () {
                that.loading = false
                that.list = []
            })
        },
        toggleCheck(item) {
            var that = this
            var v = item.checked ? 0 : 1
            updateCart(item.id, { checked: v }).then(function () {
                item.checked = v
                // 后端若同步返回合计，可在此刷新；本地直接改状态即可
            }).catch(function () { })
        },
        toggleAll() {
            var that = this
            var v = that.allChecked ? 0 : 1
            var jobs = []
            for (var i = 0; i < that.list.length; i++) {
                (function (item) {
                    jobs.push(updateCart(item.id, { checked: v }).then(function () {
                        item.checked = v
                    }).catch(function () { }))
                })(that.list[i])
            }
            Promise.all(jobs)
        },
        onQty(item, v) {
            updateCart(item.id, { quantity: v }).then(function () {
                item.quantity = v
            }).catch(function () { })
        },
        onDelete(item) {
            var that = this
            uni.showModal({
                title: '删除商品',
                content: '确定将该商品移出购物车吗？',
                confirmText: '删除',
                cancelText: '取消',
                success: function (r) {
                    if (!r.confirm) { return }
                    deleteCart(item.id).then(function () {
                        uni.showToast({ title: '已删除', icon: 'none' })
                        that.load()
                    }).catch(function () { })
                }
            })
        },
        goConfirm() {
            if (this.checkedCount === 0) {
                uni.showToast({ title: '请先勾选要结算的商品', icon: 'none' })
                return
            }
            uni.navigateTo({ url: '/pages/order/confirm?fromCart=1' })
        },
        goDetail(id) {
            uni.navigateTo({ url: '/pages/product/detail?id=' + id })
        },
        goLogin() {
            uni.navigateTo({ url: '/pages/login/login' })
        }
    }
}
</script>

<style scoped>
.cart-item {
    display: flex;
    align-items: center;
    position: relative;
}
.check-box {
    width: 40rpx;
    height: 40rpx;
    border: 2rpx solid #CCC;
    border-radius: 50%;
    flex-shrink: 0;
    margin-right: 16rpx;
    display: flex;
    align-items: center;
    justify-content: center;
}
.check-box.on {
    background: #2E8B57;
    border-color: #2E8B57;
}
.check-mark {
    color: #fff;
    font-size: 24rpx;
}
.cart-img {
    width: 160rpx;
    height: 160rpx;
    border-radius: 12rpx;
    flex-shrink: 0;
    margin-right: 16rpx;
}
.cart-body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 160rpx;
    padding-right: 70rpx;
}
.cart-name {
    font-size: 27rpx;
    line-height: 1.4;
}
.spec-text {
    margin: 4rpx 0;
}
.cart-bottom {
    margin-top: auto;
}
.del-btn {
    position: absolute;
    right: 24rpx;
    top: 24rpx;
    color: #999;
    font-size: 24rpx;
    border: 2rpx solid #DDD;
    border-radius: 20rpx;
    padding: 2rpx 16rpx;
}
.total-bar {
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    height: 110rpx;
    background: #fff;
    display: flex;
    align-items: center;
    padding: 0 24rpx;
    border-top: 2rpx solid #EFEFEF;
    padding-bottom: env(safe-area-inset-bottom);
    z-index: 999;
}
.all-txt {
    margin-right: 16rpx;
}
.total-txt {
    flex: 1;
    font-size: 26rpx;
    color: #333;
}
.total-price {
    font-size: 36rpx;
}
.go-pay {
    width: 220rpx;
    height: 80rpx;
    line-height: 80rpx;
    text-align: center;
    background: #2E8B57;
    color: #fff;
    border-radius: 40rpx;
    font-size: 28rpx;
}
.login-tip-card {
    padding-bottom: 40rpx;
}
.cart-page {
    padding-bottom: 140rpx;
}
</style>

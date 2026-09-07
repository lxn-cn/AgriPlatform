<template>
    <view class="container confirm-page">
        <!-- 收货地址 -->
        <view class="card addr-card" @click="chooseAddress">
            <view v-if="address" class="addr-inner">
                <view class="flex-between addr-top">
                    <view class="flex">
                        <text class="bold addr-receiver">{{ address.receiver }}</text>
                        <text class="small gray addr-phone">{{ address.phone }}</text>
                    </view>
                    <text class="small green">更换 &gt;</text>
                </view>
                <text class="addr-text">天津市 {{ address.district }} {{ address.detail }}</text>
            </view>
            <view v-else class="addr-empty">
                <text class="green">请选择收货地址 &gt;</text>
            </view>
        </view>

        <!-- 商品清单 -->
        <view class="card">
            <text class="card-title">商品清单</text>
            <view class="item-row" v-for="(item, i) in items" :key="i">
                <image class="item-img" :src="item.imageUrl" mode="aspectFill" />
                <view class="item-body">
                    <text class="item-name ellipsis2">{{ item.name }}</text>
                    <text v-if="item.spec" class="small gray">规格：{{ item.spec }}</text>
                    <view class="flex-between">
                        <text class="price">¥{{ item.priceText }}</text>
                        <text class="small gray">× {{ item.quantity }}</text>
                    </view>
                </view>
            </view>
            <view class="divider"></view>
            <view class="flex-between">
                <text>商品合计</text>
                <text class="price">¥{{ totalText }}</text>
            </view>
        </view>

        <!-- 留言 -->
        <view class="card">
            <view class="form-item no-border">
                <text class="form-label">买家留言</text>
                <input class="form-input" v-model="remark" placeholder="选填，给商家留言（50字内）" maxlength="50" />
            </view>
        </view>

        <!-- 提交 -->
        <view class="submit-bar">
            <view class="submit-total">
                <text>合计：</text>
                <text class="price submit-price">¥{{ totalText }}</text>
            </view>
            <view class="submit-btn" :class="{ 'btn-disabled': submitting }" @click="submit">
                {{ submitting ? '提交中...' : '提交订单' }}
            </view>
        </view>
    </view>
</template>

<script>
import { getAddresses, getCart, getProductDetail, createOrder } from '@/common/api.js'
import { imgUrl, priceText, requireLogin } from '@/common/util.js'

export default {
    data() {
        return {
            fromCart: false,
            buyProductId: null,
            buyQuantity: 1,
            buySpec: '',
            address: null,
            items: [],
            remark: '',
            submitting: false
        }
    },
    computed: {
        totalText() {
            var total = 0
            for (var i = 0; i < this.items.length; i++) {
                total += Number(this.items[i].price || 0) * Number(this.items[i].quantity || 0)
            }
            return total.toFixed(2)
        }
    },
    onLoad(query) {
        var that = this
        if (query.fromCart === '1') {
            that.fromCart = true
        } else if (query.buyNow === '1') {
            that.buyProductId = query.productId
            that.buyQuantity = Number(query.quantity) || 1
            that.buySpec = query.spec ? decodeURIComponent(query.spec) : ''
        }
        that.loadItems()
    },
    onShow() {
        this.loadAddress()
    },
    methods: {
        loadAddress() {
            var that = this
            if (!requireLogin()) { return }
            getAddresses().then(function (res) {
                var rows = res && res.list ? res.list : (res || [])
                if (rows.length === 0) {
                    that.address = null
                    return
                }
                var selId = uni.getStorageSync('confirmAddressId')
                var hit = null
                if (selId) {
                    for (var i = 0; i < rows.length; i++) {
                        if (String(rows[i].id) === String(selId)) { hit = rows[i]; break }
                    }
                }
                if (!hit) {
                    for (var j = 0; j < rows.length; j++) {
                        if (rows[j].isDefault) { hit = rows[j]; break }
                    }
                }
                if (!hit) { hit = rows[0] }
                that.address = hit
            }).catch(function () { })
        },
        loadItems() {
            var that = this
            if (that.fromCart) {
                getCart().then(function (res) {
                    var rows = res && res.list ? res.list : (res || [])
                    var arr = []
                    for (var i = 0; i < rows.length; i++) {
                        if (rows[i].checked) {
                            arr.push({
                                productId: rows[i].productId,
                                name: rows[i].productName,
                                spec: rows[i].spec || '',
                                quantity: Number(rows[i].quantity) || 1,
                                price: Number(rows[i].price) || 0,
                                imageUrl: imgUrl(rows[i].mainImage, 'p' + rows[i].productId),
                                priceText: priceText(rows[i].price)
                            })
                        }
                    }
                    if (arr.length === 0 && rows.length > 0) {
                        uni.showToast({ title: '请先在购物车勾选商品', icon: 'none' })
                        setTimeout(function () {
                            uni.navigateBack()
                        }, 1000)
                        return
                    }
                    that.items = arr
                }).catch(function () { })
            } else if (that.buyProductId) {
                getProductDetail(that.buyProductId).then(function (p) {
                    that.items = [{
                        productId: p.id,
                        name: p.name,
                        spec: that.buySpec || '',
                        quantity: that.buyQuantity,
                        price: Number(p.price) || 0,
                        imageUrl: imgUrl(p.mainImage, 'p' + p.id),
                        priceText: priceText(p.price)
                    }]
                }).catch(function () { })
            }
        },
        chooseAddress() {
            uni.navigateTo({ url: '/pages/address/list?select=1' })
        },
        submit() {
            var that = this
            if (!requireLogin()) { return }
            if (!that.address) {
                uni.showToast({ title: '请先选择收货地址', icon: 'none' })
                return
            }
            if (that.items.length === 0) {
                uni.showToast({ title: '订单商品为空', icon: 'none' })
                return
            }
            if (that.submitting) { return }
            var orderItems = that.items.map(function (it) {
                return { productId: it.productId, quantity: it.quantity, spec: it.spec || '' }
            })
            that.submitting = true
            createOrder({
                addressId: that.address.id,
                remark: that.remark,
                items: orderItems,
                fromCart: that.fromCart
            }).then(function (res) {
                that.submitting = false
                uni.removeStorageSync('confirmAddressId')
                uni.showToast({ title: '订单已提交', icon: 'success' })
                var id = res.id || res.orderId
                setTimeout(function () {
                    uni.redirectTo({ url: '/pages/order/pay?id=' + id })
                }, 800)
            }).catch(function () {
                that.submitting = false
            })
        }
    }
}
</script>

<style scoped>
.addr-card {
    padding: 28rpx 24rpx;
}
.addr-top {
    margin-bottom: 10rpx;
}
.addr-receiver {
    margin-right: 16rpx;
    font-size: 30rpx;
}
.addr-phone {
    margin-left: 4rpx;
}
.addr-text {
    font-size: 26rpx;
    color: #666;
    line-height: 1.6;
    word-break: break-all;
}
.addr-empty {
    text-align: center;
    padding: 20rpx 0;
    font-size: 28rpx;
}
.card-title {
    display: block;
    font-size: 30rpx;
    font-weight: 700;
    margin-bottom: 16rpx;
}
.item-row {
    display: flex;
    margin-bottom: 20rpx;
}
.item-img {
    width: 140rpx;
    height: 140rpx;
    border-radius: 12rpx;
    flex-shrink: 0;
    margin-right: 16rpx;
}
.item-body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.item-name {
    font-size: 27rpx;
}
.no-border {
    border-bottom: none;
}
.submit-bar {
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
.submit-total {
    flex: 1;
    font-size: 28rpx;
}
.submit-price {
    font-size: 36rpx;
}
.submit-btn {
    width: 220rpx;
    height: 80rpx;
    line-height: 80rpx;
    text-align: center;
    background: #2E8B57;
    color: #fff;
    border-radius: 40rpx;
    font-size: 28rpx;
}
.confirm-page {
    padding-bottom: 150rpx;
}
</style>

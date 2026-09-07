<template>
    <view class="container">
        <view class="card fav-card" v-for="f in list" :key="f.id" @click="goDetail(f)">
            <image class="fav-img" :src="f.imageUrl" mode="aspectFill" />
            <view class="fav-body">
                <text class="fav-name ellipsis2">{{ f.productName || f.name }}</text>
                <view class="fav-bottom">
                    <text class="price">¥{{ f.priceText }}</text>
                    <view class="fav-actions">
                        <button
                            class="btn btn-mini btn-mini-primary fav-btn"
                            size="mini"
                            @click.stop="addCart(f)"
                        >加入购物车</button>
                        <button
                            class="btn btn-mini btn-mini-gray fav-btn"
                            size="mini"
                            @click.stop="onRemove(f)"
                        >取消收藏</button>
                    </view>
                </view>
            </view>
        </view>

        <empty v-if="!loading && list.length === 0" text="暂无收藏商品" />
    </view>
</template>

<script>
import { getMyFavorites, addToCart, removeFavorite } from '@/common/api.js'
import { imgUrl, priceText, parsePage } from '@/common/util.js'

export default {
    data() {
        return {
            list: [],
            loading: false
        }
    },
    onShow() {
        this.load()
    },
    methods: {
        load() {
            var that = this
            that.loading = true
            getMyFavorites().then(function (res) {
                var page = parsePage(res)
                that.list = page.list.map(function (f) {
                    f.imageUrl = imgUrl(f.mainImage, 'p' + f.productId)
                    f.priceText = priceText(f.price)
                    return f
                })
                that.loading = false
            }).catch(function () {
                that.loading = false
                that.list = []
            })
        },
        goDetail(f) {
            uni.navigateTo({ url: '/pages/product/detail?id=' + f.productId })
        },
        addCart(f) {
            addToCart({
                productId: f.productId,
                spec: f.spec || '',
                quantity: 1
            }).then(function () {
                uni.showToast({ title: '已加入购物车', icon: 'success' })
            }).catch(function () { })
        },
        onRemove(f) {
            var that = this
            uni.showModal({
                title: '取消收藏',
                content: '确定取消收藏该商品吗？',
                confirmText: '取消收藏',
                cancelText: '再想想',
                success: function (r) {
                    if (!r.confirm) { return }
                    removeFavorite(f.productId).then(function () {
                        uni.showToast({ title: '已取消收藏', icon: 'none' })
                        that.load()
                    }).catch(function () { })
                }
            })
        }
    }
}
</script>

<style scoped>
.fav-card {
    display: flex;
}
.fav-img {
    width: 180rpx;
    height: 180rpx;
    border-radius: 12rpx;
    flex-shrink: 0;
    margin-right: 20rpx;
}
.fav-body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.fav-name {
    font-size: 28rpx;
}
.fav-bottom {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}
.fav-actions {
    display: flex;
    margin-top: 12rpx;
}
.fav-btn {
    margin-right: 14rpx;
}
</style>

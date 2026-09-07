<template>
    <view class="product-detail" v-if="p">
        <!-- 轮播图 -->
        <swiper class="p-swiper" indicator-dots autoplay circular :interval="4000">
            <swiper-item v-for="(img, i) in imageList" :key="i">
                <image class="p-img" :src="img" mode="aspectFill" />
            </swiper-item>
        </swiper>

        <view class="container">
            <!-- 基本信息 -->
            <view class="card">
                <view class="flex-between">
                    <text class="p-price">¥{{ p.priceText }}</text>
                    <text class="small gray">已售{{ p.sales || 0 }} 件</text>
                </view>
                <text class="p-name">{{ p.name }}</text>
                <view class="p-tags">
                    <text v-if="p.origin" class="tag tag-green">产地：{{ p.origin }}</text>
                    <text class="tag tag-blue">{{ merchantName }}</text>
                    <text class="tag" :class="p.stock > 0 ? 'tag-orange' : 'tag-red'">
                        {{ p.stock > 0 ? '库存 ' + p.stock : '暂时缺货' }}
                    </text>
                </view>
            </view>

            <!-- 规格选择 -->
            <view class="card" v-if="specList.length">
                <text class="card-title">选择规格</text>
                <view class="spec-chips">
                    <text
                        v-for="(s, i) in specList"
                        :key="i"
                        class="chip"
                        :class="{ active: specIndex === i }"
                        @click="onSpec(i)"
                    >{{ s }}</text>
                </view>
            </view>

            <!-- 数量 -->
            <view class="card flex-between">
                <text>购买数量</text>
                <stepper :value="quantity" :min="1" :max="maxQty" @change="onQty"></stepper>
            </view>

            <!-- 图文描述 -->
            <view class="card">
                <text class="card-title">商品详情</text>
                <text class="desc-text">{{ p.description || '暂无详细描述' }}</text>
            </view>

            <!-- 商品评价 -->
            <view class="section-head">
                <text class="section-title">用户评价（{{ reviewTotal }}）</text>
            </view>
            <view class="card" v-if="reviews.length">
                <view class="review-item" v-for="r in reviews" :key="r.id">
                    <view class="flex-between">
                        <text class="bold">{{ r.nickname || '匿名用户' }}</text>
                        <star-rate :value="r.rating" :readonly="true" :size="26"></star-rate>
                    </view>
                    <text class="review-content">{{ r.content }}</text>
                    <text class="small gray">{{ r.createTime }}</text>
                </view>
                <view v-if="reviews.length < reviewTotal" class="load-more" @click="loadMoreReviews">查看更多评价</view>
            </view>
            <empty v-if="!loading && reviews.length === 0" text="暂无评价，快来抢首评吧" />
        </view>

        <!-- 底部操作栏 -->
        <view class="bottom-bar">
            <view class="fav-btn" @click="toggleFav">
                <text class="fav-star" :class="{ on: favored }">★</text>
                <text class="fav-txt">{{ favored ? '已收藏' : '收藏' }}</text>
            </view>
            <view class="bar-btn bar-btn-cart" @click="addCart">加入购物车</view>
            <view class="bar-btn bar-btn-buy" @click="buyNow">立即购买</view>
        </view>
    </view>
    <view v-else-if="!loading" class="container">
        <empty text="未找到该商品"></empty>
    </view>
</template>

<script>
import { getProductDetail, getProductReviews, addFavorite, removeFavorite, addToCart } from '@/common/api.js'
import { imgUrl, priceText, parsePage, requireLogin } from '@/common/util.js'

export default {
    data() {
        return {
            id: null,
            p: null,
            imageList: [],
            specList: [],
            specIndex: 0,
            quantity: 1,
            favored: false,
            reviews: [],
            reviewTotal: 0,
            reviewPage: 1,
            loading: true
        }
    },
    computed: {
        merchantName() {
            return (this.p && this.p.merchantName) ? this.p.merchantName : '天津本地商家'
        },
        maxQty() {
            if (!this.p) { return 99 }
            var s = Number(this.p.stock) || 0
            return s > 0 ? s : 1
        }
    },
    onLoad(query) {
        var that = this
        that.id = query.id
        that.loadProduct()
        that.loadReviews(true)
    },
    methods: {
        loadProduct() {
            var that = this
            that.loading = true
            getProductDetail(that.id).then(function (res) {
                var imgs = []
                if (res.images) {
                    var arr = String(res.images).split(',')
                    for (var i = 0; i < arr.length; i++) {
                        var s = arr[i].trim()
                        if (s) { imgs.push(imgUrl(s, 'p' + that.id + '_' + i)) }
                    }
                }
                if (imgs.length === 0) {
                    imgs.push(imgUrl(res.mainImage, 'p' + that.id))
                }
                that.imageList = imgs
                res.priceText = priceText(res.price)
                that.p = res
                var specs = []
                if (res.specs) {
                    var sa = String(res.specs).split(',')
                    for (var j = 0; j < sa.length; j++) {
                        var t = sa[j].trim()
                        if (t) { specs.push(t) }
                    }
                }
                that.specList = specs
                that.specIndex = 0
                // 后端若返回收藏状态字段则使用（字段名兼容 favored/isFavored）
                that.favored = res.favored === true || res.isFavored === true || res.isFavorite === true
                that.loading = false
            }).catch(function () {
                that.loading = false
            })
        },
        loadReviews(reset) {
            var that = this
            if (reset) {
                that.reviewPage = 1
                that.reviews = []
            } else {
                that.reviewPage = that.reviewPage + 1
            }
            getProductReviews(that.id, { pageNum: that.reviewPage, pageSize: 10 }).then(function (res) {
                var page = parsePage(res)
                that.reviews = that.reviews.concat(page.list)
                that.reviewTotal = page.total
            }).catch(function () { })
        },
        loadMoreReviews() {
            this.loadReviews(false)
        },
        onSpec(i) {
            this.specIndex = i
        },
        onQty(v) {
            this.quantity = v
        },
        currentSpec() {
            return this.specList.length ? this.specList[this.specIndex] : ''
        },
        toggleFav() {
            var that = this
            if (!requireLogin()) { return }
            if (that.favored) {
                removeFavorite(that.id).then(function () {
                    that.favored = false
                    uni.showToast({ title: '已取消收藏', icon: 'none' })
                }).catch(function () { })
            } else {
                addFavorite(that.id).then(function () {
                    that.favored = true
                    uni.showToast({ title: '已收藏', icon: 'success' })
                }).catch(function () { })
            }
        },
        addCart() {
            var that = this
            if (!requireLogin()) { return }
            if (that.stockEmpty()) { return }
            addToCart({
                productId: that.id,
                spec: that.currentSpec(),
                quantity: that.quantity
            }).then(function () {
                uni.showToast({ title: '已加入购物车', icon: 'success' })
            }).catch(function () { })
        },
        buyNow() {
            var that = this
            if (!requireLogin()) { return }
            if (that.stockEmpty()) { return }
            uni.navigateTo({
                url: '/pages/order/confirm?buyNow=1&productId=' + that.id +
                    '&quantity=' + that.quantity +
                    '&spec=' + encodeURIComponent(that.currentSpec())
            })
        },
        stockEmpty() {
            if (this.p && Number(this.p.stock) <= 0) {
                uni.showToast({ title: '商品暂时缺货', icon: 'none' })
                return true
            }
            return false
        }
    }
}
</script>

<style scoped>
.p-swiper {
    height: 560rpx;
}
.p-img {
    width: 100%;
    height: 560rpx;
}
.p-price {
    font-size: 44rpx;
    color: #FF5722;
    font-weight: 700;
}
.p-name {
    display: block;
    font-size: 32rpx;
    font-weight: 700;
    margin: 14rpx 0 12rpx;
    line-height: 1.5;
}
.p-tags {
    margin-top: 4rpx;
}
.card-title {
    display: block;
    font-size: 30rpx;
    font-weight: 700;
    margin-bottom: 16rpx;
}
.spec-chips .chip {
    margin: 0 16rpx 16rpx 0;
}
.desc-text {
    font-size: 27rpx;
    color: #555;
    line-height: 1.8;
    word-break: break-all;
}
.review-item {
    padding: 16rpx 0;
    border-bottom: 2rpx solid #F5F5F5;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}
.review-item:last-child {
    border-bottom: none;
}
.review-content {
    font-size: 26rpx;
    color: #444;
    margin: 10rpx 0;
    line-height: 1.6;
}
.load-more {
    text-align: center;
    color: #2E8B57;
    font-size: 26rpx;
    padding: 16rpx 0 0;
}
.bottom-bar {
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
.fav-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100rpx;
}
.fav-star {
    font-size: 40rpx;
    color: #CCC;
}
.fav-star.on {
    color: #FFB800;
}
.fav-txt {
    font-size: 20rpx;
    color: #666;
}
.bar-btn {
    flex: 1;
    height: 80rpx;
    line-height: 80rpx;
    text-align: center;
    font-size: 28rpx;
    border-radius: 40rpx;
    margin-left: 16rpx;
}
.bar-btn-cart {
    background: #3CB371;
    color: #fff;
}
.bar-btn-buy {
    background: #2E8B57;
    color: #fff;
}
.product-detail {
    padding-bottom: 140rpx;
}
</style>

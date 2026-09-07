<template>
    <view class="container page-tab">
        <!-- 顶部搜索框（点击跳搜索页） -->
        <view class="search-box" @click="goSearch">
            <view class="search-input">
                <text class="search-tip">搜索农特产、农园</text>
            </view>
            <view class="search-btn">搜索</view>
        </view>

        <!-- 轮播图 -->
        <swiper v-if="banners.length" class="banner" indicator-dots autoplay circular :interval="4000" :duration="500">
            <swiper-item v-for="b in banners" :key="b.id" @click="onBanner(b)">
                <image class="banner-img" :src="b.imageUrl" mode="aspectFill" />
            </swiper-item>
        </swiper>

        <!-- 公告栏（纵向滚动） -->
        <view v-if="notices.length" class="notice-bar card" @click="onNotice(notices[noticeIdx] || notices[0])">
            <text class="notice-label">公告</text>
            <swiper class="notice-swiper" vertical autoplay circular :interval="3000" @change="onNoticeChange">
                <swiper-item v-for="n in notices" :key="n.id">
                    <text class="notice-title ellipsis">{{ n.title }}</text>
                </swiper-item>
            </swiper>
        </view>

        <!-- 金刚区分类导航 -->
        <view class="kingkong card">
            <view class="kk-item" v-for="k in kingkong" :key="k.name" @click="goKingkong(k)">
                <view class="kk-icon" :style="{ background: k.color }">{{ k.icon }}</view>
                <text class="kk-name">{{ k.name }}</text>
            </view>
        </view>

        <!-- 推荐商品 -->
        <view class="section-head">
            <text class="section-title">当季推荐</text>
        </view>
        <view class="goods-grid">
            <view class="goods-card card" v-for="g in recommended" :key="g.id" @click="goProduct(g.id)">
                <image class="goods-img" :src="g.imageUrl" mode="aspectFill" />
                <view class="goods-info">
                    <text class="goods-name ellipsis2">{{ g.name }}</text>
                    <view class="flex-between">
                        <text class="price">¥{{ g.priceText }}</text>
                        <text class="small gray">已售{{ g.sales || 0 }}</text>
                    </view>
                </view>
            </view>
        </view>
        <empty v-if="!loading && recommended.length === 0" text="暂无推荐商品" />

        <!-- 农园入口卡片区 -->
        <view class="section-head">
            <text class="section-title">农园体验</text>
            <text class="section-more" @click="goFarmList()">更多 &gt;</text>
        </view>
        <scroll-view v-if="farms.length" scroll-x class="farm-scroll">
            <view class="farm-mini" v-for="f in farms" :key="f.id" @click="goFarm(f.id)">
                <image class="farm-mini-img" :src="f.imageUrl" mode="aspectFill" />
                <text class="farm-mini-name ellipsis">{{ f.name }}</text>
                <text class="small gray">{{ f.type }} · {{ f.rating }}分</text>
            </view>
        </scroll-view>
        <empty v-if="!loading && farms.length === 0" text="暂无农园" />

        <tab-bar current="index"></tab-bar>
    </view>
</template>

<script>
import { getBanners, getNotices, getRecommended, getFarmsBrief } from '@/common/api.js'
import { imgUrl, priceText } from '@/common/util.js'

export default {
    data() {
        return {
            loading: true,
            banners: [],
            notices: [],
            recommended: [],
            farms: [],
            noticeIdx: 0,
            kingkong: [
                { name: '时令水果', icon: '果', color: '#FF7043', url: '/pages/product/list?catName=时令水果' },
                { name: '时令蔬菜', icon: '蔬', color: '#66BB6A', url: '/pages/product/list?catName=时令蔬菜' },
                { name: '粮油米面', icon: '粮', color: '#F0A64B', url: '/pages/product/list?catName=粮油米面' },
                { name: '禽蛋水产', icon: '蛋', color: '#8D6E63', url: '/pages/product/list?catName=禽蛋水产' },
                { name: '干货特产', icon: '干', color: '#7986CB', url: '/pages/product/list?catName=干货特产' },
                { name: '农园采摘', icon: '采', color: '#2E8B57', url: '/pages/farm/list' }
            ]
        }
    },
    onPullDownRefresh() {
        this.loadAll(true)
    },
    onLoad() {
        this.loadAll()
    },
    methods: {
        loadAll(stopPull) {
            var that = this
            that.loading = true
            var jobs = []
            jobs.push(
                getBanners().then(function (res) {
                    var list = res && res.list ? res.list : (res || [])
                    that.banners = list.map(function (b) {
                        b.imageUrl = imgUrl(b.image, 'banner' + b.id)
                        return b
                    })
                }).catch(function () { that.banners = [] })
            )
            jobs.push(
                getNotices().then(function (res) {
                    that.notices = res && res.list ? res.list : (res || [])
                }).catch(function () { that.notices = [] })
            )
            jobs.push(
                getRecommended().then(function (res) {
                    var list = res && res.list ? res.list : (res || [])
                    that.recommended = list.map(function (g) {
                        g.imageUrl = imgUrl(g.mainImage, 'p' + g.id)
                        g.priceText = priceText(g.price)
                        return g
                    })
                }).catch(function () { that.recommended = [] })
            )
            jobs.push(
                getFarmsBrief().then(function (res) {
                    var list = res && res.list ? res.list : (res || [])
                    that.farms = list.map(function (f) {
                        f.imageUrl = imgUrl(f.coverImage, 'farm' + f.id)
                        return f
                    })
                }).catch(function () { that.farms = [] })
            )
            Promise.all(jobs).then(function () {
                that.loading = false
                if (stopPull) { uni.stopPullDownRefresh() }
            })
        },
        goSearch() {
            uni.navigateTo({ url: '/pages/search/search' })
        },
        onBanner(b) {
            var v = String(b.linkValue || '')
            if (b.linkType === 'product' && v) {
                uni.navigateTo({ url: '/pages/product/detail?id=' + v })
            } else if (b.linkType === 'farm' && v) {
                uni.navigateTo({ url: '/pages/farm/detail?id=' + v })
            } else if (b.linkType === 'notice' && v) {
                var nid = Number(v)
                var hit = null
                for (var i = 0; i < this.notices.length; i++) {
                    if (this.notices[i].id === nid) { hit = this.notices[i]; break }
                }
                if (hit) { this.onNotice(hit) }
            }
        },
        onNotice(n) {
            if (!n) { return }
            uni.showModal({
                title: n.title,
                content: n.content || '暂无内容',
                showCancel: false,
                confirmText: '知道了'
            })
        },
        onNoticeChange(e) {
            this.noticeIdx = e.detail.current
        },
        goKingkong(k) {
            uni.navigateTo({ url: k.url })
        },
        goProduct(id) {
            uni.navigateTo({ url: '/pages/product/detail?id=' + id })
        },
        goFarm(id) {
            uni.navigateTo({ url: '/pages/farm/detail?id=' + id })
        },
        goFarmList() {
            uni.navigateTo({ url: '/pages/farm/list' })
        }
    }
}
</script>

<style scoped>
.search-box {
    display: flex;
    align-items: center;
    margin-bottom: 20rpx;
}
.search-input {
    flex: 1;
    height: 72rpx;
    background: #fff;
    border-radius: 36rpx 0 0 36rpx;
    display: flex;
    align-items: center;
    padding: 0 30rpx;
}
.search-tip {
    color: #BBB;
    font-size: 26rpx;
}
.search-btn {
    width: 120rpx;
    height: 72rpx;
    line-height: 72rpx;
    text-align: center;
    background: #2E8B57;
    color: #fff;
    border-radius: 0 36rpx 36rpx 0;
    font-size: 26rpx;
}
.banner {
    height: 300rpx;
    border-radius: 16rpx;
    overflow: hidden;
    margin-bottom: 20rpx;
}
.banner-img {
    width: 100%;
    height: 300rpx;
}
.notice-bar {
    display: flex;
    align-items: center;
    padding: 16rpx 24rpx;
}
.notice-label {
    color: #FF5722;
    font-size: 24rpx;
    font-weight: 700;
    margin-right: 16rpx;
    flex-shrink: 0;
}
.notice-swiper {
    flex: 1;
    height: 44rpx;
}
.notice-title {
    font-size: 26rpx;
    color: #666;
    line-height: 44rpx;
}
.kingkong {
    display: flex;
    flex-wrap: wrap;
    padding: 30rpx 10rpx 10rpx;
}
.kk-item {
    width: 33.33%;
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 26rpx;
}
.kk-icon {
    width: 88rpx;
    height: 88rpx;
    border-radius: 24rpx;
    color: #fff;
    font-size: 38rpx;
    text-align: center;
    line-height: 88rpx;
    margin-bottom: 10rpx;
}
.kk-name {
    font-size: 26rpx;
    color: #444;
}
.goods-grid {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
}
.goods-card {
    width: 340rpx;
    padding: 0;
    overflow: hidden;
}
.goods-img {
    width: 340rpx;
    height: 300rpx;
}
.goods-info {
    padding: 16rpx 20rpx 20rpx;
}
.goods-name {
    font-size: 27rpx;
    height: 72rpx;
    margin-bottom: 10rpx;
}
.farm-scroll {
    white-space: nowrap;
}
.farm-mini {
    display: inline-block;
    width: 300rpx;
    background: #fff;
    border-radius: 16rpx;
    padding: 16rpx;
    margin-right: 20rpx;
    vertical-align: top;
}
.farm-mini-img {
    width: 268rpx;
    height: 180rpx;
    border-radius: 12rpx;
    margin-bottom: 12rpx;
}
.farm-mini-name {
    display: block;
    font-size: 28rpx;
    font-weight: 700;
    margin-bottom: 6rpx;
}
</style>

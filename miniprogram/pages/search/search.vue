<template>
    <view class="container">
        <!-- 搜索输入区 -->
        <view class="search-box">
            <input
                v-model="keyword"
                class="search-input"
                placeholder="搜索农特产 / 农园"
                confirm-type="search"
                :focus="true"
                @confirm="doSearch"
            />
            <view class="search-btn" @click="doSearch">搜索</view>
        </view>

        <!-- 搜索历史 -->
        <view v-if="!searched && history.length" class="card">
            <view class="flex-between">
                <text class="bold">搜索历史</text>
                <text class="small gray" @click="clearHistory">清空</text>
            </view>
            <view class="history-list">
                <text
                    v-for="(h, i) in history"
                    :key="i"
                    class="chip"
                    @click="useHistory(h)"
                >{{ h }}</text>
            </view>
        </view>

        <!-- 搜索结果 -->
        <block v-if="searched">
            <!-- 商品结果 -->
            <view class="section-head">
                <text class="section-title">农特产（{{ products.length }}）</text>
            </view>
            <view class="goods-grid" v-if="products.length">
                <view class="goods-card card" v-for="g in products" :key="g.id" @click="goProduct(g.id)">
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
            <empty v-else text="未搜到相关农特产" />

            <!-- 农园结果 -->
            <view class="section-head">
                <text class="section-title">农园（{{ farms.length }}）</text>
            </view>
            <view v-if="farms.length">
                <view class="card farm-card" v-for="f in farms" :key="f.id" @click="goFarm(f.id)">
                    <image class="farm-cover" :src="f.imageUrl" mode="aspectFill" />
                    <view class="farm-body">
                        <text class="bold ellipsis">{{ f.name }}</text>
                        <view class="farm-tags">
                            <text class="tag tag-green">{{ f.type }}</text>
                            <text class="tag tag-blue">{{ f.district }}</text>
                        </view>
                        <text class="small gray">评分 {{ f.rating }} · 人均 ¥{{ f.priceText }}</text>
                    </view>
                </view>
            </view>
            <empty v-else text="未搜到相关农园" />
        </block>
    </view>
</template>

<script>
import { searchAll } from '@/common/api.js'
import { imgUrl, priceText } from '@/common/util.js'

export default {
    data() {
        return {
            keyword: '',
            history: [],
            searched: false,
            loading: false,
            products: [],
            farms: []
        }
    },
    onLoad() {
        var h = uni.getStorageSync('searchHistory') || []
        this.history = h
    },
    methods: {
        doSearch() {
            var kw = (this.keyword || '').trim()
            if (!kw) {
                uni.showToast({ title: '请输入搜索关键词', icon: 'none' })
                return
            }
            var that = this
            that.saveHistory(kw)
            that.loading = true
            that.searched = true
            uni.showLoading({ title: '搜索中' })
            searchAll(kw).then(function (res) {
                uni.hideLoading()
                that.loading = false
                var ps = (res && res.products) || []
                that.products = ps.map(function (g) {
                    g.imageUrl = imgUrl(g.mainImage, 'p' + g.id)
                    g.priceText = priceText(g.price)
                    return g
                })
                var fs = (res && res.farms) || []
                that.farms = fs.map(function (f) {
                    f.imageUrl = imgUrl(f.coverImage, 'farm' + f.id)
                    f.priceText = priceText(f.avgPrice)
                    return f
                })
            }).catch(function () {
                uni.hideLoading()
                that.loading = false
                that.products = []
                that.farms = []
            })
        },
        saveHistory(kw) {
            var h = this.history.slice(0)
            var idx = h.indexOf(kw)
            if (idx > -1) { h.splice(idx, 1) }
            h.unshift(kw)
            if (h.length > 10) { h = h.slice(0, 10) }
            this.history = h
            uni.setStorageSync('searchHistory', h)
        },
        clearHistory() {
            this.history = []
            uni.removeStorageSync('searchHistory')
        },
        useHistory(h) {
            this.keyword = h
            this.doSearch()
        },
        goProduct(id) {
            uni.navigateTo({ url: '/pages/product/detail?id=' + id })
        },
        goFarm(id) {
            uni.navigateTo({ url: '/pages/farm/detail?id=' + id })
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
    padding: 0 30rpx;
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
.history-list {
    margin-top: 16rpx;
}
.history-list .chip {
    margin: 0 16rpx 16rpx 0;
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
.farm-card {
    display: flex;
}
.farm-cover {
    width: 200rpx;
    height: 150rpx;
    border-radius: 12rpx;
    flex-shrink: 0;
    margin-right: 20rpx;
}
.farm-body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.farm-tags {
    margin: 10rpx 0;
}
</style>

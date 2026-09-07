<template>
    <view class="product-list page-tab">
        <!-- 搜索框 -->
        <view class="search-box">
            <input
                v-model="keyword"
                class="search-input"
                placeholder="搜索农特产"
                confirm-type="search"
                @confirm="onSearch"
            />
            <view class="search-btn" @click="onSearch">搜索</view>
        </view>

        <!-- 一级分类 chips -->
        <scroll-view scroll-x class="filter-bar">
            <view
                v-for="c in catChips"
                :key="c.id"
                class="chip"
                :class="{ active: activeCat === c.id }"
                @click="onCat(c.id)"
            >{{ c.name }}</view>
        </scroll-view>

        <!-- 二级分类 chips -->
        <scroll-view v-if="subChips.length" scroll-x class="filter-bar sub-bar">
            <view
                v-for="s in subChips"
                :key="s.id"
                class="chip"
                :class="{ active: activeSub === s.id }"
                @click="onSub(s.id)"
            >{{ s.name }}</view>
        </scroll-view>

        <!-- 排序 -->
        <view class="filter-bar sort-bar">
            <view
                v-for="s in sortOptions"
                :key="s.value"
                class="sort-item"
                :class="{ active: sort === s.value }"
                @click="onSort(s.value)"
            >{{ s.label }}</view>
        </view>

        <!-- 商品列表 -->
        <view class="container">
            <view class="goods-grid">
                <view class="goods-card card" v-for="g in list" :key="g.id" @click="goDetail(g.id)">
                    <image class="goods-img" :src="g.imageUrl" mode="aspectFill" />
                    <view class="goods-info">
                        <text class="goods-name ellipsis2">{{ g.name }}</text>
                        <view class="goods-meta">
                            <text v-if="g.origin" class="tag tag-green">{{ g.origin }}</text>
                            <text v-else class="tag tag-gray">天津特产</text>
                        </view>
                        <view class="flex-between">
                            <text class="price">¥{{ g.priceText }}</text>
                            <text class="small gray">已售{{ g.sales || 0 }}</text>
                        </view>
                    </view>
                </view>
            </view>
            <empty v-if="!loading && list.length === 0" text="暂无商品" />
            <view v-if="finished && list.length > 0" class="load-tip">没有更多了</view>
        </view>

        <tab-bar current="shop"></tab-bar>
    </view>
</template>

<script>
import { getCategories, getProducts } from '@/common/api.js'
import { imgUrl, priceText, parsePage } from '@/common/util.js'

export default {
    data() {
        return {
            keyword: '',
            sortOptions: [
                { label: '综合', value: '' },
                { label: '价格低→高', value: 'price_asc' },
                { label: '价格高→低', value: 'price_desc' },
                { label: '销量', value: 'sales' }
            ],
            sort: '',
            categories: [],
            activeCat: 0, // 0 = 全部
            activeSub: 0,
            list: [],
            pageNum: 1,
            total: 0,
            loading: false,
            finished: false
        }
    },
    computed: {
        catChips() {
            return [{ id: 0, name: '全部' }].concat(this.categories)
        },
        subChips() {
            if (!this.activeCat) { return [] }
            for (var i = 0; i < this.categories.length; i++) {
                if (this.categories[i].id === this.activeCat) {
                    var children = this.categories[i].children || []
                    return [{ id: 0, name: '全部' }].concat(children)
                }
            }
            return []
        },
        // 当前生效的分类 id：选了二级用二级，否则用一级
        filterCatId() {
            if (this.activeSub) { return this.activeSub }
            return this.activeCat
        }
    },
    onLoad(query) {
        var that = this
        if (query.keyword) { that.keyword = decodeURIComponent(query.keyword) }
        getCategories().then(function (res) {
            var tree = res && res.list ? res.list : (res || [])
            that.categories = tree
            // 首页金刚区按分类名跳转
            if (query.catName) {
                var name = decodeURIComponent(query.catName)
                for (var i = 0; i < tree.length; i++) {
                    if (tree[i].name === name) {
                        that.activeCat = tree[i].id
                        break
                    }
                }
            }
            that.load(true)
        }).catch(function () {
            that.load(true)
        })
    },
    onPullDownRefresh() {
        this.load(true, true)
    },
    onReachBottom() {
        if (!this.finished && !this.loading) {
            this.load(false)
        }
    },
    methods: {
        load(reset, stopPull) {
            var that = this
            if (reset) {
                that.pageNum = 1
                that.list = []
                that.finished = false
            } else {
                that.pageNum = that.pageNum + 1
            }
            that.loading = true
            var params = { pageNum: that.pageNum, pageSize: 10 }
            if (that.filterCatId) { params.categoryId = that.filterCatId }
            var kw = (that.keyword || '').trim()
            if (kw) { params.keyword = kw }
            if (that.sort) { params.sort = that.sort }
            getProducts(params).then(function (res) {
                var page = parsePage(res)
                var rows = page.list.map(function (g) {
                    g.imageUrl = imgUrl(g.mainImage, 'p' + g.id)
                    g.priceText = priceText(g.price)
                    return g
                })
                that.list = reset ? rows : that.list.concat(rows)
                that.total = page.total
                if (that.list.length >= that.total || rows.length === 0) {
                    that.finished = true
                }
                that.loading = false
                if (stopPull) { uni.stopPullDownRefresh() }
            }).catch(function () {
                that.loading = false
                if (stopPull) { uni.stopPullDownRefresh() }
            })
        },
        onSearch() {
            this.load(true)
        },
        onCat(id) {
            if (this.activeCat === id) { return }
            this.activeCat = id
            this.activeSub = 0
            this.load(true)
        },
        onSub(id) {
            if (this.activeSub === id) { return }
            this.activeSub = id
            this.load(true)
        },
        onSort(v) {
            if (this.sort === v) { return }
            this.sort = v
            this.load(true)
        },
        goDetail(id) {
            uni.navigateTo({ url: '/pages/product/detail?id=' + id })
        }
    }
}
</script>

<style scoped>
.search-box {
    display: flex;
    align-items: center;
    background: #fff;
    padding: 16rpx 24rpx;
}
.search-input {
    flex: 1;
    height: 68rpx;
    background: #F5F6F2;
    border-radius: 34rpx;
    padding: 0 30rpx;
    font-size: 26rpx;
}
.search-btn {
    width: 110rpx;
    height: 68rpx;
    line-height: 68rpx;
    text-align: center;
    background: #2E8B57;
    color: #fff;
    border-radius: 34rpx;
    font-size: 26rpx;
    margin-left: 16rpx;
}
.filter-bar {
    background: #fff;
    white-space: nowrap;
    padding: 16rpx 24rpx;
    display: flex;
}
.filter-bar .chip {
    flex-shrink: 0;
    margin-right: 14rpx;
}
.sub-bar {
    border-top: 2rpx solid #F5F5F5;
    padding-top: 8rpx;
}
.sort-bar {
    border-top: 2rpx solid #F5F5F5;
}
.sort-item {
    flex-shrink: 0;
    margin-right: 44rpx;
    font-size: 26rpx;
    color: #666;
    padding: 4rpx 0;
}
.sort-item.active {
    color: #2E8B57;
    font-weight: 700;
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
.goods-meta {
    margin-bottom: 12rpx;
}
.load-tip {
    text-align: center;
    color: #999;
    font-size: 24rpx;
    padding: 20rpx 0;
}
</style>

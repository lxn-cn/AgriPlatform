<template>
    <view class="farm-list page-tab">
        <!-- 区县筛选 -->
        <scroll-view scroll-x class="filter-bar">
            <view
                v-for="d in districtOptions"
                :key="d"
                class="chip"
                :class="{ active: district === d }"
                @click="onDistrict(d)"
            >{{ d }}</view>
        </scroll-view>

        <!-- 类型筛选 + 排序 -->
        <view class="filter-bar filter-row">
            <view
                v-for="t in typeOptions"
                :key="t.value"
                class="chip"
                :class="{ active: type === t.value }"
                @click="onType(t.value)"
            >{{ t.label }}</view>
            <text class="filter-split">|</text>
            <view
                v-for="s in sortOptions"
                :key="s.value"
                class="chip"
                :class="{ active: sort === s.value }"
                @click="onSort(s.value)"
            >{{ s.label }}</view>
        </view>

        <!-- 农园列表 -->
        <view class="container">
            <view class="card farm-card" v-for="f in list" :key="f.id" @click="goDetail(f.id)">
                <image class="farm-cover" :src="f.imageUrl" mode="aspectFill" />
                <view class="farm-body">
                    <text class="bold farm-name ellipsis">{{ f.name }}</text>
                    <view class="farm-tags">
                        <text class="tag tag-green">{{ f.type }}</text>
                        <text class="tag tag-blue">{{ f.district }}</text>
                    </view>
                    <view class="flex-between">
                        <text class="small gray">评分 {{ f.rating }}</text>
                        <text class="small">人均 <text class="price">¥{{ f.priceText }}</text></text>
                    </view>
                </view>
            </view>
            <empty v-if="!loading && list.length === 0" text="暂无符合条件的农园" />
            <view v-if="loading" class="loading-tip">{{ loadMoreText }}</view>
        </view>

        <tab-bar current="farm"></tab-bar>
    </view>
</template>

<script>
import { getFarmList } from '@/common/api.js'
import { imgUrl, priceText, parsePage } from '@/common/util.js'

export default {
    data() {
        return {
            districtOptions: ['全部', '蓟州区', '西青区', '静海区', '宁河区', '宝坻区', '武清区', '北辰区', '津南区', '滨海新区'],
            typeOptions: [
                { label: '全部类型', value: '' },
                { label: '果园', value: '果园' },
                { label: '有机蔬菜农场', value: '有机蔬菜农场' }
            ],
            sortOptions: [
                { label: '人气', value: 'rating' },
                { label: '价格低→高', value: 'price_asc' },
                { label: '价格高→低', value: 'price_desc' }
            ],
            district: '全部',
            type: '',
            sort: 'rating',
            list: [],
            pageNum: 1,
            total: 0,
            loading: false,
            finished: false
        }
    },
    computed: {
        loadMoreText() {
            return this.pageNum > 1 ? '加载中...' : ''
        }
    },
    onLoad(query) {
        if (query.district) { this.district = query.district }
        this.load(true)
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
            var params = {
                pageNum: that.pageNum,
                pageSize: 10,
                sort: that.sort
            }
            if (that.district && that.district !== '全部') { params.district = that.district }
            if (that.type) { params.type = that.type }
            getFarmList(params).then(function (res) {
                var page = parsePage(res)
                var rows = page.list.map(function (f) {
                    f.imageUrl = imgUrl(f.coverImage, 'farm' + f.id)
                    f.priceText = priceText(f.avgPrice)
                    return f
                })
                if (reset) {
                    that.list = rows
                } else {
                    that.list = that.list.concat(rows)
                }
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
        onDistrict(d) {
            if (this.district === d) { return }
            this.district = d
            this.load(true)
        },
        onType(v) {
            if (this.type === v) { return }
            this.type = v
            this.load(true)
        },
        onSort(v) {
            if (this.sort === v) { return }
            this.sort = v
            this.load(true)
        },
        goDetail(id) {
            uni.navigateTo({ url: '/pages/farm/detail?id=' + id })
        }
    }
}
</script>

<style scoped>
.filter-bar {
    background: #fff;
    white-space: nowrap;
    padding: 20rpx 24rpx 4rpx;
}
.filter-row {
    display: flex;
    flex-wrap: nowrap;
    padding: 12rpx 24rpx 20rpx;
}
.filter-row .chip {
    flex-shrink: 0;
    margin-right: 14rpx;
}
.filter-split {
    color: #EEE;
    margin: 0 4rpx;
}
.farm-card {
    display: flex;
}
.farm-cover {
    width: 220rpx;
    height: 170rpx;
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
.farm-name {
    font-size: 30rpx;
}
.farm-tags {
    margin: 8rpx 0;
}
.loading-tip {
    text-align: center;
    color: #999;
    font-size: 24rpx;
    padding: 20rpx 0;
}
</style>

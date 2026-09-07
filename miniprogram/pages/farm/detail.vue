<template>
    <view class="farm-detail" v-if="farm">
        <!-- 头部封面 -->
        <swiper class="head-swiper" indicator-dots autoplay circular :interval="4000" v-if="farm.imageList.length">
            <swiper-item v-for="(img, i) in farm.imageList" :key="i">
                <image class="head-img" :src="img" mode="aspectFill" />
            </swiper-item>
        </swiper>

        <view class="container">
            <!-- 基础信息 -->
            <view class="card">
                <view class="flex-between">
                    <text class="farm-name">{{ farm.name }}</text>
                    <text class="small gray">评分 {{ farm.rating }}</text>
                </view>
                <view class="farm-tags">
                    <text class="tag tag-green">{{ farm.type }}</text>
                    <text class="tag tag-blue">{{ farm.district }}</text>
                    <text class="tag tag-orange">人均 ¥{{ farm.priceText }}</text>
                </view>
                <view class="info-row">
                    <text class="info-label">营业时间</text>
                    <text class="info-value">{{ farm.businessHours || '08:30-17:00' }}</text>
                </view>
                <!-- 地址行：带复制按钮 -->
                <view class="info-row">
                    <text class="info-label">地　址</text>
                    <text class="info-value addr-text">{{ farm.address }}</text>
                    <text class="copy-btn" @click="copyAddress">复制</text>
                </view>
                <!-- 联系电话：一键拨打 -->
                <view class="info-row">
                    <text class="info-label">联系电话</text>
                    <text class="info-value">{{ farm.phone || '暂未提供' }}</text>
                    <text v-if="farm.phone" class="copy-btn" @click="callFarm">拨打</text>
                </view>
            </view>

            <!-- 交通指引 -->
            <view class="card" v-if="farm.trafficGuide">
                <text class="card-title">交通指引</text>
                <text class="block-text">{{ farm.trafficGuide }}</text>
            </view>

            <!-- 图文简介 -->
            <view class="card">
                <text class="card-title">农园简介</text>
                <text class="block-text">{{ farm.intro || '暂无简介' }}</text>
            </view>

            <!-- 当季采摘项目 -->
            <view class="section-head">
                <text class="section-title">当季采摘项目（{{ projects.length }}）</text>
            </view>
            <view class="card project-card" v-for="p in projects" :key="p.id">
                <view class="flex-between">
                    <text class="bold project-name">{{ p.name }}</text>
                    <text class="tag" :class="p.stock > 0 ? 'tag-green' : 'tag-gray'">
                        {{ p.stock > 0 ? '可预约' : '已约满' }}
                    </text>
                </view>
                <view class="project-rows">
                    <text class="small gray">当季时间：{{ p.seasonText }}</text>
                    <text class="small gray">计价方式：{{ p.priceMode }}（¥{{ p.priceText }}{{ p.priceMode === '按采摘重量' ? '/斤' : '' }}）</text>
                    <text class="small gray">可约场次：{{ p.session }}</text>
                    <text class="small gray">剩余库存：{{ p.stock }} 人</text>
                </view>
                <button
                    class="btn btn-primary btn-book"
                    :class="{ 'btn-disabled': p.stock <= 0 }"
                    :disabled="p.stock <= 0"
                    @click="goAppointment(p)"
                >立即预约</button>
            </view>
            <empty v-if="!loading && projects.length === 0" text="暂无当季采摘项目" />

            <!-- 评价列表 -->
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
            <empty v-if="!loading && reviews.length === 0" text="暂无评价" />
        </view>
    </view>
</template>

<script>
import { getFarmDetail, getFarmReviews } from '@/common/api.js'
import { imgUrl, priceText, parsePage, requireLogin } from '@/common/util.js'

export default {
    data() {
        return {
            farmId: null,
            farm: null,
            projects: [],
            reviews: [],
            reviewTotal: 0,
            reviewPage: 1,
            loading: true
        }
    },
    onLoad(query) {
        this.farmId = query.id
        this.loadFarm()
        this.loadReviews(true)
    },
    methods: {
        loadFarm() {
            var that = this
            that.loading = true
            getFarmDetail(that.farmId).then(function (res) {
                var imgs = []
                if (res.images) {
                    var arr = String(res.images).split(',')
                    for (var i = 0; i < arr.length; i++) {
                        var s = arr[i].trim()
                        if (s) { imgs.push(imgUrl(s, 'farm' + that.farmId + '_' + i)) }
                    }
                }
                if (imgs.length === 0 && res.coverImage) {
                    imgs.push(imgUrl(res.coverImage, 'farm' + that.farmId))
                }
                res.imageList = imgs
                res.priceText = priceText(res.avgPrice)
                that.farm = res
                var ps = res.projects || []
                that.projects = ps.map(function (p) {
                    p.priceText = priceText(p.price)
                    p.seasonText = (p.seasonStart || '') + ' ~ ' + (p.seasonEnd || '')
                    return p
                })
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
            getFarmReviews(that.farmId, { pageNum: that.reviewPage, pageSize: 10 }).then(function (res) {
                var page = parsePage(res)
                that.reviews = that.reviews.concat(page.list)
                that.reviewTotal = page.total
            }).catch(function () { })
        },
        loadMoreReviews() {
            this.loadReviews(false)
        },
        copyAddress() {
            uni.setClipboardData({
                data: this.farm.address,
                success: function () {
                    uni.showToast({ title: '地址已复制', icon: 'none' })
                }
            })
        },
        callFarm() {
            if (!this.farm.phone) { return }
            uni.makePhoneCall({
                phoneNumber: String(this.farm.phone),
                fail: function () { }
            })
        },
        goAppointment(p) {
            if (!requireLogin()) { return }
            if (p.stock <= 0) {
                uni.showToast({ title: '该项目已约满', icon: 'none' })
                return
            }
            uni.navigateTo({
                url: '/pages/farm/appointment?farmId=' + this.farmId + '&projectId=' + p.id
            })
        }
    }
}
</script>

<style scoped>
.head-swiper {
    height: 400rpx;
}
.head-img {
    width: 100%;
    height: 400rpx;
}
.farm-name {
    font-size: 34rpx;
    font-weight: 700;
    margin-bottom: 12rpx;
}
.farm-tags {
    margin-bottom: 10rpx;
}
.info-row {
    display: flex;
    align-items: flex-start;
    padding: 12rpx 0;
    border-top: 2rpx solid #F5F5F5;
}
.info-label {
    width: 140rpx;
    color: #999;
    font-size: 26rpx;
    flex-shrink: 0;
}
.info-value {
    flex: 1;
    font-size: 26rpx;
    color: #444;
}
.addr-text {
    word-break: break-all;
}
.copy-btn {
    flex-shrink: 0;
    margin-left: 16rpx;
    color: #2E8B57;
    font-size: 24rpx;
    border: 2rpx solid #2E8B57;
    border-radius: 20rpx;
    padding: 2rpx 18rpx;
}
.card-title {
    display: block;
    font-size: 30rpx;
    font-weight: 700;
    margin-bottom: 14rpx;
}
.block-text {
    font-size: 26rpx;
    color: #666;
    line-height: 1.7;
    word-break: break-all;
}
.project-name {
    font-size: 30rpx;
}
.project-rows {
    display: flex;
    flex-direction: column;
    gap: 8rpx;
    margin: 16rpx 0;
}
.btn-book {
    margin-top: 10rpx;
    height: 72rpx;
    line-height: 72rpx;
    font-size: 28rpx;
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
</style>

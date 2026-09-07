<template>
    <view>
        <!-- 状态 tab -->
        <view class="tabs">
            <view
                v-for="t in tabs"
                :key="t.value"
                class="tab-item"
                :class="{ active: status === t.value }"
                @click="onTab(t.value)"
            >{{ t.label }}</view>
        </view>

        <view class="container">
            <!-- 预约卡片 -->
            <view class="card" v-for="a in list" :key="a.id" @click="goDetail(a.id)">
                <view class="flex-between">
                    <text class="bold">{{ a.farmName || '农园' }}</text>
                    <text class="tag" :class="tagClass(a.status)">{{ statusText(a.status) }}</text>
                </view>
                <view class="a-rows">
                    <text class="small gray">项目：{{ a.projectName || '采摘项目' }}</text>
                    <text class="small gray">时间：{{ a.appointDate }} {{ a.session }}</text>
                    <text class="small gray">人数：{{ a.peopleCount }} 人</text>
                    <text class="small gray">联系手机号：{{ a.contactPhone }}</text>
                </view>
                <view class="divider"></view>
                <view class="flex-between">
                    <text class="price">¥{{ a.priceText }}</text>
                    <view class="a-actions">
                        <button
                            v-if="a.status === 0"
                            class="btn btn-mini btn-mini-primary a-btn"
                            size="mini"
                            @click.stop="goPay(a)"
                        >去支付</button>
                        <button
                            v-if="a.status === 1 && canCancel(a)"
                            class="btn btn-mini btn-mini-gray a-btn"
                            size="mini"
                            @click.stop="onCancel(a)"
                        >取消预约</button>
                        <button
                            v-if="a.status === 2"
                            class="btn btn-mini btn-mini-primary a-btn"
                            size="mini"
                            @click.stop="goReview(a)"
                        >去评价</button>
                    </view>
                </view>
            </view>

            <empty v-if="!loading && list.length === 0" text="暂无预约记录" />
            <view v-if="finished && list.length > 0" class="load-tip">没有更多了</view>
        </view>
    </view>
</template>

<script>
import { getMyAppointments, cancelAppointment } from '@/common/api.js'
import { priceText, appointStatusText, appointTagClass, parsePage, canCancelAppointment } from '@/common/util.js'

export default {
    data() {
        return {
            tabs: [
                { label: '全部', value: '' },
                { label: '待支付', value: '0' },
                { label: '待使用', value: '1' },
                { label: '已使用', value: '2' },
                { label: '已取消', value: '3' }
            ],
            status: '',
            list: [],
            pageNum: 1,
            total: 0,
            loading: false,
            finished: false
        }
    },
    onLoad(query) {
        if (query.status !== undefined && query.status !== '') {
            this.status = String(query.status)
        }
        this.load(true)
    },
    onReachBottom() {
        if (!this.finished && !this.loading) {
            this.load(false)
        }
    },
    methods: {
        statusText(s) { return appointStatusText(s) },
        tagClass(s) { return appointTagClass(s) },
        canCancel(a) { return canCancelAppointment(a) },
        load(reset) {
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
            if (that.status !== '') { params.status = that.status }
            getMyAppointments(params).then(function (res) {
                var page = parsePage(res)
                var rows = page.list.map(function (a) {
                    a.priceText = priceText(a.amount)
                    return a
                })
                that.list = reset ? rows : that.list.concat(rows)
                that.total = page.total
                if (that.list.length >= that.total || rows.length === 0) {
                    that.finished = true
                }
                that.loading = false
            }).catch(function () {
                that.loading = false
            })
        },
        onTab(v) {
            if (this.status === v) { return }
            this.status = v
            this.load(true)
        },
        goDetail(id) {
            uni.navigateTo({ url: '/pages/appointment/detail?id=' + id })
        },
        goPay(a) {
            uni.navigateTo({ url: '/pages/appointment/pay?id=' + a.id })
        },
        goReview(a) {
            uni.navigateTo({
                url: '/pages/review/post?relType=farm&relId=' + a.farmId +
                    '&appointmentId=' + a.id + '&name=' + encodeURIComponent(a.farmName || '农园')
            })
        },
        onCancel(a) {
            var that = this
            uni.showModal({
                title: '取消预约',
                content: '确定取消该预约吗？取消后不可恢复。',
                confirmText: '确定取消',
                cancelText: '再想想',
                success: function (r) {
                    if (!r.confirm) { return }
                    cancelAppointment(a.id).then(function () {
                        uni.showToast({ title: '已取消预约', icon: 'success' })
                        that.load(true)
                    }).catch(function () { })
                }
            })
        }
    }
}
</script>

<style scoped>
.a-rows {
    display: flex;
    flex-direction: column;
    gap: 8rpx;
    margin: 16rpx 0;
}
.a-actions {
    display: flex;
    align-items: center;
}
.a-btn {
    margin-left: 16rpx;
}
.load-tip {
    text-align: center;
    color: #999;
    font-size: 24rpx;
    padding: 20rpx 0;
}
</style>

<template>
    <view class="container">
        <!-- 项目信息卡 -->
        <view class="card" v-if="project">
            <view class="flex-between">
                <text class="bold project-name">{{ project.name }}</text>
                <text class="tag tag-green">{{ farm.type }}</text>
            </view>
            <text class="small gray farm-name">{{ farm.name }}</text>
            <view class="project-rows">
                <text class="small gray">当季时间：{{ project.seasonText }}</text>
                <text class="small gray">计价方式：{{ project.priceMode }}（¥{{ project.priceText }}{{ project.priceMode === '按采摘重量' ? '/斤' : '' }}）</text>
                <text class="small gray">剩余库存：{{ project.stock }} 人</text>
            </view>
        </view>

        <!-- 预约信息填写 -->
        <view class="card">
            <view class="form-item">
                <text class="form-label">预约日期</text>
                <picker mode="date" :value="appointDate" :start="minDate" @change="onDateChange">
                    <view class="picker-value" :class="{ placeholder: !appointDate }">
                        {{ appointDate || '请选择日期（仅可选今天之后）' }}
                    </view>
                </picker>
            </view>
            <view class="form-item">
                <text class="form-label">预约场次</text>
                <block v-if="sessions.length > 1">
                    <picker mode="selector" :range="sessions" :value="sessionIndex" @change="onSessionChange">
                        <view class="picker-value">{{ sessions[sessionIndex] }}</view>
                    </picker>
                </block>
                <text v-else class="picker-value">{{ sessions[0] || '暂无场次' }}</text>
            </view>
            <view class="form-item">
                <text class="form-label">预约人数</text>
                <stepper :value="peopleCount" :min="1" :max="maxPeople" @change="onPeopleChange"></stepper>
                <text class="small gray stock-tip">（最多 {{ maxPeople }} 人）</text>
            </view>
            <view class="form-item">
                <text class="form-label">预约人</text>
                <input class="form-input" v-model="contactName" placeholder="请输入预约人姓名" maxlength="20" />
            </view>
            <view class="form-item">
                <text class="form-label">手机号</text>
                <input class="form-input" v-model="contactPhone" type="number" placeholder="请输入联系手机号" maxlength="11" />
            </view>
            <view class="phone-tip">
                <text class="small orange">* 手机号必填，到场后需向商家报出该手机号进行确认</text>
            </view>
        </view>

        <!-- 金额试算 -->
        <view class="card" v-if="project">
            <view class="flex-between">
                <text>金额试算</text>
                <text class="price">{{ amountText }}</text>
            </view>
            <text class="small gray amount-tip">{{ amountTip }}</text>
        </view>

        <!-- 提交 -->
        <button class="btn btn-primary submit-btn" :disabled="submitting" @click="submit">
            {{ submitting ? '提交中...' : '提交预约' }}
        </button>
    </view>
</template>

<script>
import { getFarmDetail, createAppointment } from '@/common/api.js'
import { priceText, fmtDate, requireLogin, isPhone } from '@/common/util.js'

export default {
    data() {
        return {
            farmId: null,
            projectId: null,
            farm: {},
            project: null,
            sessions: ['上午', '下午'],
            sessionIndex: 0,
            appointDate: '',
            peopleCount: 1,
            contactName: '',
            contactPhone: '',
            submitting: false
        }
    },
    computed: {
        minDate() {
            var d = new Date()
            d.setDate(d.getDate() + 1) // 只允许今天之后
            return fmtDate(d)
        },
        maxPeople() {
            if (!this.project) { return 1 }
            var s = Number(this.project.stock) || 1
            return s > 0 ? s : 1
        },
        amountText() {
            if (!this.project) { return '¥0.00' }
            if (this.project.priceMode === '按人头门票') {
                return '¥' + priceText(Number(this.project.price) * this.peopleCount)
            }
            return '¥' + this.project.priceText + '/斤'
        },
        amountTip() {
            if (!this.project) { return '' }
            if (this.project.priceMode === '按采摘重量') { return '按重量计价项目，到场后按实际采摘重量结算' }
            return '按人头门票计价：¥' + this.project.priceText + ' × ' + this.peopleCount + ' 人'
        }
    },
    onLoad(query) {
        var that = this
        that.farmId = query.farmId
        that.projectId = query.projectId
        uni.showLoading({ title: '加载中' })
        getFarmDetail(that.farmId).then(function (res) {
            uni.hideLoading()
            that.farm = res
            var ps = res.projects || []
            for (var i = 0; i < ps.length; i++) {
                if (String(ps[i].id) === String(that.projectId)) {
                    var p = ps[i]
                    p.priceText = priceText(p.price)
                    p.seasonText = (p.seasonStart || '') + ' ~ ' + (p.seasonEnd || '')
                    that.project = p
                    var ss = String(p.session || '上午,下午').split(',')
                    var arr = []
                    for (var j = 0; j < ss.length; j++) {
                        var t = ss[j].trim()
                        if (t) { arr.push(t) }
                    }
                    that.sessions = arr.length ? arr : ['上午']
                    that.sessionIndex = 0
                    return
                }
            }
            uni.showToast({ title: '未找到该采摘项目', icon: 'none' })
            setTimeout(function () { uni.navigateBack() }, 900)
        }).catch(function () {
            uni.hideLoading()
        })
    },
    methods: {
        onDateChange(e) {
            this.appointDate = e.detail.value
        },
        onSessionChange(e) {
            this.sessionIndex = Number(e.detail.value)
        },
        onPeopleChange(v) {
            this.peopleCount = v
        },
        submit() {
            var that = this
            if (!requireLogin()) { return }
            if (!that.project) {
                uni.showToast({ title: '项目信息加载中，请稍候', icon: 'none' })
                return
            }
            if (!that.appointDate) {
                uni.showToast({ title: '请选择预约日期', icon: 'none' })
                return
            }
            var session = that.sessions[that.sessionIndex]
            if (!session) {
                uni.showToast({ title: '请选择预约场次', icon: 'none' })
                return
            }
            if (!that.peopleCount || that.peopleCount < 1) {
                uni.showToast({ title: '请选择预约人数', icon: 'none' })
                return
            }
            if (!that.contactName || !that.contactName.trim()) {
                uni.showToast({ title: '请填写预约人姓名', icon: 'none' })
                return
            }
            if (!isPhone(that.contactPhone)) {
                uni.showToast({ title: '请填写正确的11位手机号', icon: 'none' })
                return
            }
            that.submitting = true
            createAppointment({
                projectId: that.projectId,
                appointDate: that.appointDate,
                session: session,
                peopleCount: that.peopleCount,
                contactName: that.contactName.trim(),
                contactPhone: that.contactPhone
            }).then(function (res) {
                that.submitting = false
                uni.showToast({ title: '预约提交成功', icon: 'success' })
                var id = res.id || res.appointmentId
                setTimeout(function () {
                    uni.redirectTo({ url: '/pages/appointment/pay?id=' + id })
                }, 800)
            }).catch(function () {
                that.submitting = false
            })
        }
    }
}
</script>

<style scoped>
.project-name {
    font-size: 32rpx;
}
.farm-name {
    display: block;
    margin: 8rpx 0 12rpx;
}
.project-rows {
    display: flex;
    flex-direction: column;
    gap: 8rpx;
}
.picker-value {
    font-size: 28rpx;
    color: #333;
}
.picker-value.placeholder {
    color: #BBB;
}
.stock-tip {
    margin-left: 16rpx;
}
.phone-tip {
    padding: 16rpx 0 0;
}
.orange {
    color: #FF8C00;
}
.amount-tip {
    display: block;
    margin-top: 12rpx;
}
.submit-btn {
    margin-top: 40rpx;
    width: 100%;
}
</style>

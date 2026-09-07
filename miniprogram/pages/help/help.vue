<template>
    <view class="container">
        <view class="card">
            <view class="intro">
                <text class="bold green">天津地方农特产推广服务平台</text>
                <text class="small gray intro-text">
                    平台集“农特产线上商城、农园采摘体验预约、内容推广”于一体，汇聚天津本地小站稻、沙窝萝卜、茶淀葡萄等特色农副特产，以及蓟州、西青、静海等区的果园与有机蔬菜农场资源。
                </text>
            </view>
        </view>

        <!-- 常见问题（手风琴） -->
        <view class="card faq" v-for="(f, i) in faqs" :key="i">
            <view class="faq-q" @click="toggle(i)">
                <text class="faq-q-text">{{ f.q }}</text>
                <text class="faq-arrow">{{ f.open ? '∧' : '∨' }}</text>
            </view>
            <view v-if="f.open" class="faq-a">
                <text class="small">{{ f.a }}</text>
            </view>
        </view>
    </view>
</template>

<script>
export default {
    data() {
        return {
            faqs: [
                { q: '如何预约农园采摘？', a: '进入“农园”模块选择农园，在详情页选择当季采摘项目，点击“立即预约”，选择日期、场次与人数，填写预约人姓名与联系手机号，支付（模拟）后即预约成功。到场后向商家报出预留手机号即可确认入园。', open: true },
                { q: '预约后可以取消吗？', a: '待支付的预约可直接取消；待使用的预约需在预约日期前一天的 24:00 前取消，逾期不可取消。已使用或已过期的预约无法取消。' },
                { q: '农园采摘如何计价？', a: '各采摘项目的计价方式由农园设置，分为“按人头门票”（按人数收取门票费用）与“按采摘重量”（到场后按实际采摘重量计费）两类，下单前请留意项目详情中的计价说明。' },
                { q: '下单后如何付款？', a: '课程设计环境使用模拟支付：提交订单后进入支付页点击“确认支付（模拟）”即完成付款，不产生真实资金往来。' },
                { q: '如何申请退款？', a: '在“我的订单”中，待发货或待收货状态的订单可点击“申请退款”，提交后订单进入“退款中”状态，由商家处理。' },
                { q: '商品售后与评价？', a: '订单确认收货后即“已完成”，此时可对订单内商品进行星级与文字评价；采摘体验完成后（商家到园确认）可对农园进行评价。' },
                { q: '收货地址如何管理？', a: '在“我的-收货地址”中可新增、编辑、删除收货地址，并可将某一地址设为默认地址，下单时优先使用默认地址。' }
            ]
        }
    },
    methods: {
        toggle(i) {
            this.$set(this.faqs[i], 'open', !this.faqs[i].open)
        }
    }
}
</script>

<style scoped>
.intro {
    display: flex;
    flex-direction: column;
}
.intro-text {
    margin-top: 14rpx;
    line-height: 1.7;
}
.faq-q {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.faq-q-text {
    font-size: 28rpx;
    font-weight: 700;
}
.faq-arrow {
    color: #999;
    font-size: 26rpx;
    margin-left: 16rpx;
}
.faq-a {
    padding-top: 20rpx;
    line-height: 1.7;
    color: #666;
    border-top: 2rpx solid #F5F5F5;
    margin-top: 20rpx;
}
</style>

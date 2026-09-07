<template>
    <view class="stepper">
        <view class="st-btn" :class="{ disabled: innerValue <= min }" @click="minus">-</view>
        <view class="st-num">{{ innerValue }}</view>
        <view class="st-btn" :class="{ disabled: innerValue >= max }" @click="plus">+</view>
    </view>
</template>

<script>
// 数量步进器
// <stepper :value="qty" :min="1" :max="stock" @change="onQty"></stepper>
export default {
    name: 'stepper',
    props: {
        value: { type: [Number, String], default: 1 },
        min: { type: [Number, String], default: 1 },
        max: { type: [Number, String], default: 999 }
    },
    computed: {
        innerValue() {
            return Number(this.value) || 0
        },
        minNum() {
            return Number(this.min) || 0
        },
        maxNum() {
            return Number(this.max) || 999
        }
    },
    methods: {
        minus() {
            if (this.innerValue <= this.minNum) {
                uni.showToast({ title: '不能再少了', icon: 'none' })
                return
            }
            this.$emit('input', this.innerValue - 1)
            this.$emit('change', this.innerValue - 1)
        },
        plus() {
            if (this.innerValue >= this.maxNum) {
                uni.showToast({ title: '已达上限', icon: 'none' })
                return
            }
            this.$emit('input', this.innerValue + 1)
            this.$emit('change', this.innerValue + 1)
        }
    }
}
</script>

<style scoped>
.stepper {
    display: inline-flex;
    align-items: center;
}
.st-btn {
    width: 56rpx;
    height: 56rpx;
    text-align: center;
    line-height: 52rpx;
    border: 2rpx solid #DDD;
    border-radius: 8rpx;
    color: #666;
    font-size: 32rpx;
    background: #fff;
}
.st-btn.disabled {
    color: #CCC;
    border-color: #EEE;
}
.st-num {
    min-width: 76rpx;
    text-align: center;
    font-size: 30rpx;
    color: #333;
}
</style>

<template>
    <view class="star-rate">
        <text
            v-for="i in 5"
            :key="i"
            class="star"
            :class="{ on: i <= innerValue, off: !readonly }"
            :style="{ fontSize: size + 'rpx' }"
            @click="tapStar(i)"
        >★</text>
        <text v-if="showValue" class="star-value" :style="{ fontSize: (size * 0.6) + 'rpx' }">{{ innerValue }}.0</text>
    </view>
</template>

<script>
// 星级评分：展示用（readonly）或输入用（点击打分）
// <star-rate :value="5" :readonly="true" :size="28"></star-rate>
// <star-rate :value="rating" :size="44" @change="onRate"></star-rate>
export default {
    name: 'star-rate',
    props: {
        value: { type: [Number, String], default: 0 },
        readonly: { type: Boolean, default: false },
        size: { type: [Number, String], default: 32 },
        showValue: { type: Boolean, default: false }
    },
    computed: {
        innerValue() {
            return Number(this.value) || 0
        }
    },
    methods: {
        tapStar(i) {
            if (this.readonly) { return }
            this.$emit('input', i)
            this.$emit('change', i)
        }
    }
}
</script>

<style scoped>
.star-rate {
    display: inline-flex;
    align-items: center;
}
.star {
    color: #DDDDDD;
    margin-right: 4rpx;
}
.star.on {
    color: #FFB800;
}
.star.off {
    cursor: pointer;
}
.star-value {
    color: #FFB800;
    margin-left: 8rpx;
}
</style>

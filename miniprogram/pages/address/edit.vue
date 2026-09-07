<template>
    <view class="container">
        <view class="card">
            <view class="form-item">
                <text class="form-label">联系人</text>
                <input class="form-input" v-model="form.receiver" placeholder="请输入收货人姓名" maxlength="20" />
            </view>
            <view class="form-item">
                <text class="form-label">手机号</text>
                <input class="form-input" v-model="form.phone" type="number" placeholder="请输入11位手机号" maxlength="11" />
            </view>
            <view class="form-item">
                <text class="form-label">所在地区</text>
                <picker mode="selector" :range="districts" :value="districtIndex" @change="onDistrict">
                    <view class="picker-value">天津市 {{ form.district }}</view>
                </picker>
            </view>
            <view class="form-item">
                <text class="form-label">详细地址</text>
                <input class="form-input" v-model="form.detail" placeholder="街道、小区、门牌号等" maxlength="100" />
            </view>
            <view class="form-item">
                <text class="form-label">设为默认</text>
                <switch :checked="form.isDefault === 1" color="#2E8B57" @change="onDefaultChange" style="transform:scale(0.8)" />
            </view>
        </view>

        <button class="btn btn-primary save-btn" :disabled="saving" @click="save">
            {{ saving ? '保存中...' : '保存地址' }}
        </button>
    </view>
</template>

<script>
import { addAddress, updateAddress, getAddresses } from '@/common/api.js'
import { isPhone, DISTRICTS } from '@/common/util.js'

export default {
    data() {
        return {
            id: null,
            districts: DISTRICTS,
            districtIndex: 0, // 省市固定为天津市，仅需选择区县
            form: {
                receiver: '',
                phone: '',
                district: DISTRICTS[0],
                detail: '',
                isDefault: 0
            },
            saving: false
        }
    },
    onLoad(query) {
        var that = this
        if (query.id) {
            that.id = query.id
            uni.showLoading({ title: '加载中' })
            getAddresses().then(function (res) {
                uni.hideLoading()
                var rows = res && res.list ? res.list : (res || [])
                for (var i = 0; i < rows.length; i++) {
                    if (String(rows[i].id) === String(that.id)) {
                        var a = rows[i]
                        that.form = {
                            receiver: a.receiver || '',
                            phone: a.phone || '',
                            district: a.district || DISTRICTS[0],
                            detail: a.detail || '',
                            isDefault: a.isDefault ? 1 : 0
                        }
                        that.districtIndex = DISTRICTS.indexOf(that.form.district)
                        if (that.districtIndex < 0) { that.districtIndex = 0 }
                        break
                    }
                }
            }).catch(function () {
                uni.hideLoading()
            })
        }
    },
    methods: {
        onDistrict(e) {
            this.districtIndex = Number(e.detail.value)
            this.form.district = this.districts[this.districtIndex]
        },
        onDefaultChange(e) {
            this.form.isDefault = e.detail.value ? 1 : 0
        },
        save() {
            var that = this
            var f = that.form
            if (!f.receiver || !f.receiver.trim()) {
                uni.showToast({ title: '请填写联系人', icon: 'none' })
                return
            }
            if (!isPhone(f.phone)) {
                uni.showToast({ title: '请填写正确的11位手机号', icon: 'none' })
                return
            }
            if (!f.district) {
                uni.showToast({ title: '请选择所在地区', icon: 'none' })
                return
            }
            if (!f.detail || !f.detail.trim()) {
                uni.showToast({ title: '请填写详细地址', icon: 'none' })
                return
            }
            var data = {
                receiver: f.receiver.trim(),
                phone: f.phone,
                district: f.district,
                detail: f.detail.trim(),
                isDefault: f.isDefault
            }
            that.saving = true
            var job
            if (that.id) {
                job = updateAddress(that.id, data)
            } else {
                job = addAddress(data)
            }
            job.then(function () {
                that.saving = false
                uni.showToast({ title: '保存成功', icon: 'success' })
                setTimeout(function () {
                    uni.navigateBack()
                }, 800)
            }).catch(function () {
                that.saving = false
            })
        }
    }
}
</script>

<style scoped>
.picker-value {
    font-size: 28rpx;
    color: #333;
}
.save-btn {
    margin-top: 40rpx;
    width: 100%;
}
</style>

<template>
    <view class="container">
        <!-- 头像 -->
        <view class="card">
            <view class="avatar-row" @click="chooseAvatar">
                <image v-if="form.avatar" class="avatar-img" :src="imgUrl(form.avatar)" mode="aspectFill" />
                <view v-else class="avatar-img avatar-text">{{ avatarChar }}</view>
                <view class="avatar-hint">
                    <text class="hint-main">{{ uploading ? '上传中...' : '点击更换头像' }}</text>
                    <text class="hint-sub">支持 jpg/png/webp/gif，不超过 5MB</text>
                </view>
                <text class="avatar-arrow">&gt;</text>
            </view>
        </view>

        <!-- 昵称/手机号 -->
        <view class="card">
            <view class="form-item">
                <text class="form-label">昵称</text>
                <input class="form-input" v-model="form.nickname" placeholder="请输入昵称" maxlength="20" />
            </view>
            <view class="form-item">
                <text class="form-label">手机号</text>
                <input class="form-input" v-model="form.phone" type="number" placeholder="11位手机号，留空则不修改" maxlength="11" />
            </view>
        </view>
        <view class="form-tip">手机号用于下单与预约联系；未认证小程序不支持微信一键取号，请手动输入</view>

        <button class="btn btn-primary save-btn" :disabled="saving" @click="save">
            {{ saving ? '保存中...' : '保存' }}
        </button>
    </view>
</template>

<script>
import { getUserMe, updateUserMe, uploadImage } from '@/common/api.js'
import { isPhone, imgUrl } from '@/common/util.js'

export default {
    data() {
        return {
            form: {
                nickname: '',
                phone: '',
                avatar: ''
            },
            uploading: false,
            saving: false
        }
    },
    computed: {
        avatarChar() {
            var n = this.form.nickname || '用'
            return n.substring(0, 1)
        }
    },
    onLoad() {
        var that = this
        // 先用本地缓存回显，再拉最新覆盖
        var cached = uni.getStorageSync('userInfo') || {}
        that.form = {
            nickname: cached.nickname || '',
            phone: cached.phone || '',
            avatar: cached.avatar || ''
        }
        getUserMe().then(function (res) {
            if (!res) { return }
            uni.setStorageSync('userInfo', res)
            that.form = {
                nickname: res.nickname || '',
                phone: res.phone || '',
                avatar: res.avatar || ''
            }
        }).catch(function () { })
    },
    methods: {
        // 选图并上传，成功后仅暂存路径，点"保存"才写入资料
        chooseAvatar() {
            var that = this
            if (that.uploading || that.saving) { return }
            uni.chooseImage({
                count: 1,
                sizeType: ['compressed'],
                sourceType: ['album', 'camera'],
                success: function (res) {
                    var path = res.tempFilePaths && res.tempFilePaths[0]
                    if (!path) { return }
                    that.uploading = true
                    uploadImage(path).then(function (url) {
                        that.uploading = false
                        that.form.avatar = url
                        uni.showToast({ title: '头像已上传，记得保存', icon: 'none' })
                    }).catch(function () {
                        that.uploading = false
                    })
                }
            })
        },
        save() {
            var that = this
            if (that.saving) { return }
            var nickname = (that.form.nickname || '').trim()
            if (!nickname) {
                uni.showToast({ title: '请填写昵称', icon: 'none' })
                return
            }
            var phone = (that.form.phone || '').trim()
            if (phone && !isPhone(phone)) {
                uni.showToast({ title: '手机号须为1开头的11位数字', icon: 'none' })
                return
            }
            that.saving = true
            updateUserMe({
                nickname: nickname,
                avatar: that.form.avatar || null,
                phone: phone || null
            }).then(function (res) {
                that.saving = false
                uni.setStorageSync('userInfo', res || {})
                uni.showToast({ title: '保存成功', icon: 'success' })
                setTimeout(function () {
                    uni.navigateBack()
                }, 600)
            }).catch(function () {
                that.saving = false
            })
        }
    }
}
</script>

<style scoped>
.avatar-row {
    display: flex;
    align-items: center;
    padding: 10rpx 0;
}
.avatar-img {
    width: 130rpx;
    height: 130rpx;
    border-radius: 50%;
    background: #F5F5F5;
}
.avatar-text {
    background: #E8F5EE;
    color: #2E8B57;
    font-size: 52rpx;
    font-weight: bold;
    text-align: center;
    line-height: 130rpx;
}
.avatar-hint {
    flex: 1;
    display: flex;
    flex-direction: column;
    margin-left: 26rpx;
}
.hint-main {
    font-size: 30rpx;
    color: #333;
    margin-bottom: 8rpx;
}
.hint-sub {
    font-size: 24rpx;
    color: #999;
}
.avatar-arrow {
    color: #CCC;
    font-size: 32rpx;
}
.form-tip {
    font-size: 24rpx;
    color: #999;
    padding: 0 30rpx;
    margin-top: -10rpx;
}
.save-btn {
    margin-top: 40rpx;
}
</style>

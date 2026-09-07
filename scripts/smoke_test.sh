#!/bin/bash
# 天津地方农特产推广服务平台 - 后端冒烟测试
# 用法: 在 Git Bash 中执行 bash smoke_test.sh
# 前置: 数据库已初始化、后端已在 8080 端口运行

BASE=http://localhost:8080
PASS=0; FAIL=0

check() { # $1 名称 $2 条件(0成功)
  if [ "$2" = "0" ]; then PASS=$((PASS+1)); echo "[通过] $1"; else FAIL=$((FAIL+1)); echo "[失败] $1"; fi
}

echo "========== 1. 游客接口 =========="
R=$(curl -s "$BASE/api/home/banners")
echo "$R" | grep -q '"code":200'; check "轮播图" $?
R=$(curl -s "$BASE/api/farms?pageNum=1&pageSize=5")
echo "$R" | grep -q '"code":200'; check "农园列表" $?
FARM_ID=$(echo "$R" | sed -n 's/.*"id":\([0-9]*\).*/\1/p' | head -1)
R=$(curl -s "$BASE/api/farms/$FARM_ID")
echo "$R" | grep -q '"code":200'; check "农园详情($FARM_ID)" $?
R=$(curl -s "$BASE/api/products?pageNum=1&pageSize=5")
echo "$R" | grep -q '"code":200'; check "商品列表" $?
R=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/api/file/placeholder/p1.png")
[ "$R" = "200" ]; check "占位图接口" $?

echo "========== 2. 小程序用户登录与预约链路 =========="
R=$(curl -s -X POST "$BASE/api/auth/wx-login" -H "Content-Type: application/json" -d '{"code":"smoketest001","nickname":"冒烟测试用户"}')
echo "$R" | grep -q '"code":200'; check "微信登录(模拟)" $?
TOKEN=$(echo "$R" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
AUTH="Authorization: Bearer $TOKEN"
echo "  token: ${TOKEN:0:30}..."

# 找一个有库存的采摘项目
R=$(curl -s "$BASE/api/farms/1")
PROJECT_ID=$(echo "$R" | sed -n 's/.*"projects":\[{"id":\([0-9]*\).*/\1/p')
echo "  项目ID: $PROJECT_ID"
TOMORROW=$(date -d "+1 day" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d 2>/dev/null)
R=$(curl -s -X POST "$BASE/api/appointments" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"projectId\":$PROJECT_ID,\"appointDate\":\"$TOMORROW\",\"session\":\"上午\",\"peopleCount\":2,\"contactName\":\"测试用户\",\"contactPhone\":\"13900001111\"}")
echo "$R" | grep -q '"code":200'; check "提交预约" $?
APPT_ID=$(echo "$R" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
echo "  预约ID: $APPT_ID"
R=$(curl -s -X POST "$BASE/api/appointments/$APPT_ID/pay" -H "$AUTH")
echo "$R" | grep -q '"code":200'; check "模拟支付预约" $?

echo "========== 3. 商城购物链路 =========="
R=$(curl -s "$BASE/api/products?pageNum=1&pageSize=1")
PROD_ID=$(echo "$R" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
R=$(curl -s -X POST "$BASE/api/cart" -H "$AUTH" -H "Content-Type: application/json" -d "{\"productId\":$PROD_ID,\"spec\":\"5斤装\",\"quantity\":2}")
echo "$R" | grep -q '"code":200'; check "加入购物车" $?
R=$(curl -s -X POST "$BASE/api/addresses" -H "$AUTH" -H "Content-Type: application/json" -d '{"receiver":"测试收货人","phone":"13900002222","district":"南开区","detail":"测试地址1号","isDefault":1}')
echo "$R" | grep -q '"code":200'; check "新增地址" $?
ADDR_ID=$(echo "$R" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
R=$(curl -s -X POST "$BASE/api/orders" -H "$AUTH" -H "Content-Type: application/json" -d "{\"addressId\":$ADDR_ID,\"remark\":\"冒烟测试\",\"fromCart\":false,\"items\":[{\"productId\":$PROD_ID,\"quantity\":1,\"spec\":\"5斤装\"}]}")
echo "$R" | grep -q '"code":200'; check "提交订单" $?
ORDER_ID=$(echo "$R" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
R=$(curl -s -X POST "$BASE/api/orders/$ORDER_ID/pay" -H "$AUTH")
echo "$R" | grep -q '"code":200'; check "模拟支付订单" $?
R=$(curl -s -X POST "$BASE/api/orders/$ORDER_ID/confirm" -H "$AUTH")
echo "$R" | grep -q '"code":200'; check "确认收货" $?
R=$(curl -s -X POST "$BASE/api/reviews" -H "$AUTH" -H "Content-Type: application/json" -d "{\"relType\":\"product\",\"relId\":$PROD_ID,\"orderId\":$ORDER_ID,\"rating\":5,\"content\":\"冒烟测试好评\"}")
echo "$R" | grep -q '"code":200'; check "商品评价" $?

echo "========== 4. 商家端链路 =========="
R=$(curl -s -X POST "$BASE/api/auth/login" -H "Content-Type: application/json" -d '{"username":"merchant01","password":"merchant123","role":"MERCHANT"}')
echo "$R" | grep -q '"code":200'; check "商家登录" $?
MTOKEN=$(echo "$R" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
MAUTH="Authorization: Bearer $MTOKEN"
R=$(curl -s "$BASE/api/merchant/appointments/unread-count" -H "$MAUTH")
echo "$R" | grep -q '"code":200'; check "商家未读预约通知" $?
R=$(curl -s "$BASE/api/merchant/appointments?pageNum=1&pageSize=5" -H "$MAUTH")
echo "$R" | grep -q '"code":200'; check "商家预约列表(含用户手机号)" $?
R=$(curl -s "$BASE/api/merchant/orders?status=1&pageNum=1&pageSize=5" -H "$MAUTH")
echo "$R" | grep -q '"code":200'; check "商家订单列表" $?

echo "========== 5. 平台管理端链路 =========="
R=$(curl -s -X POST "$BASE/api/auth/login" -H "Content-Type: application/json" -d '{"username":"admin","password":"123456","role":"ADMIN"}')
echo "$R" | grep -q '"code":200'; check "管理员登录" $?
ATOKEN=$(echo "$R" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
AAUTH="Authorization: Bearer $ATOKEN"
R=$(curl -s "$BASE/api/admin/stats/overview" -H "$AAUTH")
echo "$R" | grep -q '"code":200'; check "数据看板统计" $?
R=$(curl -s "$BASE/api/admin/merchants?status=0&pageNum=1" -H "$AAUTH")
echo "$R" | grep -q '"code":200'; check "待审核商家列表" $?
R=$(curl -s "$BASE/api/admin/logs?pageNum=1" -H "$AAUTH")
echo "$R" | grep -q '"code":200'; check "操作日志" $?

echo ""
echo "=========================================="
echo "冒烟测试结果: 通过 $PASS 项, 失败 $FAIL 项"
[ "$FAIL" = "0" ] && echo "✅ 全部通过" || echo "❌ 存在失败项，请检查"

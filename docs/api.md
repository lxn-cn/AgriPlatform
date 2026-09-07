# 天津地方农特产推广服务平台 — 接口契约（v1.0）

> 本文档是后端、管理端、小程序端共同遵守的接口契约。所有端以此为准实现。

## 1. 全局约定

- Base URL：`http://localhost:8080`（真机调试时改为局域网 IP）
- 所有业务接口以 `/api` 开头，遵循 RESTful 风格
- **统一响应结构**：

```json
{ "code": 200, "msg": "success", "data": { } }
```

- `code` 为 200 表示成功；401 未登录/令牌失效；403 无权限；400 业务校验失败（msg 为提示文案）；500 系统异常。
- **分页参数**（GET 查询串）：`pageNum`（默认 1）、`pageSize`（默认 10）。
- **分页返回** `data` 结构：`{ "total": 123, "list": [ ... ] }`

- **鉴权**：除标注【游客可用】的接口外，均需请求头 `Authorization: Bearer <JWT>`。
- JWT payload 含：`role`（`USER` / `MERCHANT` / `ADMIN`）、对应主体 id（`userId` / `merchantId` / `adminId`）、`name`。
- 时间格式：`yyyy-MM-dd HH:mm:ss`；日期：`yyyy-MM-dd`；金额单位元，两位小数。
- 图片字段存相对路径（如 `/api/file/placeholder/p1.png`），前端展示时拼接 Base URL。

## 2. 认证与账号

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/auth/wx-login` | POST | 【游客→用户】小程序登录。入参 `{code, nickname?}`；演示环境后端将 code 模拟为 openid=`mock_<code>`，自动注册并返回 `{token, userInfo}`。 |
| `/api/auth/login` | POST | 管理端登录。入参 `{username, password, role}`，role 取 `ADMIN` 或 `MERCHANT`。返回 `{token, userInfo}`。 |
| `/api/user/me` | GET | 当前用户信息。 |
| `/api/user/me` | PUT | 修改昵称/头像/手机号 `{nickname, avatar, phone}`。 |

演示账号（seed 数据预置）：
- 平台管理员：`admin / 123456`
- 商家：`merchant01 … merchant09 / merchant123`（已通过）；`merchant10 / merchant123`（待审核）
- 小程序：任意 code 即可自动注册（例如 code=`demo001` 对应用户"津门吃货小王"）

## 3. 首页与通用（FR-01）

| 接口 | 方法 | 权限 | 说明 |
|---|---|---|---|
| `/api/home/banners` | GET | 游客 | 轮播图列表（按 sort 升序）。字段：id,title,image,linkType,linkValue |
| `/api/home/notices` | GET | 游客 | 公告列表（最新 N 条）。 |
| `/api/home/recommended` | GET | 游客 | 推荐当季商品（status=1 按销量前 10）。 |
| `/api/home/farms-brief` | GET | 游客 | 首页农园入口卡片（前 6 个）。 |
| `/api/search` | GET | 游客 | 关键词聚合搜索 `?keyword=`，返回 `{products, farms}`。 |

## 4. 农园体验与采摘预约（FR-02）

### 4.1 用户侧（游客可浏览，登录后可预约）

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/farms` | GET | 农园列表。参数：`district`（区县）、`type`（果园/有机蔬菜农场）、`keyword`、`sort`（`rating` 人气/评分、`price_asc`、`price_desc`）+ 分页。卡片字段含：id,name,type,district,coverImage,avgPrice,rating |
| `/api/farms/{id}` | GET | 农园详情：基础信息 + address（供一键复制）、businessHours、phone（一键拨打）、trafficGuide、intro、images、当季项目列表 projects[]。 |
| `/api/farms/{id}/reviews` | GET | 农园评价分页。 |

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/appointments` | POST | 提交预约 `{projectId, appointDate, session(上午/下午), peopleCount, contactName, contactPhone}`。后端校验：日期为未来、场次在项目可约场次内、当日场次剩余库存≥人数。成功返回预约单（status=0 待支付）。 |
| `/api/appointments/my` | GET | 我的预约列表 `?status=&pageNum=&pageSize=`。 |
| `/api/appointments/{id}` | GET | 预约详情（校验归属）。 |
| `/api/appointments/{id}/pay` | POST | 模拟支付 → status=1 待使用，并触发商家通知（merchant_read=0）。 |
| `/api/appointments/{id}/cancel` | POST | 取消预约（仅待支付/待使用可取消；待使用的需在预约日期前一天 24:00 前）。 |
| `/api/reviews` | POST | 评价 `{relType:'farm', relId:farmId, appointmentId, rating:1-5, content}`。仅已使用（status=2）的预约可评价。 |

### 4.2 商家侧（需 MERCHANT 角色，登录主体须为已通过商家）

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/merchant/appointments` | GET | 预约单列表 `?status=&date=&pageNum=`，**含预约人姓名、联系电话、人数、场次**（供到园核对）。 |
| `/api/merchant/appointments/unread-count` | GET | 未读预约通知数（角标）。 |
| `/api/merchant/appointments/{id}/read` | POST | 标记通知已读。 |
| `/api/merchant/appointments/{id}/confirm` | POST | **到园确认**：用户报出预留手机号，商家核对后调用，status→2 已使用。入参可选 `{phoneTail}`（核对用后四位，演示用）。 |
| `/api/merchant/farms` | GET/POST | 本商家农园列表 / 新建农园。 |
| `/api/merchant/farms/{id}` | GET/PUT | 农园详情 / 修改（含 trafficGuide 交通指引）。 |
| `/api/merchant/picking-projects` | GET/POST | 本商家采摘项目列表（按 farmId 查）/ 新建。 |
| `/api/merchant/picking-projects/{id}` | PUT/DELETE | 修改（含场次库存）/下架。 |

## 5. 商城购物（FR-03）

### 5.1 用户侧

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/categories` | GET | 【游客】分类树（两级）。 |
| `/api/products` | GET | 【游客】商品列表 `?categoryId=&keyword=&sort=price_asc/price_desc/sales&pageNum=`。 |
| `/api/products/{id}` | GET | 【游客】商品详情（含 specs 规格列表、origin、merchantName、images）。 |
| `/api/products/{id}/reviews` | GET | 【游客】商品评价分页。 |
| `/api/products/{id}/favorite` | POST / DELETE | 收藏 / 取消收藏。 |
| `/api/favorites/my` | GET | 我的收藏（含商品快照，可直接加购）。 |
| `/api/cart` | GET | 购物车列表（含实时小计、合计）。 |
| `/api/cart` | POST | 加入购物车 `{productId, spec, quantity}`。 |
| `/api/cart/{id}` | PUT | 修改数量/勾选 `{quantity, checked}`。 |
| `/api/cart/{id}` | DELETE | 删除购物车行。 |
| `/api/orders` | POST | 提交订单 `{addressId, remark, items:[{productId, quantity, spec}], fromCart:bool}`。校验库存；快照地址与商品价格；生成订单号 `SOyyyyMMddHHmmss+随机`。 |
| `/api/orders/my` | GET | 我的订单 `?status=&pageNum=`（status：0待付款/1待发货/2待收货/3已完成/4已取消/5退款中/6已退款）。 |
| `/api/orders/{id}` | GET | 订单详情（含 items 明细）。 |
| `/api/orders/{id}/pay` | POST | 模拟支付 → 待发货（扣库存、加销量）。 |
| `/api/orders/{id}/cancel` | POST | 取消订单（仅待付款可取消）。 |
| `/api/orders/{id}/confirm` | POST | 确认收货 → 已完成。 |
| `/api/orders/{id}/refund` | POST | 申请退款 `{reason}`（待发货/待收货可申请）→ 退款中。 |
| `/api/reviews` | POST | 商品评价 `{relType:'product', relId:productId, orderId, rating, content}`。仅已完成订单可评价。 |

### 5.2 商家侧

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/merchant/products` | GET/POST | 本商家商品列表 / 新建（可上架 1、下架 0、待审核 2）。 |
| `/api/merchant/products/{id}` | GET/PUT/DELETE | 商品详情 / 修改 / 删除（逻辑下架）。 |
| `/api/merchant/orders` | GET | 本商家订单 `?status=&pageNum=`（含明细，通过 order_item→product 归属过滤）。 |
| `/api/merchant/orders/{id}/ship` | POST | 发货 → 待收货。 |
| `/api/merchant/orders/{id}/refund-agree` | POST | 同意退款 → 已退款（回滚库存）。 |
| `/api/merchant/stats` | GET | 经营统计：销量、销售额、预约人次、近 7 日趋势（供图表）。 |

## 6. 个人中心（FR-04）

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/addresses` | GET/POST | 地址列表 / 新增 `{receiver, phone, district, detail, isDefault}`（province/city 默认天津市）。 |
| `/api/addresses/{id}` | PUT/DELETE | 修改 / 删除。 |
| `/api/addresses/{id}/default` | POST | 设为默认。 |
| `/api/feedback` | POST | 意见反馈 `{content, contact}`。 |

## 7. 商家入驻（FR-05-01，无需登录）

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/merchant/apply` | POST | 入驻申请 `{username, password, name, licenseInfo, contact, phone, intro}`。账号唯一性校验；status=0 待审核。 |
| `/api/merchant/profile` | GET/PUT | 已登录商家：查看 / 维护店铺信息。 |

## 8. 平台管理（FR-06，ADMIN 角色）

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/admin/merchants` | GET | 商家列表 `?status=&pageNum=`。 |
| `/api/admin/merchants/{id}/audit` | POST | 审核 `{pass:bool, reason}` → 已通过 / 驳回（记录 oper_log）。 |
| `/api/admin/merchants/{id}/ban` / `unban` | POST | 封禁 / 解禁。 |
| `/api/admin/users` | GET | 用户列表 `?keyword=&pageNum=`（手机号脱敏展示：138****0001）。 |
| `/api/admin/users/{id}/status` | POST | 启用/禁用用户。 |
| `/api/admin/products` | GET | 全平台商品 `?status=&keyword=`。 |
| `/api/admin/products/{id}/force-off` | POST | 违规强制下架（记录日志）。 |
| `/api/admin/banners` | GET/POST/PUT/DELETE | 轮播图维护。 |
| `/api/admin/notices` | GET/POST/PUT/DELETE | 公告维护。 |
| `/api/admin/categories` | GET/POST/PUT/DELETE | 分类维护。 |
| `/api/admin/orders` | GET | 全平台订单总览 `?status=&orderNo=&pageNum=`。 |
| `/api/admin/appointments` | GET | 全平台预约总览 `?status=&pageNum=`。 |
| `/api/admin/stats/overview` | GET | 总交易额、总订单量、总预约量、用户总数 + 近 7 日订单量/预约量序列 + 分类销售额占比（供图表）。 |
| `/api/admin/feedbacks` | GET | 反馈列表；`/{id}/reply` POST 回复。 |
| `/api/admin/logs` | GET | 操作日志 `?pageNum=`。 |
| `/api/admin/admins` | GET/POST/PUT | 管理员账号管理（SUPER 角色可用）。 |

## 9. 占位图服务（开发演示用）

| 接口 | 方法 | 说明 |
|---|---|---|
| `/api/file/placeholder/{seed}.png` | GET | 【游客】按 seed 生成纯色 + 文字的 PNG 占位图（如 `p1.png`、`farm3.png`、`banner1.png`），避免依赖外部图片资源。Content-Type: image/png。 |

## 10. 非功能实现约定

- 密码：BCrypt 单向加密存储。
- 登录态：JWT（HS256，密钥配置于 application.yml，过期 7 天）；拦截器按 `/api/merchant/**`、`/api/admin/**` 前缀做角色隔离。
- 手机号在管理端列表返回时脱敏。
- 关键操作（商家审核、封禁、退款、强制下架、到园确认）写入 oper_log。
- SQL 一律 MyBatis-Plus 预编译，禁止拼接。
- Redis 用途：登录 token 黑名单/续期（可选实现）、首页轮播与公告缓存（可 5 分钟 TTL）。

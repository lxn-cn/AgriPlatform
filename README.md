# 天津地方农特产推广服务平台

基于《需求规格说明书》实现的课程设计项目：集"农特产线上商城、农园采摘体验预约、内容推广"于一体的本地化服务平台。

## 技术栈

| 端 | 技术 | 目录 |
|---|---|---|
| 用户端 | uni-app（发布为微信小程序） | `miniprogram/` |
| 管理端 | Vue 3 + Element Plus + Axios + ECharts | `admin-web/` |
| 服务端 | Spring Boot 2.7 + MyBatis-Plus + JWT | `backend/` |
| 数据库 | MySQL 5.6+（utf8mb4） | `db/` |
| 缓存 | Redis（首页轮播/公告缓存） | — |

## 环境要求

- JDK 1.8 及以上、Maven 3.6+
- MySQL 5.6 及以上（运行中）
- Redis（运行中，默认 6379 无密码）
- Node.js 12.1 及以上（管理端构建）
- HBuilderX（运行小程序端）+ 微信开发者工具
- Chrome / Edge 浏览器

## 环境变量配置

敏感配置（数据库密码、微信密钥等）**不写入仓库**，通过环境变量注入。首次拉取项目后请设置：

| 环境变量 | 必填 | 说明 |
|---|---|---|
| `DB_PASSWORD` | ✅ | 本机 MySQL 的 root 密码（每人自己的） |
| `WECHAT_SECRET` | ✅ | 微信小程序测试号密钥（**向组长索取**） |
| `DB_USERNAME` | 否 | 默认 `root` |
| `WECHAT_APPID` | 否 | 默认测试号 appid |
| `JWT_SECRET` | 否 | 本地开发用默认值即可，生产环境必须覆盖 |

**Windows（PowerShell，永久生效，设完重启 IDEA/终端）：**

```powershell
setx DB_PASSWORD "你的MySQL密码"
setx WECHAT_SECRET "向组长索取"
```

**macOS / Linux（加到 ~/.zshrc 或 ~/.bashrc）：**

```bash
export DB_PASSWORD="你的MySQL密码"
export WECHAT_SECRET="向组长索取"
```

IDEA 中也可只在运行配置里设置：Run → Edit Configurations → Environment variables。

## 快速启动

### 1. 初始化数据库

```bash
mysql -u root -p < db/schema.sql
mysql -u root -p < db/seed.sql
```

### 2. 启动后端（端口 8080）

```bash
cd backend
# 先按上方「环境变量配置」设置 DB_PASSWORD
mvn spring-boot:run
```

### 3. 启动管理端（端口 5173）

```bash
cd admin-web
npm install
npm run dev
```

浏览器访问 http://localhost:5173

### 4. 运行小程序端

1. 用 HBuilderX 打开 `miniprogram/` 目录
2. 菜单"运行 → 运行到小程序模拟器 → 微信开发者工具"
3. 真机调试时把 `common/config.js` 的 `BASE_URL` 改为电脑局域网 IP（如 `http://192.168.x.x:8080`），并确保手机与电脑同一网络

## 演示账号

| 角色 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 平台管理员 | admin | 123456 | 管理端登录，角色选"管理员" |
| 商家 | merchant01 ~ merchant09 | merchant123 | 管理端登录，角色选"商家" |
| 待审核商家 | merchant10 | merchant123 | 演示入驻审核流程 |
| 小程序用户 | 无需注册 | — | 登录页输入昵称，一键微信登录（演示模拟）；或用 code=demo001~demo005 登录预置用户 |

## 三条核心业务链路（验收演示路径）

### 链路一：农园采摘预约

小程序登录 → 农园列表（区县/类型筛选）→ 农园详情（查看地址、一键复制、交通指引）→ 选择采摘项目 → 提交预约（填姓名+手机号）→ 模拟支付 → 商家端收到预约通知（含预约人、电话、场次、人数）→ 用户到园报手机号，商家在预约管理中核对并"到园确认" → 预约状态变"已使用" → 用户发布采摘评价。

### 链路二：商城购物

小程序登录 → 商城浏览/搜索 → 商品详情（选规格）→ 加入购物车/立即购买 → 提交订单（选收货地址）→ 模拟支付 → 商家端订单管理执行"发货" → 用户"确认收货" → 用户发布商品评价。

### 链路三：商家入驻

管理端登录页点"商家入驻申请"（或直接用 merchant10）→ 填写资质提交 → 平台管理员在"商家审核"中通过 → 商家登录 → 上架商品、发布农园与采摘项目 → 小程序端可见。

## 目录结构

```
AgriPlatform/
├── backend/         # Spring Boot 后端（Controller-Service-Mapper 分层）
├── admin-web/       # Vue3 管理端（商家工作台 + 平台管理）
├── miniprogram/     # uni-app 小程序用户端
├── db/              # schema.sql（建库建表）、seed.sql（演示数据）、gen_seed.py（数据生成脚本）
├── docs/            # api.md 接口文档
├── requirements.txt # 需求规格说明书导出文本
└── README.md
```

## 其他说明

- 支付为**模拟支付**，不接入真实渠道。
- 农园位置以**文字地址**展示，支持一键复制，不使用定位与地图。
- 图片使用后端占位图接口 `/api/file/placeholder/{seed}.png` 动态生成，无需准备图片资源。
- 手机号在管理端列表中脱敏展示；关键操作记录操作日志。

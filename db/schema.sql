-- =====================================================================
-- 天津地方农特产推广服务平台 数据库结构
-- 兼容 MySQL 5.6 / 8.0，字符集 utf8mb4
-- =====================================================================
CREATE DATABASE IF NOT EXISTS agri_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE agri_platform;

DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS merchant;
DROP TABLE IF EXISTS farm;
DROP TABLE IF EXISTS picking_project;
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS banner;
DROP TABLE IF EXISTS notice;
DROP TABLE IF EXISTS sys_admin;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS oper_log;

-- 用户表
CREATE TABLE user (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  openid      VARCHAR(64)  NOT NULL COMMENT '微信openid（演示环境为模拟值',
  nickname    VARCHAR(64)  DEFAULT '' COMMENT '昵称',
  avatar      VARCHAR(255) DEFAULT '' COMMENT '头像URL',
  phone       VARCHAR(20)  DEFAULT '' COMMENT '绑定手机号',
  status      TINYINT      NOT NULL DEFAULT 1 COMMENT '1正常 0禁用',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_openid (openid)
) ENGINE=InnoDB COMMENT='平台注册用户';

-- 收货地址表
CREATE TABLE address (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT       NOT NULL,
  receiver    VARCHAR(32)  NOT NULL COMMENT '联系人',
  phone       VARCHAR(20)  NOT NULL COMMENT '电话',
  province    VARCHAR(32)  DEFAULT '天津市',
  city        VARCHAR(32)  DEFAULT '天津市',
  district    VARCHAR(32)  NOT NULL COMMENT '区',
  detail      VARCHAR(255) NOT NULL COMMENT '详细地址',
  is_default  TINYINT      NOT NULL DEFAULT 0 COMMENT '1默认地址',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_user (user_id)
) ENGINE=InnoDB COMMENT='用户收货地址';

-- 商家表（农户/合作社/农园经营者，也是管理端登录账号）
CREATE TABLE merchant (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(32)  NOT NULL COMMENT '管理端登录账号',
  password_hash  VARCHAR(100) NOT NULL COMMENT 'BCrypt加密密码',
  name           VARCHAR(64)  NOT NULL COMMENT '商家/店铺名称',
  license_info   VARCHAR(255) DEFAULT '' COMMENT '资质信息（营业执照、经营许可证等）',
  contact        VARCHAR(32)  DEFAULT '' COMMENT '联系人',
  phone          VARCHAR(20)  DEFAULT '' COMMENT '联系电话',
  intro          VARCHAR(500) DEFAULT '' COMMENT '商家简介',
  status         TINYINT      NOT NULL DEFAULT 0 COMMENT '0待审核 1已通过 2已封禁',
  reject_reason  VARCHAR(255) DEFAULT '' COMMENT '驳回原因',
  create_time    DATETIME     DEFAULT CURRENT_TIMESTAMP,
  update_time    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_username (username)
) ENGINE=InnoDB COMMENT='商家';

-- 农园表（果园/有机蔬菜农场）
CREATE TABLE farm (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  merchant_id    BIGINT        NOT NULL,
  name           VARCHAR(64)   NOT NULL COMMENT '农园名称',
  type           VARCHAR(16)   NOT NULL DEFAULT '果园' COMMENT '果园/有机蔬菜农场',
  district       VARCHAR(16)   NOT NULL COMMENT '所在区县',
  address        VARCHAR(255)  NOT NULL COMMENT '详细地址（文字形式，供复制）',
  business_hours VARCHAR(64)   DEFAULT '08:30-17:00' COMMENT '营业时间',
  intro          TEXT          COMMENT '图文简介',
  cover_image    VARCHAR(255)  DEFAULT '' COMMENT '封面图路径',
  images         VARCHAR(1000) DEFAULT '' COMMENT '详情图，逗号分隔',
  avg_price      DECIMAL(10,2) DEFAULT 0 COMMENT '人均价格',
  rating         DECIMAL(2,1)  DEFAULT 5.0 COMMENT '评分',
  traffic_guide  VARCHAR(500)  DEFAULT '' COMMENT '交通指引（公交路线、自驾提示）',
  status         TINYINT       NOT NULL DEFAULT 1 COMMENT '1上架 0下架',
  create_time    DATETIME      DEFAULT CURRENT_TIMESTAMP,
  update_time    DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_merchant (merchant_id),
  KEY idx_district (district)
) ENGINE=InnoDB COMMENT='农园';

-- 采摘项目表
CREATE TABLE picking_project (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  farm_id      BIGINT        NOT NULL,
  name         VARCHAR(64)   NOT NULL COMMENT '品种名称，如红富士苹果采摘',
  season_start DATE          COMMENT '当季开始',
  season_end   DATE          COMMENT '当季结束',
  price_mode   VARCHAR(16)   NOT NULL DEFAULT '按人头门票' COMMENT '按人头门票/按采摘重量',
  price        DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '价格（门票价或每斤价）',
  session      VARCHAR(16)   NOT NULL DEFAULT '上午,下午' COMMENT '可约场次，逗号分隔',
  stock        INT           NOT NULL DEFAULT 50 COMMENT '场次库存（每场次可约总人数）',
  status       TINYINT       NOT NULL DEFAULT 1 COMMENT '1上架 0下架',
  create_time  DATETIME       DEFAULT CURRENT_TIMESTAMP,
  update_time  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_farm (farm_id)
) ENGINE=InnoDB COMMENT='采摘项目';

-- 预约单表
CREATE TABLE appointment (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  appointment_no VARCHAR(32)  NOT NULL COMMENT '预约编号',
  user_id        BIGINT       NOT NULL,
  farm_id        BIGINT       NOT NULL,
  project_id     BIGINT       NOT NULL,
  appoint_date   DATE         NOT NULL COMMENT '预约日期',
  session        VARCHAR(8)   NOT NULL COMMENT '上午/下午',
  people_count   INT          NOT NULL DEFAULT 1 COMMENT '人数',
  amount         DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '金额',
  contact_name   VARCHAR(32)  NOT NULL COMMENT '预约人姓名',
  contact_phone  VARCHAR(20)  NOT NULL COMMENT '联系电话（供商家到园核对）',
  status         TINYINT      NOT NULL DEFAULT 0 COMMENT '0待支付 1待使用 2已使用 3已取消 4已过期',
  merchant_read  TINYINT      NOT NULL DEFAULT 0 COMMENT '商家端已读标记',
  create_time    DATETIME     DEFAULT CURRENT_TIMESTAMP,
  pay_time       DATETIME     COMMENT '支付时间',
  confirm_time   DATETIME     COMMENT '到园确认时间',
  cancel_time    DATETIME     COMMENT '取消时间',
  UNIQUE KEY uk_no (appointment_no),
  KEY idx_user (user_id),
  KEY idx_farm (farm_id),
  KEY idx_status (status)
) ENGINE=InnoDB COMMENT='预约单';

-- 商品分类表（支持两级）
CREATE TABLE category (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(32) NOT NULL,
  parent_id   BIGINT      NOT NULL DEFAULT 0 COMMENT '父级id，0为一级分类',
  sort        INT         NOT NULL DEFAULT 0,
  status      TINYINT     NOT NULL DEFAULT 1,
  create_time DATETIME    DEFAULT CURRENT_TIMESTAMP,
  KEY idx_parent (parent_id)
) ENGINE=InnoDB COMMENT='商品分类';

-- 商品表
CREATE TABLE product (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  merchant_id  BIGINT        NOT NULL,
  category_id  BIGINT        NOT NULL,
  name         VARCHAR(128)  NOT NULL,
  main_image   VARCHAR(255)  DEFAULT '' COMMENT '主图路径',
  images       VARCHAR(1000) DEFAULT '' COMMENT '详情图，逗号分隔',
  price        DECIMAL(10,2) NOT NULL DEFAULT 0,
  specs        VARCHAR(255)  DEFAULT '' COMMENT '可选规格，如 5斤装,10斤装',
  stock        INT           NOT NULL DEFAULT 0,
  sales        INT           NOT NULL DEFAULT 0 COMMENT '销量',
  origin       VARCHAR(64)   DEFAULT '' COMMENT '产地',
  description  TEXT          COMMENT '图文详情',
  status       TINYINT       NOT NULL DEFAULT 1 COMMENT '1上架 0下架 2待审核',
  create_time  DATETIME      DEFAULT CURRENT_TIMESTAMP,
  update_time  DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_merchant (merchant_id),
  KEY idx_category (category_id),
  KEY idx_status (status)
) ENGINE=InnoDB COMMENT='商品';

-- 购物车表
CREATE TABLE cart (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT      NOT NULL,
  product_id  BIGINT      NOT NULL,
  spec        VARCHAR(64) DEFAULT '',
  quantity    INT         NOT NULL DEFAULT 1,
  checked     TINYINT     NOT NULL DEFAULT 1 COMMENT '勾选结算标记',
  create_time DATETIME    DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_user (user_id)
) ENGINE=InnoDB COMMENT='购物车';

-- 订单主表
CREATE TABLE orders (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_no     VARCHAR(32)  NOT NULL COMMENT '订单号',
  user_id      BIGINT       NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status       TINYINT      NOT NULL DEFAULT 0 COMMENT '0待付款 1待发货 2待收货 3已完成 4已取消 5退款中 6已退款',
  receiver     VARCHAR(32)  NOT NULL COMMENT '收货人（快照）',
  phone        VARCHAR(20)  NOT NULL COMMENT '收货电话（快照）',
  address      VARCHAR(255) NOT NULL COMMENT '收货地址（快照）',
  remark       VARCHAR(255) DEFAULT '' COMMENT '买家留言',
  refund_reason VARCHAR(255) DEFAULT '' COMMENT '退款原因',
  create_time  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  pay_time     DATETIME     COMMENT '支付时间',
  ship_time    DATETIME     COMMENT '发货时间',
  finish_time  DATETIME     COMMENT '完成时间',
  cancel_time  DATETIME     COMMENT '取消时间',
  UNIQUE KEY uk_no (order_no),
  KEY idx_user (user_id),
  KEY idx_status (status)
) ENGINE=InnoDB COMMENT='订单主表';

-- 订单明细表
CREATE TABLE order_item (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id     BIGINT        NOT NULL,
  product_id   BIGINT        NOT NULL,
  product_name VARCHAR(128)  NOT NULL COMMENT '商品快照',
  main_image   VARCHAR(255)  DEFAULT '',
  price        DECIMAL(10,2) NOT NULL COMMENT '成交单价快照',
  quantity     INT           NOT NULL DEFAULT 1,
  spec         VARCHAR(64)   DEFAULT '',
  KEY idx_order (order_id)
) ENGINE=InnoDB COMMENT='订单明细';

-- 评价表（商品/农园通用：关联类型+关联id）
CREATE TABLE review (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  rel_type    VARCHAR(8)   NOT NULL COMMENT 'product/farm',
  rel_id      BIGINT       NOT NULL,
  user_id     BIGINT       NOT NULL,
  order_id    BIGINT       DEFAULT NULL COMMENT '商品评价关联的订单',
  appointment_id BIGINT    DEFAULT NULL COMMENT '农园评价关联的预约单',
  rating      TINYINT      NOT NULL DEFAULT 5 COMMENT '1-5星',
  content     VARCHAR(500) DEFAULT '',
  images      VARCHAR(1000) DEFAULT '',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
  KEY idx_rel (rel_type, rel_id),
  KEY idx_user (user_id)
) ENGINE=InnoDB COMMENT='评价';

-- 轮播图表
CREATE TABLE banner (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  title      VARCHAR(64)  DEFAULT '',
  image      VARCHAR(255) NOT NULL,
  link_type  VARCHAR(16)  DEFAULT '' COMMENT 'product/farm/notice/none',
  link_value VARCHAR(64)  DEFAULT '' COMMENT '跳转目标id',
  sort       INT          NOT NULL DEFAULT 0,
  status     TINYINT      NOT NULL DEFAULT 1,
  KEY idx_sort (sort)
) ENGINE=InnoDB COMMENT='首页轮播图';

-- 公告表
CREATE TABLE notice (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(128) NOT NULL,
  content      TEXT,
  publish_time DATETIME    DEFAULT CURRENT_TIMESTAMP,
  status       TINYINT     NOT NULL DEFAULT 1 COMMENT '1发布 0下线',
  KEY idx_time (publish_time)
) ENGINE=InnoDB COMMENT='平台公告';

-- 系统管理员表
CREATE TABLE sys_admin (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(32)  NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  name          VARCHAR(32)  DEFAULT '',
  role          VARCHAR(16)  NOT NULL DEFAULT 'ADMIN' COMMENT 'ADMIN/SUPER',
  status        TINYINT     NOT NULL DEFAULT 1,
  create_time   DATETIME    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_username (username)
) ENGINE=InnoDB COMMENT='系统管理员';

-- 意见反馈表
CREATE TABLE feedback (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT       NOT NULL,
  content     VARCHAR(1000) NOT NULL,
  contact     VARCHAR(64)  DEFAULT '',
  status      TINYINT      NOT NULL DEFAULT 0 COMMENT '0待处理 1已处理',
  reply       VARCHAR(500) DEFAULT '',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
  KEY idx_user (user_id)
) ENGINE=InnoDB COMMENT='意见反馈';

-- 操作日志表（审核、封禁、退款等关键操作）
CREATE TABLE oper_log (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  operator_type VARCHAR(16) NOT NULL COMMENT 'ADMIN/MERCHANT/USER',
  operator_id   BIGINT      NOT NULL,
  operator_name VARCHAR(32) DEFAULT '',
  action        VARCHAR(64) NOT NULL,
  detail        VARCHAR(500) DEFAULT '',
  create_time   DATETIME    DEFAULT CURRENT_TIMESTAMP,
  KEY idx_operator (operator_type, operator_id)
) ENGINE=InnoDB COMMENT='操作日志';

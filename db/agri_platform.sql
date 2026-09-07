/*
 Navicat Premium Dump SQL

 Source Server         : MySQL
 Source Server Type    : MySQL
 Source Server Version : 50613 (5.6.13)
 Source Host           : localhost:3306
 Source Schema         : agri_platform

 Target Server Type    : MySQL
 Target Server Version : 50613 (5.6.13)
 File Encoding         : 65001

 Date: 07/09/2026 14:35:27
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `receiver` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '电话',
  `province` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '天津市',
  `city` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '天津市',
  `district` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区',
  `detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '详细地址',
  `is_default` tinyint(4) NOT NULL DEFAULT 0 COMMENT '1默认地址',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户收货地址' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, 1, '王先生', '13911110001', '天津市', '天津市', '南开区', '长江道与红旗路交口融创中心3-1-502', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `address` VALUES (2, 2, '李女士', '13911110002', '天津市', '天津市', '河西区', '友谊南路与潭江道交口万科水晶城12-2-801', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `address` VALUES (3, 3, '张大爷', '13911110003', '天津市', '天津市', '河东区', '卫国道红星大厦B座1803', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for appointment
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `appointment_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '预约编号',
  `user_id` bigint(20) NOT NULL,
  `farm_id` bigint(20) NOT NULL,
  `project_id` bigint(20) NOT NULL,
  `appoint_date` date NOT NULL COMMENT '预约日期',
  `session` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '上午/下午',
  `people_count` int(11) NOT NULL DEFAULT 1 COMMENT '人数',
  `amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `contact_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '预约人姓名',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '联系电话（供商家到园核对）',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0待支付 1待使用 2已使用 3已取消 4已过期',
  `merchant_read` tinyint(4) NOT NULL DEFAULT 0 COMMENT '商家端已读标记',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '到园确认时间',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_no`(`appointment_no`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE,
  INDEX `idx_farm`(`farm_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '预约单' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of appointment
-- ----------------------------
INSERT INTO `appointment` VALUES (1, 'AP2026202609000000', 1, 26, 29, '2026-08-24', '上午', 5, 118.70, '王先生', '13911110001', 1, 1, '2026-08-14 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (2, 'AP2026202609000054', 3, 8, 7, '2026-09-09', '上午', 4, 273.60, '张大爷', '13911110003', 2, 1, '2026-08-13 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (3, 'AP2026202609000108', 2, 30, 38, '2026-09-19', '下午', 4, 158.10, '李女士', '13911110002', 0, 0, '2026-08-18 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (4, 'AP2026202609000162', 4, 4, 18, '2026-09-12', '上午', 1, 242.50, '刘女士', '13911110004', 2, 1, '2026-08-05 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (5, 'AP2026202609000216', 1, 10, 44, '2026-08-29', '上午', 1, 212.00, '王先生', '13911110001', 1, 1, '2026-08-09 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (6, 'AP2026202609000270', 3, 1, 29, '2026-08-22', '下午', 5, 118.20, '张大爷', '13911110003', 1, 1, '2026-08-23 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (7, 'AP2026202609000324', 3, 7, 41, '2026-09-02', '下午', 6, 195.60, '张大爷', '13911110003', 2, 0, '2026-09-01 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (8, 'AP2026202609000378', 2, 9, 36, '2026-09-24', '下午', 4, 33.80, '李女士', '13911110002', 1, 1, '2026-08-18 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (9, 'AP2026202609000432', 2, 5, 9, '2026-09-07', '上午', 1, 281.40, '李女士', '13911110002', 2, 0, '2026-08-25 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (10, 'AP2026202609000486', 2, 12, 28, '2026-09-30', '上午', 4, 150.80, '李女士', '13911110002', 2, 0, '2026-08-22 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (11, 'AP2026202609000540', 3, 30, 38, '2026-09-05', '下午', 3, 66.40, '张大爷', '13911110003', 1, 1, '2026-08-08 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (12, 'AP2026202609000594', 3, 21, 27, '2026-09-20', '下午', 3, 266.50, '张大爷', '13911110003', 3, 0, '2026-08-25 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (13, 'AP2026202609000648', 5, 7, 31, '2026-09-19', '上午', 3, 62.20, '陈先生', '13911110005', 0, 0, '2026-08-18 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (14, 'AP2026202609000702', 4, 2, 48, '2026-09-28', '上午', 5, 197.40, '刘女士', '13911110004', 1, 1, '2026-08-31 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (15, 'AP2026202609000756', 1, 15, 18, '2026-09-27', '上午', 1, 223.60, '王先生', '13911110001', 1, 1, '2026-08-11 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (16, 'AP2026202609000810', 1, 5, 27, '2026-09-16', '下午', 5, 82.20, '王先生', '13911110001', 2, 1, '2026-08-15 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (17, 'AP2026202609000864', 4, 23, 40, '2026-09-16', '上午', 5, 134.70, '刘女士', '13911110004', 3, 1, '2026-08-09 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (18, 'AP2026202609000918', 4, 27, 2, '2026-09-17', '下午', 3, 299.40, '刘女士', '13911110004', 1, 1, '2026-08-05 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (19, 'AP2026202609000972', 1, 6, 48, '2026-09-22', '下午', 3, 87.90, '王先生', '13911110001', 1, 1, '2026-08-31 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (20, 'AP2026202609001026', 3, 28, 31, '2026-09-24', '上午', 5, 36.50, '张大爷', '13911110003', 4, 1, '2026-09-01 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (21, 'AP2026202609001080', 5, 18, 35, '2026-10-02', '上午', 3, 64.00, '陈先生', '13911110005', 0, 1, '2026-08-19 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (22, 'AP2026202609001134', 5, 16, 35, '2026-09-04', '下午', 6, 88.30, '陈先生', '13911110005', 2, 0, '2026-08-07 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (23, 'AP2026202609001188', 2, 12, 38, '2026-09-14', '上午', 3, 278.70, '李女士', '13911110002', 2, 1, '2026-08-25 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (24, 'AP2026202609001242', 1, 12, 17, '2026-08-09', '上午', 4, 38.40, '王先生', '13911110001', 4, 1, '2026-08-30 15:00:00', NULL, NULL, NULL);
INSERT INTO `appointment` VALUES (25, 'AP2026202609001296', 4, 17, 12, '2026-09-14', '上午', 5, 223.60, '刘女士', '13911110004', 2, 0, '2026-08-25 15:00:00', NULL, NULL, NULL);

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `link_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT 'product/farm/notice/none',
  `link_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '跳转目标id',
  `sort` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sort`(`sort`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '首页轮播图' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of banner
-- ----------------------------
INSERT INTO `banner` VALUES (1, '金秋采摘季·蓟州苹果红了', '/api/file/placeholder/banner1.png', 'product', '1', 1, 1);
INSERT INTO `banner` VALUES (2, '茶淀玫瑰香葡萄限时特惠', '/api/file/placeholder/banner2.png', 'product', '1', 2, 1);
INSERT INTO `banner` VALUES (3, '沙窝萝卜·非遗美味直达', '/api/file/placeholder/banner3.png', 'farm', '5', 3, 1);
INSERT INTO `banner` VALUES (4, '小站稻蟹田米新米上市', '/api/file/placeholder/banner4.png', 'product', '1', 4, 1);

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `spec` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `quantity` int(11) NOT NULL DEFAULT 1,
  `checked` tinyint(4) NOT NULL DEFAULT 1 COMMENT '勾选结算标记',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '购物车' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of cart
-- ----------------------------

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `parent_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '父级id，0为一级分类',
  `sort` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent`(`parent_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品分类' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '时令水果', 0, 10, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (2, '时令蔬菜', 0, 20, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (3, '粮油米面', 0, 30, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (4, '禽蛋水产', 0, 40, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (5, '干货特产', 0, 50, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (6, '调味干货', 0, 60, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (7, '苹果', 1, 10, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (8, '葡萄', 1, 20, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (9, '草莓', 1, 30, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (10, '枣类', 1, 40, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (11, '蟹类', 4, 10, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (12, '稻米', 3, 10, 1, '2026-09-04 16:56:37');
INSERT INTO `category` VALUES (13, '薯芋', 2, 10, 1, '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for farm
-- ----------------------------
DROP TABLE IF EXISTS `farm`;
CREATE TABLE `farm`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint(20) NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '农园名称',
  `type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '果园' COMMENT '果园/有机蔬菜农场',
  `district` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所在区县',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '详细地址（文字形式，供复制）',
  `business_hours` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '08:30-17:00' COMMENT '营业时间',
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '图文简介',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '封面图路径',
  `images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '详情图，逗号分隔',
  `avg_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '人均价格',
  `rating` decimal(2, 1) NULL DEFAULT 5.0 COMMENT '评分',
  `traffic_guide` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '交通指引（公交路线、自驾提示）',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1上架 0下架',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_merchant`(`merchant_id`) USING BTREE,
  INDEX `idx_district`(`district`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '农园' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of farm
-- ----------------------------
INSERT INTO `farm` VALUES (1, 1, '盘山红富士苹果园', '果园', '蓟州区', '蓟州区官庄镇盘山景区东门北行2公里', '08:00-16:30', '盘山红富士苹果园坐落于天津蓟州区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm1.png', '', 68.00, 4.8, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (2, 1, '盘山磨盘柿采摘园', '果园', '蓟州区', '蓟州区官庄镇玉石庄村盘山南麓', '09:00-17:30', '盘山磨盘柿采摘园地处蓟州区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm2.png', '', 45.00, 4.7, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (3, 1, '蓟州山里红山楂园', '果园', '蓟州区', '蓟州区下营镇黄崖关长城西侧1公里', '08:00-16:30', '蓟州山里红山楂园坐落于天津蓟州区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm3.png', '', 40.00, 4.5, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (4, 1, '燕山板栗生态园', '果园', '蓟州区', '蓟州区罗庄子镇洪水庄村北', '09:00-17:30', '燕山板栗生态园坐落于天津蓟州区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm4.png', '', 55.00, 4.6, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (5, 2, '沙窝萝卜直供菜园', '有机蔬菜农场', '西青区', '西青区辛口镇小沙窝村村南', '08:00-16:30', '沙窝萝卜直供菜园坐落于天津西青区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm5.png', '', 30.00, 4.9, '自驾：滨保高速七里海出口下，沿七里海大道行驶3公里；公交：公交571路俵口站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (6, 2, '西青早春甜瓜大棚', '果园', '西青区', '西青区辛口镇水高庄村农业示范园内', '08:30-17:00', '西青早春甜瓜大棚坐落于天津西青区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm6.png', '', 50.00, 4.4, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (7, 3, '茶淀玫瑰香葡萄园', '果园', '滨海新区', '滨海新区汉沽茶淀镇崔兴沽村', '08:30-17:00', '茶淀玫瑰香葡萄园地处滨海新区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm7.png', '', 60.00, 4.8, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (8, 3, '汉沽草莓采摘基地', '果园', '滨海新区', '滨海新区汉沽大田镇小马杓沽村', '08:00-16:30', '汉沽草莓采摘基地坐落于天津滨海新区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm8.png', '', 88.00, 4.6, '自驾：荣乌高速天津出口下，导航\"小沙窝村\"即可；公交：公交669路辛口站换乘便民3号线。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (9, 4, '静海金丝小枣园', '果园', '静海区', '静海区独流镇十一堡村东', '08:30-17:00', '静海金丝小枣园地处静海区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm9.png', '', 35.00, 4.5, '自驾：滨保高速七里海出口下，沿七里海大道行驶3公里；公交：公交571路俵口站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (10, 4, '静海冬枣采摘园', '果园', '静海区', '静海区良王庄乡王家院村', '09:00-17:30', '静海冬枣采摘园位于静海区核心农业示范区，是当地知名的家庭农场。所有作物按有机标准管理，农事体验丰富：游客可下田采摘、认养菜地、喂养小动物。园区提供免费停车位与采摘工具，雨天备有雨靴雨衣。', '/api/file/placeholder/farm10.png', '', 48.00, 4.4, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (11, 5, '七里海河蟹垂钓农庄', '有机蔬菜农场', '宁河区', '宁河区七里海镇俵口村湿地旁', '08:00-16:30', '七里海河蟹垂钓农庄地处宁河区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm11.png', '', 120.00, 4.7, '自驾：荣乌高速天津出口下，导航\"小沙窝村\"即可；公交：公交669路辛口站换乘便民3号线。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (12, 6, '宝坻小站稻体验农场', '有机蔬菜农场', '宝坻区', '宝坻区八门城镇欢喜庄村', '09:00-17:30', '宝坻小站稻体验农场坐落于天津宝坻区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm12.png', '', 40.00, 4.6, '自驾：荣乌高速天津出口下，导航\"小沙窝村\"即可；公交：公交669路辛口站换乘便民3号线。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (13, 6, '宝坻天鹰椒种植园', '有机蔬菜农场', '宝坻区', '宝坻区林亭口镇糙甸村', '09:00-17:30', '宝坻天鹰椒种植园坐落于天津宝坻区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm13.png', '', 28.00, 4.3, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (14, 7, '武清有机番茄农场', '有机蔬菜农场', '武清区', '武清区河西务镇三街村', '08:00-16:30', '武清有机番茄农场地处武清区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm14.png', '', 35.00, 4.6, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (15, 7, '武清奶油草莓园', '果园', '武清区', '武清区大碱厂镇南辛庄村', '08:30-17:00', '武清奶油草莓园位于武清区核心农业示范区，是当地知名的家庭农场。所有作物按有机标准管理，农事体验丰富：游客可下田采摘、认养菜地、喂养小动物。园区提供免费停车位与采摘工具，雨天备有雨靴雨衣。', '/api/file/placeholder/farm15.png', '', 85.00, 4.7, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (16, 7, '武清鲜食玉米基地', '有机蔬菜农场', '武清区', '武清区泗村店镇窑上村', '08:30-17:00', '武清鲜食玉米基地坐落于天津武清区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm16.png', '', 25.00, 4.2, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (17, 8, '北辰红颜草莓采摘园', '果园', '北辰区', '北辰区双街镇庞咀村农业园', '09:00-17:30', '北辰红颜草莓采摘园地处北辰区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm17.png', '', 90.00, 4.6, '自驾：滨保高速七里海出口下，沿七里海大道行驶3公里；公交：公交571路俵口站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (18, 8, '北辰樱桃采摘园', '果园', '北辰区', '北辰区西堤头镇东赵庄村', '08:30-17:00', '北辰樱桃采摘园地处北辰区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm18.png', '', 128.00, 4.8, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (19, 9, '津南葡萄主题农庄', '果园', '津南区', '津南区八里台镇大孙庄村', '08:00-16:30', '津南葡萄主题农庄地处津南区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm19.png', '', 62.00, 4.5, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (20, 9, '津南无花果家庭农场', '果园', '津南区', '津南区小站镇东西庄房村', '08:00-16:30', '津南无花果家庭农场位于津南区核心农业示范区，是当地知名的家庭农场。所有作物按有机标准管理，农事体验丰富：游客可下田采摘、认养菜地、喂养小动物。园区提供免费停车位与采摘工具，雨天备有雨靴雨衣。', '/api/file/placeholder/farm20.png', '', 70.00, 4.4, '自驾：滨保高速七里海出口下，沿七里海大道行驶3公里；公交：公交571路俵口站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (21, 1, '蓟州雪花梨采摘园', '果园', '蓟州区', '蓟州区马伸桥镇于各庄村', '09:00-17:30', '蓟州雪花梨采摘园坐落于天津蓟州区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm21.png', '', 42.00, 4.5, '自驾：荣乌高速天津出口下，导航\"小沙窝村\"即可；公交：公交669路辛口站换乘便民3号线。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (22, 1, '蓟州京白桃生态园', '果园', '蓟州区', '蓟州区穿芳峪镇新水厂村', '08:00-16:30', '蓟州京白桃生态园位于蓟州区核心农业示范区，是当地知名的家庭农场。所有作物按有机标准管理，农事体验丰富：游客可下田采摘、认养菜地、喂养小动物。园区提供免费停车位与采摘工具，雨天备有雨靴雨衣。', '/api/file/placeholder/farm22.png', '', 55.00, 4.6, '自驾：滨保高速七里海出口下，沿七里海大道行驶3公里；公交：公交571路俵口站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (23, 2, '西青盆栽蔬菜体验棚', '有机蔬菜农场', '西青区', '西青区杨柳青镇大柳滩村', '09:00-17:30', '西青盆栽蔬菜体验棚地处西青区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm23.png', '', 38.00, 4.3, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (24, 5, '宁河有机水稻农场', '有机蔬菜农场', '宁河区', '宁河区廉庄镇菜园村', '09:00-17:30', '宁河有机水稻农场地处宁河区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm24.png', '', 45.00, 4.5, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (25, 7, '武清西兰花出口基地', '有机蔬菜农场', '武清区', '武清区河北屯镇甄马营村', '08:30-17:00', '武清西兰花出口基地地处武清区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm25.png', '', 22.00, 4.1, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (26, 3, '汉沽桃李杏三果园', '果园', '滨海新区', '滨海新区汉沽杨家泊镇付庄村', '08:30-17:00', '汉沽桃李杏三果园地处滨海新区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm26.png', '', 50.00, 4.3, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (27, 4, '静海多肉植物园', '有机蔬菜农场', '静海区', '静海区双塘镇杨家园村', '09:00-17:30', '静海多肉植物园地处静海区生态涵养区，水土条件优越。农场主深耕本地特色品种二十余年，产品质量有口皆碑。除采摘外，还提供农产品加工体验（磨米、酿醋、晒干），让您感受从田间到餐桌的完整过程。', '/api/file/placeholder/farm27.png', '', 30.00, 4.2, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (28, 6, '宝坻大蒜种植体验园', '有机蔬菜农场', '宝坻区', '宝坻区大口屯镇西刘举人庄村', '08:30-17:00', '宝坻大蒜种植体验园位于宝坻区核心农业示范区，是当地知名的家庭农场。所有作物按有机标准管理，农事体验丰富：游客可下田采摘、认养菜地、喂养小动物。园区提供免费停车位与采摘工具，雨天备有雨靴雨衣。', '/api/file/placeholder/farm28.png', '', 26.00, 4.0, '自驾：津蓟高速盘山出口下，沿盘山大道行驶2公里即到；公交：旅游专线11路盘山站下车步行800米。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (29, 9, '津南小站稻垦殖园', '有机蔬菜农场', '津南区', '津南区小站镇会馆村小站稻核心区', '08:30-17:00', '津南小站稻垦殖园坐落于天津津南区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm29.png', '', 50.00, 4.7, '自驾：长深高速汉沽出口下，沿汉北路行驶5公里；公交：公交455路茶淀镇站下车。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `farm` VALUES (30, 8, '北辰蓝莓主题农场', '果园', '北辰区', '北辰区青光镇刘家码头村', '08:00-16:30', '北辰蓝莓主题农场坐落于天津北辰区，远离市区喧嚣，空气清新。园区坚持绿色种植理念，不使用高毒农药，采用物理防虫与有机肥栽培，果品口感纯正、甜度高。园内设有休息区与农家餐饮，适合亲子出游、朋友聚会，欢迎预约采摘。', '/api/file/placeholder/farm30.png', '', 98.00, 4.5, '自驾：京沪高速静海出口下，沿静文公路行驶8公里；公交：公交552路独流站下车步行1公里。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for feedback
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `contact` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0待处理 1已处理',
  `reply` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '意见反馈' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of feedback
-- ----------------------------
INSERT INTO `feedback` VALUES (1, 1, '希望增加更多宝坻区的农园，想带孩子去体验水稻收割。', '13911110001', 0, '', '2026-09-02 16:56:37');
INSERT INTO `feedback` VALUES (2, 2, '建议预约时可以同时预约多个采摘项目。', '13911110002', 1, '', '2026-08-30 16:56:37');
INSERT INTO `feedback` VALUES (3, 4, '商品页面图片能再清晰一点就更好了。', '13911110004', 0, '', '2026-09-03 16:56:37');

-- ----------------------------
-- Table structure for merchant
-- ----------------------------
DROP TABLE IF EXISTS `merchant`;
CREATE TABLE `merchant`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理端登录账号',
  `password_hash` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'BCrypt加密密码',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商家/店铺名称',
  `license_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '资质信息（营业执照、经营许可证等）',
  `contact` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '联系电话',
  `intro` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '商家简介',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0待审核 1已通过 2已封禁',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '驳回原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of merchant
-- ----------------------------
INSERT INTO `merchant` VALUES (1, 'merchant01', '$2b$10$DB8KRI8LHt8snTpOl7JYAOurXLbzyhnu8XIxXGk4boyy0Wr5lPRn.', '蓟州盘山果业有限公司', '统一社会信用代码：911202473MA5069X1', '张建国', '13800000001', '蓟州盘山_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (2, 'merchant02', '$2b$10$..Fyvr8.xN6Xkzvc7gwdMePxV2IcNFNSmk/aD5eirfRJcuI1Qm/hi', '西青沙窝萝卜种植合作社', '统一社会信用代码：911201568MA4930X2', '李秀兰', '13800000002', '西青沙窝_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (3, 'merchant03', '$2b$10$N4dzwG9NhE3B/b4Ov8CeeuYYW/23jNv1Tn3EA2MxC3E0amnuPuCLq', '汉沽茶淀葡萄合作社', '统一社会信用代码：911201329MA7405X8', '王振海', '13800000003', '汉沽茶淀_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (4, 'merchant04', '$2b$10$oLGB/5L3TOqWSmYRZMsDzOGRQo9rYTJ5JDgLXPpJhInS/H1XqO69.', '静海金丝小枣家庭农场', '统一社会信用代码：911205130MA6842X9', '刘芳', '13800000004', '静海金丝_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (5, 'merchant05', '$2b$10$PKn3vYHjV28i9idFPcFid.fPTQpYW8k007DnOLzOzSebred3VfTKG', '宁河七里海河蟹养殖基地', '统一社会信用代码：911202781MA6390X4', '赵德顺', '13800000005', '宁河七里_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (6, 'merchant06', '$2b$10$lymg0/4byA.pSZWH8XCLIuLrK7i3t8VW0IY.4ulUC7qk4uB2bmnVO', '宝坻小站稻米业公司', '统一社会信用代码：911203790MA1826X4', '陈永贵', '13800000006', '宝坻小站_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (7, 'merchant07', '$2b$10$Y.vITGdRp.0LNeY1C4fuvuzyB6KSfntrfy5q/lMnd4a9D5UN6HBAm', '武清有机蔬菜农场联盟', '统一社会信用代码：911205963MA4012X8', '孙丽梅', '13800000007', '武清有机_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (8, 'merchant08', '$2b$10$iAqS5rC51oEj8PwheVEDkefVmDr.0zzy/CQZ.bioK8yJYLOeiYr.K', '北辰果蔬采摘园', '统一社会信用代码：911204783MA5290X1', '周天成', '13800000008', '北辰果蔬_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (9, 'merchant09', '$2b$10$xjDjgv/xWgWNGHViK31Mo.EimhM5Z1sBL1NilT4VndbQS.1IVR...', '津南绿色农庄', '统一社会信用代码：911207298MA3451X6', '吴桂芝', '13800000009', '津南绿色_本地优质农副产品直供商家', 1, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `merchant` VALUES (10, 'merchant10', '$2b$10$8HDNp74xpSyNToB4skdVRugNXL0iAth/pO.917qOGsxHxt7gVTlBK', '滨海新区海产干货行', '统一社会信用代码：911209037MA2654X8', '郑海生', '13800000010', '滨海新区_本地优质农副产品直供商家', 0, '', '2026-09-04 16:56:37', '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `publish_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1发布 0下线',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_time`(`publish_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '平台公告' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (1, '平台试运营公告', '天津地方农特产推广服务平台于2026年9月正式上线试运营。平台首批入驻本地优质农户与农园30余家，覆盖蓟州、西青、静海、宁河等涉农区县。试运营期间全场满88元包邮，欢迎体验！', '2026-09-01 10:00:00', 1);
INSERT INTO `notice` VALUES (2, '金秋采摘季活动通知', '9月至11月为天津地区苹果、柿子、冬枣最佳采摘期。平台农园体验模块已上线\"金秋采摘季\"专题，预约任意农园即可获赠农家自种蔬菜一份（到园领取）。', '2026-08-25 10:00:00', 1);
INSERT INTO `notice` VALUES (3, '国庆假期预约提示', '国庆假期（10月1日至7日）为采摘高峰期，各农园场次库存有限，建议提前3天以上预约。到园后请向商家出示预留手机号以便现场确认。', '2026-08-15 10:00:00', 1);

-- ----------------------------
-- Table structure for oper_log
-- ----------------------------
DROP TABLE IF EXISTS `oper_log`;
CREATE TABLE `oper_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `operator_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ADMIN/MERCHANT/USER',
  `operator_id` bigint(20) NOT NULL,
  `operator_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `action` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `detail` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_operator`(`operator_type`, `operator_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作日志' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of oper_log
-- ----------------------------

-- ----------------------------
-- Table structure for order_item
-- ----------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `product_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品快照',
  `main_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `price` decimal(10, 2) NOT NULL COMMENT '成交单价快照',
  `quantity` int(11) NOT NULL DEFAULT 1,
  `spec` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order`(`order_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 56 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order_item
-- ----------------------------
INSERT INTO `order_item` VALUES (1, 1, 26, '商品#26演示快照', '/api/file/placeholder/p26.png', 194.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (2, 1, 101, '商品#101演示快照', '/api/file/placeholder/p101.png', 107.70, 1, '5斤装');
INSERT INTO `order_item` VALUES (3, 2, 189, '商品#189演示快照', '/api/file/placeholder/p189.png', 48.10, 1, '5斤装');
INSERT INTO `order_item` VALUES (4, 2, 119, '商品#119演示快照', '/api/file/placeholder/p119.png', 158.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (5, 2, 123, '商品#123演示快照', '/api/file/placeholder/p123.png', 182.70, 1, '5斤装');
INSERT INTO `order_item` VALUES (6, 3, 31, '商品#31演示快照', '/api/file/placeholder/p31.png', 148.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (7, 4, 207, '商品#207演示快照', '/api/file/placeholder/p207.png', 77.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (8, 5, 165, '商品#165演示快照', '/api/file/placeholder/p165.png', 151.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (9, 5, 142, '商品#142演示快照', '/api/file/placeholder/p142.png', 180.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (10, 5, 199, '商品#199演示快照', '/api/file/placeholder/p199.png', 62.60, 1, '5斤装');
INSERT INTO `order_item` VALUES (11, 6, 47, '商品#47演示快照', '/api/file/placeholder/p47.png', 157.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (12, 7, 100, '商品#100演示快照', '/api/file/placeholder/p100.png', 63.60, 1, '5斤装');
INSERT INTO `order_item` VALUES (13, 7, 188, '商品#188演示快照', '/api/file/placeholder/p188.png', 170.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (14, 8, 168, '商品#168演示快照', '/api/file/placeholder/p168.png', 77.80, 1, '5斤装');
INSERT INTO `order_item` VALUES (15, 8, 28, '商品#28演示快照', '/api/file/placeholder/p28.png', 134.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (16, 9, 166, '商品#166演示快照', '/api/file/placeholder/p166.png', 33.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (17, 9, 174, '商品#174演示快照', '/api/file/placeholder/p174.png', 49.80, 1, '5斤装');
INSERT INTO `order_item` VALUES (18, 9, 140, '商品#140演示快照', '/api/file/placeholder/p140.png', 149.40, 1, '5斤装');
INSERT INTO `order_item` VALUES (19, 10, 19, '商品#19演示快照', '/api/file/placeholder/p19.png', 27.50, 1, '5斤装');
INSERT INTO `order_item` VALUES (20, 10, 29, '商品#29演示快照', '/api/file/placeholder/p29.png', 182.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (21, 10, 118, '商品#118演示快照', '/api/file/placeholder/p118.png', 22.00, 1, '5斤装');
INSERT INTO `order_item` VALUES (22, 11, 138, '商品#138演示快照', '/api/file/placeholder/p138.png', 27.60, 1, '5斤装');
INSERT INTO `order_item` VALUES (23, 11, 113, '商品#113演示快照', '/api/file/placeholder/p113.png', 165.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (24, 12, 136, '商品#136演示快照', '/api/file/placeholder/p136.png', 58.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (25, 12, 25, '商品#25演示快照', '/api/file/placeholder/p25.png', 179.70, 1, '5斤装');
INSERT INTO `order_item` VALUES (26, 13, 187, '商品#187演示快照', '/api/file/placeholder/p187.png', 152.80, 1, '5斤装');
INSERT INTO `order_item` VALUES (27, 14, 117, '商品#117演示快照', '/api/file/placeholder/p117.png', 145.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (28, 15, 113, '商品#113演示快照', '/api/file/placeholder/p113.png', 28.60, 1, '5斤装');
INSERT INTO `order_item` VALUES (29, 15, 175, '商品#175演示快照', '/api/file/placeholder/p175.png', 34.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (30, 16, 166, '商品#166演示快照', '/api/file/placeholder/p166.png', 93.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (31, 16, 148, '商品#148演示快照', '/api/file/placeholder/p148.png', 73.70, 1, '5斤装');
INSERT INTO `order_item` VALUES (32, 17, 82, '商品#82演示快照', '/api/file/placeholder/p82.png', 186.10, 1, '5斤装');
INSERT INTO `order_item` VALUES (33, 18, 28, '商品#28演示快照', '/api/file/placeholder/p28.png', 72.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (34, 19, 8, '商品#8演示快照', '/api/file/placeholder/p8.png', 156.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (35, 19, 110, '商品#110演示快照', '/api/file/placeholder/p110.png', 134.00, 1, '5斤装');
INSERT INTO `order_item` VALUES (36, 19, 3, '商品#3演示快照', '/api/file/placeholder/p3.png', 72.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (37, 20, 176, '商品#176演示快照', '/api/file/placeholder/p176.png', 132.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (38, 21, 47, '商品#47演示快照', '/api/file/placeholder/p47.png', 28.70, 1, '5斤装');
INSERT INTO `order_item` VALUES (39, 21, 29, '商品#29演示快照', '/api/file/placeholder/p29.png', 84.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (40, 21, 24, '商品#24演示快照', '/api/file/placeholder/p24.png', 129.00, 1, '5斤装');
INSERT INTO `order_item` VALUES (41, 22, 61, '商品#61演示快照', '/api/file/placeholder/p61.png', 65.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (42, 23, 100, '商品#100演示快照', '/api/file/placeholder/p100.png', 135.40, 1, '5斤装');
INSERT INTO `order_item` VALUES (43, 24, 147, '商品#147演示快照', '/api/file/placeholder/p147.png', 152.80, 1, '5斤装');
INSERT INTO `order_item` VALUES (44, 25, 174, '商品#174演示快照', '/api/file/placeholder/p174.png', 87.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (45, 25, 2, '商品#2演示快照', '/api/file/placeholder/p2.png', 59.60, 1, '5斤装');
INSERT INTO `order_item` VALUES (46, 26, 92, '商品#92演示快照', '/api/file/placeholder/p92.png', 105.50, 1, '5斤装');
INSERT INTO `order_item` VALUES (47, 26, 141, '商品#141演示快照', '/api/file/placeholder/p141.png', 125.40, 1, '5斤装');
INSERT INTO `order_item` VALUES (48, 26, 151, '商品#151演示快照', '/api/file/placeholder/p151.png', 99.50, 1, '5斤装');
INSERT INTO `order_item` VALUES (49, 27, 28, '商品#28演示快照', '/api/file/placeholder/p28.png', 68.10, 1, '5斤装');
INSERT INTO `order_item` VALUES (50, 27, 142, '商品#142演示快照', '/api/file/placeholder/p142.png', 24.30, 1, '5斤装');
INSERT INTO `order_item` VALUES (51, 28, 27, '商品#27演示快照', '/api/file/placeholder/p27.png', 163.70, 1, '5斤装');
INSERT INTO `order_item` VALUES (52, 29, 50, '商品#50演示快照', '/api/file/placeholder/p50.png', 113.90, 1, '5斤装');
INSERT INTO `order_item` VALUES (53, 29, 190, '商品#190演示快照', '/api/file/placeholder/p190.png', 63.60, 1, '5斤装');
INSERT INTO `order_item` VALUES (54, 29, 114, '商品#114演示快照', '/api/file/placeholder/p114.png', 172.20, 1, '5斤装');
INSERT INTO `order_item` VALUES (55, 30, 175, '商品#175演示快照', '/api/file/placeholder/p175.png', 43.90, 1, '5斤装');

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL,
  `total_amount` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0待付款 1待发货 2待收货 3已完成 4已取消 5退款中 6已退款',
  `receiver` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货人（快照）',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货电话（快照）',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货地址（快照）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '买家留言',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '退款原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `ship_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_no`(`order_no`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单主表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, 'SO2026202609000000', 4, 232.10, 1, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-26 05:00:00', '2026-08-26 06:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (2, 'SO2026202609000038', 1, 274.20, 2, '王先生', '13911110001', '天津市南开区长江道融创中心3-1-502', '', '', '2026-08-05 01:00:00', '2026-08-05 02:00:00', '2026-08-06 02:00:00', NULL, NULL);
INSERT INTO `orders` VALUES (3, 'SO2026202609000076', 5, 223.00, 1, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-24 06:00:00', '2026-08-24 07:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (4, 'SO2026202609000114', 2, 375.00, 1, '李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801', '', '', '2026-07-27 00:00:00', '2026-07-27 01:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (5, 'SO2026202609000152', 2, 324.90, 2, '李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801', '', '', '2026-07-30 20:00:00', '2026-07-30 21:00:00', '2026-07-31 21:00:00', NULL, NULL);
INSERT INTO `orders` VALUES (6, 'SO2026202609000190', 4, 165.70, 4, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-16 11:00:00', '2026-08-16 12:00:00', '2026-08-17 12:00:00', NULL, '2026-08-16 13:00:00');
INSERT INTO `orders` VALUES (7, 'SO2026202609000228', 5, 197.80, 1, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-14 03:00:00', '2026-08-14 04:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (8, 'SO2026202609000266', 4, 318.70, 3, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-06 00:00:00', '2026-08-06 01:00:00', '2026-08-07 01:00:00', '2026-08-10 01:00:00', NULL);
INSERT INTO `orders` VALUES (9, 'SO2026202609000304', 2, 372.50, 3, '李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801', '', '', '2026-08-10 20:00:00', '2026-08-10 21:00:00', '2026-08-11 21:00:00', '2026-08-14 21:00:00', NULL);
INSERT INTO `orders` VALUES (10, 'SO2026202609000342', 5, 212.70, 4, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-07-31 23:00:00', '2026-08-01 00:00:00', '2026-08-02 00:00:00', NULL, '2026-08-01 01:00:00');
INSERT INTO `orders` VALUES (11, 'SO2026202609000380', 4, 41.90, 4, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-14 21:00:00', '2026-08-14 22:00:00', '2026-08-15 22:00:00', NULL, '2026-08-14 23:00:00');
INSERT INTO `orders` VALUES (12, 'SO2026202609000418', 1, 261.30, 4, '王先生', '13911110001', '天津市南开区长江道融创中心3-1-502', '', '', '2026-08-28 06:00:00', '2026-08-28 07:00:00', '2026-08-29 07:00:00', NULL, '2026-08-28 08:00:00');
INSERT INTO `orders` VALUES (13, 'SO2026202609000456', 2, 48.30, 3, '李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801', '', '', '2026-09-04 10:00:00', '2026-09-04 11:00:00', '2026-09-05 11:00:00', '2026-09-08 11:00:00', NULL);
INSERT INTO `orders` VALUES (14, 'SO2026202609000494', 2, 235.40, 2, '李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801', '', '', '2026-08-04 19:00:00', '2026-08-04 20:00:00', '2026-08-05 20:00:00', NULL, NULL);
INSERT INTO `orders` VALUES (15, 'SO2026202609000532', 1, 79.10, 3, '王先生', '13911110001', '天津市南开区长江道融创中心3-1-502', '', '', '2026-08-01 22:00:00', '2026-08-01 23:00:00', '2026-08-02 23:00:00', '2026-08-05 23:00:00', NULL);
INSERT INTO `orders` VALUES (16, 'SO2026202609000570', 4, 362.90, 1, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-07-30 00:00:00', '2026-07-30 01:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (17, 'SO2026202609000608', 5, 138.40, 1, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-07-26 19:00:00', '2026-07-26 20:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (18, 'SO2026202609000646', 5, 91.50, 3, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-07-27 08:00:00', '2026-07-27 09:00:00', '2026-07-28 09:00:00', '2026-07-31 09:00:00', NULL);
INSERT INTO `orders` VALUES (19, 'SO2026202609000684', 2, 289.80, 3, '李女士', '13911110002', '天津市河西区友谊南路万科水晶城12-2-801', '', '', '2026-08-07 11:00:00', '2026-08-07 12:00:00', '2026-08-08 12:00:00', '2026-08-11 12:00:00', NULL);
INSERT INTO `orders` VALUES (20, 'SO2026202609000722', 4, 42.10, 0, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-07-31 08:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (21, 'SO2026202609000760', 4, 327.80, 1, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-04 11:00:00', '2026-08-04 12:00:00', NULL, NULL, NULL);
INSERT INTO `orders` VALUES (22, 'SO2026202609000798', 5, 40.30, 4, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-21 15:00:00', '2026-08-21 16:00:00', '2026-08-22 16:00:00', NULL, '2026-08-21 17:00:00');
INSERT INTO `orders` VALUES (23, 'SO2026202609000836', 1, 76.90, 4, '王先生', '13911110001', '天津市南开区长江道融创中心3-1-502', '', '', '2026-08-06 03:00:00', '2026-08-06 04:00:00', '2026-08-07 04:00:00', NULL, '2026-08-06 05:00:00');
INSERT INTO `orders` VALUES (24, 'SO2026202609000874', 1, 124.30, 4, '王先生', '13911110001', '天津市南开区长江道融创中心3-1-502', '', '', '2026-08-18 01:00:00', '2026-08-18 02:00:00', '2026-08-19 02:00:00', NULL, '2026-08-18 03:00:00');
INSERT INTO `orders` VALUES (25, 'SO2026202609000912', 3, 204.00, 3, '张大爷', '13911110003', '天津市河东区卫国道红星大厦B座1803', '', '', '2026-08-29 07:00:00', '2026-08-29 08:00:00', '2026-08-30 08:00:00', '2026-09-02 08:00:00', NULL);
INSERT INTO `orders` VALUES (26, 'SO2026202609000950', 4, 119.60, 3, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-09-02 22:00:00', '2026-09-02 23:00:00', '2026-09-03 23:00:00', '2026-09-06 23:00:00', NULL);
INSERT INTO `orders` VALUES (27, 'SO2026202609000988', 3, 218.40, 3, '张大爷', '13911110003', '天津市河东区卫国道红星大厦B座1803', '', '', '2026-09-04 08:00:00', '2026-09-04 09:00:00', '2026-09-05 09:00:00', '2026-09-08 09:00:00', NULL);
INSERT INTO `orders` VALUES (28, 'SO2026202609001026', 5, 334.00, 0, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-07-30 22:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `orders` VALUES (29, 'SO2026202609001064', 3, 176.10, 2, '张大爷', '13911110003', '天津市河东区卫国道红星大厦B座1803', '', '', '2026-08-31 07:00:00', '2026-08-31 08:00:00', '2026-09-01 08:00:00', NULL, NULL);
INSERT INTO `orders` VALUES (30, 'SO2026202609001102', 5, 38.20, 0, '亲子游达人', '13911110004', '天津市和平区南京路君隆广场B座902', '', '', '2026-08-24 04:00:00', NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for picking_project
-- ----------------------------
DROP TABLE IF EXISTS `picking_project`;
CREATE TABLE `picking_project`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `farm_id` bigint(20) NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '品种名称，如红富士苹果采摘',
  `season_start` date NULL DEFAULT NULL COMMENT '当季开始',
  `season_end` date NULL DEFAULT NULL COMMENT '当季结束',
  `price_mode` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '按人头门票' COMMENT '按人头门票/按采摘重量',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '价格（门票价或每斤价）',
  `session` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '上午,下午' COMMENT '可约场次，逗号分隔',
  `stock` int(11) NOT NULL DEFAULT 50 COMMENT '场次库存（每场次可约总人数）',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1上架 0下架',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_farm`(`farm_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 61 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采摘项目' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of picking_project
-- ----------------------------
INSERT INTO `picking_project` VALUES (1, 1, '玫瑰香葡萄采摘', '2026-10-06', '2027-03-15', '按人头门票', 95.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (2, 1, '雪花梨采摘', '2026-10-14', '2027-04-01', '按采摘重量', 18.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (3, 1, '山楂采摘', '2026-11-02', '2027-05-15', '按采摘重量', 32.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (4, 2, '无花果采摘', '2026-08-23', '2026-12-09', '按采摘重量', 8.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (5, 2, '甜瓜采摘', '2026-09-17', '2026-12-26', '按采摘重量', 16.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (6, 3, '板栗采摘', '2026-07-16', '2027-01-13', '按人头门票', 55.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (7, 3, '京白桃采摘', '2026-10-03', '2027-02-10', '按采摘重量', 12.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (8, 4, '金丝小枣采摘', '2026-10-10', '2027-01-19', '按人头门票', 85.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (9, 4, '奶油草莓采摘', '2026-07-09', '2027-01-05', '按人头门票', 25.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (10, 4, '蓝莓采摘', '2026-08-09', '2026-12-17', '按采摘重量', 34.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (11, 5, '鲜食玉米采摘', '2026-09-08', '2027-01-02', '按人头门票', 65.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (12, 6, '蓝莓采摘', '2026-10-08', '2027-01-09', '按采摘重量', 16.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (13, 6, '樱桃采摘', '2026-11-01', '2027-02-27', '按人头门票', 105.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (14, 7, '冬枣采摘', '2026-10-21', '2027-04-29', '按采摘重量', 32.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (15, 7, '京白桃采摘', '2026-08-22', '2026-12-28', '按人头门票', 105.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (16, 7, '甜瓜采摘', '2026-11-01', '2027-02-08', '按人头门票', 115.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (17, 8, '板栗采摘', '2026-10-27', '2027-03-26', '按采摘重量', 24.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (18, 8, '桃杏李混摘', '2026-10-20', '2027-04-27', '按人头门票', 55.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (19, 9, '雪花梨采摘', '2026-09-09', '2027-03-28', '按采摘重量', 20.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (20, 9, '甜瓜采摘', '2026-07-28', '2026-12-15', '按采摘重量', 18.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (21, 10, '红富士苹果采摘', '2026-09-20', '2027-01-26', '按采摘重量', 14.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (22, 11, '螃蟹垂钓体验', '2026-10-24', '2027-02-26', '按人头门票', 85.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (23, 11, '有机番茄采摘', '2026-07-23', '2026-12-27', '按采摘重量', 22.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (24, 12, '水稻收割农事体验', '2026-08-27', '2026-11-27', '按人头门票', 110.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (25, 13, '沙窝萝卜拔取体验', '2026-07-13', '2027-01-17', '按采摘重量', 24.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (26, 13, '西兰花采收体验', '2026-08-02', '2027-01-26', '按人头门票', 60.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (27, 14, '水稻收割农事体验', '2026-10-19', '2027-02-12', '按采摘重量', 30.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (28, 14, '西兰花采收体验', '2026-07-07', '2026-10-10', '按人头门票', 110.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (29, 15, '蓝莓采摘', '2026-08-13', '2026-12-26', '按采摘重量', 34.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (30, 16, '水稻收割农事体验', '2026-10-12', '2027-04-16', '按人头门票', 75.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (31, 17, '蓝莓采摘', '2026-09-04', '2027-03-09', '按人头门票', 45.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (32, 17, '红富士苹果采摘', '2026-10-14', '2027-04-30', '按采摘重量', 26.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (33, 18, '红富士苹果采摘', '2026-07-23', '2026-12-17', '按采摘重量', 22.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (34, 19, '红富士苹果采摘', '2026-08-17', '2027-02-28', '按人头门票', 110.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (35, 19, '樱桃采摘', '2026-08-27', '2026-12-28', '按采摘重量', 14.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (36, 19, '桃杏李混摘', '2026-10-05', '2027-04-23', '按人头门票', 75.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (37, 20, '金丝小枣采摘', '2026-09-15', '2027-01-23', '按采摘重量', 12.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (38, 21, '玫瑰香葡萄采摘', '2026-09-21', '2027-02-27', '按人头门票', 120.00, '上午,下午', 60, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (39, 21, '磨盘柿采摘', '2026-10-17', '2027-01-24', '按采摘重量', 18.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (40, 22, '桃杏李混摘', '2026-10-04', '2027-01-21', '按采摘重量', 24.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (41, 22, '樱桃采摘', '2026-08-03', '2026-11-23', '按人头门票', 25.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (42, 22, '玫瑰香葡萄采摘', '2026-08-08', '2027-01-27', '按人头门票', 105.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (43, 23, '水稻收割农事体验', '2026-07-26', '2026-11-16', '按采摘重量', 38.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (44, 24, '大蒜采收体验', '2026-07-13', '2026-12-20', '按人头门票', 40.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (45, 25, '水稻收割农事体验', '2026-11-03', '2027-05-03', '按采摘重量', 36.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (46, 26, '板栗采摘', '2026-08-02', '2027-02-02', '按人头门票', 100.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (47, 26, '奶油草莓采摘', '2026-10-21', '2027-04-26', '按采摘重量', 18.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (48, 26, '樱桃采摘', '2026-09-13', '2027-03-03', '按采摘重量', 22.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (49, 27, '螃蟹垂钓体验', '2026-08-23', '2027-01-29', '按人头门票', 70.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (50, 27, '多肉植物盆栽DIY', '2026-07-07', '2026-10-28', '按人头门票', 45.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (51, 27, '水稻收割农事体验', '2026-09-26', '2027-03-30', '按采摘重量', 28.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (52, 28, '西兰花采收体验', '2026-09-21', '2027-03-02', '按人头门票', 100.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (53, 28, '鲜食玉米采摘', '2026-10-11', '2027-03-18', '按人头门票', 25.00, '上午,下午', 40, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (54, 28, '有机番茄采摘', '2026-09-25', '2027-02-16', '按采摘重量', 34.00, '上午,下午', 80, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (55, 29, '沙窝萝卜拔取体验', '2026-07-08', '2026-10-21', '按采摘重量', 16.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (56, 29, '鲜食玉米采摘', '2026-09-29', '2027-01-09', '按采摘重量', 24.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (57, 29, '盆栽蔬菜认购', '2026-09-12', '2027-02-14', '按人头门票', 65.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (58, 30, '蓝莓采摘', '2026-10-12', '2027-04-13', '按采摘重量', 16.00, '上午,下午', 50, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (59, 30, '金丝小枣采摘', '2026-07-13', '2026-11-12', '按人头门票', 90.00, '上午,下午', 30, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `picking_project` VALUES (60, 30, '无花果采摘', '2026-10-06', '2027-02-08', '按采摘重量', 20.00, '上午,下午', 20, 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for product
-- ----------------------------
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `merchant_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `main_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '主图路径',
  `images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '详情图，逗号分隔',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `specs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '可选规格，如 5斤装,10斤装',
  `stock` int(11) NOT NULL DEFAULT 0,
  `sales` int(11) NOT NULL DEFAULT 0 COMMENT '销量',
  `origin` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '产地',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '图文详情',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1上架 0下架 2待审核',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_merchant`(`merchant_id`) USING BTREE,
  INDEX `idx_category`(`category_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 491 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of product
-- ----------------------------
INSERT INTO `product` VALUES (1, 6, 3, '小站稻香米 5斤装（精选）', '/api/file/placeholder/p1.png', '', 56.40, '5斤装,10斤装,20斤装', 80, 696, '天津宝坻', '小站稻香米 5斤装（精选），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (2, 6, 3, '小站稻香米 10斤装（精选）', '/api/file/placeholder/p2.png', '', 47.90, '5斤装,10斤装,20斤装', 300, 627, '天津宝坻', '小站稻香米 10斤装（精选），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (3, 6, 3, '小站稻香米 20斤装（精选）', '/api/file/placeholder/p3.png', '', 64.30, '5斤装,10斤装,20斤装', 50, 1005, '天津宝坻', '小站稻香米 20斤装（精选），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (4, 6, 3, '小站稻香米 5斤装（特选）', '/api/file/placeholder/p4.png', '', 75.10, '5斤装,10斤装,20斤装', 50, 1803, '天津宝坻', '小站稻香米 5斤装（特选），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (5, 6, 3, '小站稻香米 10斤装（特选）', '/api/file/placeholder/p5.png', '', 102.20, '5斤装,10斤装,20斤装', 0, 19, '天津宝坻', '小站稻香米 10斤装（特选），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (6, 6, 3, '小站稻香米 20斤装（特选）', '/api/file/placeholder/p6.png', '', 41.90, '5斤装,10斤装,20斤装', 80, 1762, '天津宝坻', '小站稻香米 20斤装（特选），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (7, 6, 3, '小站稻香米 5斤装（家庭装）', '/api/file/placeholder/p7.png', '', 92.20, '5斤装,10斤装,20斤装', 150, 1844, '天津宝坻', '小站稻香米 5斤装（家庭装），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (8, 6, 3, '小站稻香米 10斤装（家庭装）', '/api/file/placeholder/p8.png', '', 39.50, '5斤装,10斤装,20斤装', 500, 1844, '天津宝坻', '小站稻香米 10斤装（家庭装），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (9, 6, 3, '小站稻香米 20斤装（家庭装）', '/api/file/placeholder/p9.png', '', 98.90, '5斤装,10斤装,20斤装', 100, 729, '天津宝坻', '小站稻香米 20斤装（家庭装），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (10, 6, 3, '小站稻香米 5斤装（礼盒）', '/api/file/placeholder/p10.png', '', 109.10, '5斤装,10斤装,20斤装', 30, 645, '天津宝坻', '小站稻香米 5斤装（礼盒），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (11, 6, 3, '小站稻香米 10斤装（礼盒）', '/api/file/placeholder/p11.png', '', 119.40, '5斤装,10斤装,20斤装', 0, 20, '天津宝坻', '小站稻香米 10斤装（礼盒），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (12, 6, 3, '小站稻香米 20斤装（礼盒）', '/api/file/placeholder/p12.png', '', 128.10, '5斤装,10斤装,20斤装', 50, 78, '天津宝坻', '小站稻香米 20斤装（礼盒），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (13, 6, 3, '小站稻香米 5斤装（生态）', '/api/file/placeholder/p13.png', '', 127.70, '5斤装,10斤装,20斤装', 0, 8, '天津宝坻', '小站稻香米 5斤装（生态），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (14, 6, 3, '小站稻香米 10斤装（生态）', '/api/file/placeholder/p14.png', '', 49.60, '5斤装,10斤装,20斤装', 30, 1342, '天津宝坻', '小站稻香米 10斤装（生态），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (15, 6, 3, '小站稻香米 20斤装（生态）', '/api/file/placeholder/p15.png', '', 61.20, '5斤装,10斤装,20斤装', 30, 1807, '天津宝坻', '小站稻香米 20斤装（生态），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (16, 6, 3, '小站稻香米 5斤装（头茬）', '/api/file/placeholder/p16.png', '', 43.30, '5斤装,10斤装,20斤装', 50, 1560, '天津宝坻', '小站稻香米 5斤装（头茬），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (17, 6, 3, '小站稻香米 10斤装（头茬）', '/api/file/placeholder/p17.png', '', 106.90, '5斤装,10斤装,20斤装', 30, 1164, '天津宝坻', '小站稻香米 10斤装（头茬），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (18, 6, 3, '小站稻香米 20斤装（头茬）', '/api/file/placeholder/p18.png', '', 123.20, '5斤装,10斤装,20斤装', 50, 1332, '天津宝坻', '小站稻香米 20斤装（头茬），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (19, 6, 3, '小站稻香米 5斤装（新货）', '/api/file/placeholder/p19.png', '', 42.70, '5斤装,10斤装,20斤装', 300, 174, '天津宝坻', '小站稻香米 5斤装（新货），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (20, 6, 3, '小站稻香米 10斤装（新货）', '/api/file/placeholder/p20.png', '', 47.70, '5斤装,10斤装,20斤装', 30, 706, '天津宝坻', '小站稻香米 10斤装（新货），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (21, 6, 3, '小站稻香米 20斤装（新货）', '/api/file/placeholder/p21.png', '', 118.50, '5斤装,10斤装,20斤装', 100, 1854, '天津宝坻', '小站稻香米 20斤装（新货），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (22, 6, 3, '小站稻香米 5斤装（直供）', '/api/file/placeholder/p22.png', '', 72.20, '5斤装,10斤装,20斤装', 15, 1706, '天津宝坻', '小站稻香米 5斤装（直供），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (23, 6, 3, '小站稻香米 10斤装（直供）', '/api/file/placeholder/p23.png', '', 49.10, '5斤装,10斤装,20斤装', 150, 1050, '天津宝坻', '小站稻香米 10斤装（直供），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (24, 6, 3, '小站稻香米 20斤装（直供）', '/api/file/placeholder/p24.png', '', 63.90, '5斤装,10斤装,20斤装', 100, 1517, '天津宝坻', '小站稻香米 20斤装（直供），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (25, 6, 3, '小站稻香米 5斤装（老树）', '/api/file/placeholder/p25.png', '', 71.30, '5斤装,10斤装,20斤装', 200, 1601, '天津宝坻', '小站稻香米 5斤装（老树），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (26, 6, 3, '小站稻香米 10斤装（老树）', '/api/file/placeholder/p26.png', '', 42.80, '5斤装,10斤装,20斤装', 300, 601, '天津宝坻', '小站稻香米 10斤装（老树），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (27, 6, 3, '小站稻香米 20斤装（老树）', '/api/file/placeholder/p27.png', '', 84.80, '5斤装,10斤装,20斤装', 30, 1235, '天津宝坻', '小站稻香米 20斤装（老树），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (28, 6, 3, '小站稻香米 5斤装（当季）', '/api/file/placeholder/p28.png', '', 116.10, '5斤装,10斤装,20斤装', 300, 298, '天津宝坻', '小站稻香米 5斤装（当季），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (29, 6, 3, '小站稻香米 10斤装（当季）', '/api/file/placeholder/p29.png', '', 109.60, '5斤装,10斤装,20斤装', 15, 1221, '天津宝坻', '小站稻香米 10斤装（当季），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (30, 6, 3, '小站稻香米 20斤装（当季）', '/api/file/placeholder/p30.png', '', 112.80, '5斤装,10斤装,20斤装', 30, 456, '天津宝坻', '小站稻香米 20斤装（当季），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (31, 2, 2, '沙窝萝卜 3斤装（精选）', '/api/file/placeholder/p31.png', '', 20.70, '3斤装,5斤装,10斤装', 80, 1006, '天津西青', '沙窝萝卜 3斤装（精选），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (32, 2, 2, '沙窝萝卜 5斤装（精选）', '/api/file/placeholder/p32.png', '', 29.10, '3斤装,5斤装,10斤装', 100, 812, '天津西青', '沙窝萝卜 5斤装（精选），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (33, 2, 2, '沙窝萝卜 10斤装（精选）', '/api/file/placeholder/p33.png', '', 46.40, '3斤装,5斤装,10斤装', 0, 9, '天津西青', '沙窝萝卜 10斤装（精选），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (34, 2, 2, '沙窝萝卜 3斤装（特选）', '/api/file/placeholder/p34.png', '', 40.40, '3斤装,5斤装,10斤装', 0, 23, '天津西青', '沙窝萝卜 3斤装（特选），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (35, 2, 2, '沙窝萝卜 5斤装（特选）', '/api/file/placeholder/p35.png', '', 28.90, '3斤装,5斤装,10斤装', 150, 593, '天津西青', '沙窝萝卜 5斤装（特选），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (36, 2, 2, '沙窝萝卜 10斤装（特选）', '/api/file/placeholder/p36.png', '', 25.20, '3斤装,5斤装,10斤装', 500, 1002, '天津西青', '沙窝萝卜 10斤装（特选），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (37, 2, 2, '沙窝萝卜 3斤装（家庭装）', '/api/file/placeholder/p37.png', '', 29.70, '3斤装,5斤装,10斤装', 200, 1813, '天津西青', '沙窝萝卜 3斤装（家庭装），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (38, 2, 2, '沙窝萝卜 5斤装（家庭装）', '/api/file/placeholder/p38.png', '', 32.50, '3斤装,5斤装,10斤装', 150, 682, '天津西青', '沙窝萝卜 5斤装（家庭装），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (39, 2, 2, '沙窝萝卜 10斤装（家庭装）', '/api/file/placeholder/p39.png', '', 41.80, '3斤装,5斤装,10斤装', 100, 1811, '天津西青', '沙窝萝卜 10斤装（家庭装），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (40, 2, 2, '沙窝萝卜 3斤装（礼盒）', '/api/file/placeholder/p40.png', '', 16.10, '3斤装,5斤装,10斤装', 500, 1145, '天津西青', '沙窝萝卜 3斤装（礼盒），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (41, 2, 2, '沙窝萝卜 5斤装（礼盒）', '/api/file/placeholder/p41.png', '', 25.10, '3斤装,5斤装,10斤装', 500, 399, '天津西青', '沙窝萝卜 5斤装（礼盒），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (42, 2, 2, '沙窝萝卜 10斤装（礼盒）', '/api/file/placeholder/p42.png', '', 44.50, '3斤装,5斤装,10斤装', 100, 1156, '天津西青', '沙窝萝卜 10斤装（礼盒），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (43, 2, 2, '沙窝萝卜 3斤装（生态）', '/api/file/placeholder/p43.png', '', 27.10, '3斤装,5斤装,10斤装', 500, 1334, '天津西青', '沙窝萝卜 3斤装（生态），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (44, 2, 2, '沙窝萝卜 5斤装（生态）', '/api/file/placeholder/p44.png', '', 29.40, '3斤装,5斤装,10斤装', 200, 1873, '天津西青', '沙窝萝卜 5斤装（生态），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (45, 2, 2, '沙窝萝卜 10斤装（生态）', '/api/file/placeholder/p45.png', '', 33.80, '3斤装,5斤装,10斤装', 0, 11, '天津西青', '沙窝萝卜 10斤装（生态），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (46, 2, 2, '沙窝萝卜 3斤装（头茬）', '/api/file/placeholder/p46.png', '', 45.60, '3斤装,5斤装,10斤装', 50, 180, '天津西青', '沙窝萝卜 3斤装（头茬），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (47, 2, 2, '沙窝萝卜 5斤装（头茬）', '/api/file/placeholder/p47.png', '', 12.40, '3斤装,5斤装,10斤装', 0, 16, '天津西青', '沙窝萝卜 5斤装（头茬），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (48, 2, 2, '沙窝萝卜 10斤装（头茬）', '/api/file/placeholder/p48.png', '', 30.10, '3斤装,5斤装,10斤装', 50, 1129, '天津西青', '沙窝萝卜 10斤装（头茬），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (49, 2, 2, '沙窝萝卜 3斤装（新货）', '/api/file/placeholder/p49.png', '', 15.20, '3斤装,5斤装,10斤装', 150, 25, '天津西青', '沙窝萝卜 3斤装（新货），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (50, 2, 2, '沙窝萝卜 5斤装（新货）', '/api/file/placeholder/p50.png', '', 29.30, '3斤装,5斤装,10斤装', 500, 1856, '天津西青', '沙窝萝卜 5斤装（新货），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (51, 2, 2, '沙窝萝卜 10斤装（新货）', '/api/file/placeholder/p51.png', '', 22.60, '3斤装,5斤装,10斤装', 150, 1297, '天津西青', '沙窝萝卜 10斤装（新货），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (52, 2, 2, '沙窝萝卜 3斤装（直供）', '/api/file/placeholder/p52.png', '', 45.20, '3斤装,5斤装,10斤装', 30, 176, '天津西青', '沙窝萝卜 3斤装（直供），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (53, 2, 2, '沙窝萝卜 5斤装（直供）', '/api/file/placeholder/p53.png', '', 27.50, '3斤装,5斤装,10斤装', 200, 1502, '天津西青', '沙窝萝卜 5斤装（直供），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (54, 2, 2, '沙窝萝卜 10斤装（直供）', '/api/file/placeholder/p54.png', '', 40.80, '3斤装,5斤装,10斤装', 50, 175, '天津西青', '沙窝萝卜 10斤装（直供），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (55, 2, 2, '沙窝萝卜 3斤装（老树）', '/api/file/placeholder/p55.png', '', 17.00, '3斤装,5斤装,10斤装', 15, 1910, '天津西青', '沙窝萝卜 3斤装（老树），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (56, 2, 2, '沙窝萝卜 5斤装（老树）', '/api/file/placeholder/p56.png', '', 31.10, '3斤装,5斤装,10斤装', 500, 30, '天津西青', '沙窝萝卜 5斤装（老树），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (57, 2, 2, '沙窝萝卜 10斤装（老树）', '/api/file/placeholder/p57.png', '', 41.30, '3斤装,5斤装,10斤装', 80, 456, '天津西青', '沙窝萝卜 10斤装（老树），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (58, 2, 2, '沙窝萝卜 3斤装（当季）', '/api/file/placeholder/p58.png', '', 15.50, '3斤装,5斤装,10斤装', 150, 1126, '天津西青', '沙窝萝卜 3斤装（当季），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (59, 2, 2, '沙窝萝卜 5斤装（当季）', '/api/file/placeholder/p59.png', '', 18.10, '3斤装,5斤装,10斤装', 80, 405, '天津西青', '沙窝萝卜 5斤装（当季），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (60, 2, 2, '沙窝萝卜 10斤装（当季）', '/api/file/placeholder/p60.png', '', 25.20, '3斤装,5斤装,10斤装', 30, 1030, '天津西青', '沙窝萝卜 10斤装（当季），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (61, 3, 1, '茶淀玫瑰香葡萄 2斤装（精选）', '/api/file/placeholder/p61.png', '', 44.70, '2斤装,4斤装,6斤装', 50, 1861, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（精选），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (62, 3, 1, '茶淀玫瑰香葡萄 4斤装（精选）', '/api/file/placeholder/p62.png', '', 70.60, '2斤装,4斤装,6斤装', 50, 219, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（精选），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (63, 3, 1, '茶淀玫瑰香葡萄 6斤装（精选）', '/api/file/placeholder/p63.png', '', 57.50, '2斤装,4斤装,6斤装', 80, 226, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（精选），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (64, 3, 1, '茶淀玫瑰香葡萄 2斤装（特选）', '/api/file/placeholder/p64.png', '', 33.00, '2斤装,4斤装,6斤装', 500, 421, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（特选），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (65, 3, 1, '茶淀玫瑰香葡萄 4斤装（特选）', '/api/file/placeholder/p65.png', '', 71.00, '2斤装,4斤装,6斤装', 100, 895, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（特选），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (66, 3, 1, '茶淀玫瑰香葡萄 6斤装（特选）', '/api/file/placeholder/p66.png', '', 34.20, '2斤装,4斤装,6斤装', 200, 1474, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（特选），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (67, 3, 1, '茶淀玫瑰香葡萄 2斤装（家庭装）', '/api/file/placeholder/p67.png', '', 39.50, '2斤装,4斤装,6斤装', 300, 689, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（家庭装），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (68, 3, 1, '茶淀玫瑰香葡萄 4斤装（家庭装）', '/api/file/placeholder/p68.png', '', 45.60, '2斤装,4斤装,6斤装', 50, 294, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（家庭装），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (69, 3, 1, '茶淀玫瑰香葡萄 6斤装（家庭装）', '/api/file/placeholder/p69.png', '', 48.80, '2斤装,4斤装,6斤装', 200, 457, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（家庭装），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (70, 3, 1, '茶淀玫瑰香葡萄 2斤装（礼盒）', '/api/file/placeholder/p70.png', '', 37.60, '2斤装,4斤装,6斤装', 0, 6, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（礼盒），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (71, 3, 1, '茶淀玫瑰香葡萄 4斤装（礼盒）', '/api/file/placeholder/p71.png', '', 77.90, '2斤装,4斤装,6斤装', 80, 1299, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（礼盒），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (72, 3, 1, '茶淀玫瑰香葡萄 6斤装（礼盒）', '/api/file/placeholder/p72.png', '', 30.80, '2斤装,4斤装,6斤装', 500, 1838, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（礼盒），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (73, 3, 1, '茶淀玫瑰香葡萄 2斤装（生态）', '/api/file/placeholder/p73.png', '', 45.40, '2斤装,4斤装,6斤装', 50, 999, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（生态），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (74, 3, 1, '茶淀玫瑰香葡萄 4斤装（生态）', '/api/file/placeholder/p74.png', '', 53.50, '2斤装,4斤装,6斤装', 500, 318, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（生态），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (75, 3, 1, '茶淀玫瑰香葡萄 6斤装（生态）', '/api/file/placeholder/p75.png', '', 53.60, '2斤装,4斤装,6斤装', 15, 1118, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（生态），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (76, 3, 1, '茶淀玫瑰香葡萄 2斤装（头茬）', '/api/file/placeholder/p76.png', '', 53.80, '2斤装,4斤装,6斤装', 100, 865, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（头茬），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (77, 3, 1, '茶淀玫瑰香葡萄 4斤装（头茬）', '/api/file/placeholder/p77.png', '', 68.20, '2斤装,4斤装,6斤装', 30, 1327, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（头茬），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (78, 3, 1, '茶淀玫瑰香葡萄 6斤装（头茬）', '/api/file/placeholder/p78.png', '', 33.50, '2斤装,4斤装,6斤装', 300, 1014, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（头茬），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (79, 3, 1, '茶淀玫瑰香葡萄 2斤装（新货）', '/api/file/placeholder/p79.png', '', 51.80, '2斤装,4斤装,6斤装', 15, 1473, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（新货），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (80, 3, 1, '茶淀玫瑰香葡萄 4斤装（新货）', '/api/file/placeholder/p80.png', '', 58.50, '2斤装,4斤装,6斤装', 300, 847, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（新货），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (81, 3, 1, '茶淀玫瑰香葡萄 6斤装（新货）', '/api/file/placeholder/p81.png', '', 87.20, '2斤装,4斤装,6斤装', 30, 598, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（新货），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (82, 3, 1, '茶淀玫瑰香葡萄 2斤装（直供）', '/api/file/placeholder/p82.png', '', 40.20, '2斤装,4斤装,6斤装', 500, 962, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（直供），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (83, 3, 1, '茶淀玫瑰香葡萄 4斤装（直供）', '/api/file/placeholder/p83.png', '', 32.80, '2斤装,4斤装,6斤装', 200, 1733, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（直供），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (84, 3, 1, '茶淀玫瑰香葡萄 6斤装（直供）', '/api/file/placeholder/p84.png', '', 86.70, '2斤装,4斤装,6斤装', 150, 1247, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（直供），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (85, 3, 1, '茶淀玫瑰香葡萄 2斤装（老树）', '/api/file/placeholder/p85.png', '', 71.60, '2斤装,4斤装,6斤装', 0, 3, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（老树），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (86, 3, 1, '茶淀玫瑰香葡萄 4斤装（老树）', '/api/file/placeholder/p86.png', '', 51.90, '2斤装,4斤装,6斤装', 300, 438, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（老树），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (87, 3, 1, '茶淀玫瑰香葡萄 6斤装（老树）', '/api/file/placeholder/p87.png', '', 75.80, '2斤装,4斤装,6斤装', 150, 51, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（老树），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (88, 3, 1, '茶淀玫瑰香葡萄 2斤装（当季）', '/api/file/placeholder/p88.png', '', 28.60, '2斤装,4斤装,6斤装', 150, 826, '天津汉沽', '茶淀玫瑰香葡萄 2斤装（当季），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (89, 3, 1, '茶淀玫瑰香葡萄 4斤装（当季）', '/api/file/placeholder/p89.png', '', 45.40, '2斤装,4斤装,6斤装', 0, 9, '天津汉沽', '茶淀玫瑰香葡萄 4斤装（当季），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (90, 3, 1, '茶淀玫瑰香葡萄 6斤装（当季）', '/api/file/placeholder/p90.png', '', 35.30, '2斤装,4斤装,6斤装', 15, 419, '天津汉沽', '茶淀玫瑰香葡萄 6斤装（当季），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (91, 1, 1, '盘山磨盘柿 3斤装（精选）', '/api/file/placeholder/p91.png', '', 27.10, '3斤装,5斤装', 300, 1300, '天津蓟州', '盘山磨盘柿 3斤装（精选），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (92, 1, 1, '盘山磨盘柿 5斤装（精选）', '/api/file/placeholder/p92.png', '', 43.30, '3斤装,5斤装', 30, 1960, '天津蓟州', '盘山磨盘柿 5斤装（精选），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (93, 1, 1, '盘山磨盘柿 3斤装（特选）', '/api/file/placeholder/p93.png', '', 35.10, '3斤装,5斤装', 30, 698, '天津蓟州', '盘山磨盘柿 3斤装（特选），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (94, 1, 1, '盘山磨盘柿 5斤装（特选）', '/api/file/placeholder/p94.png', '', 51.80, '3斤装,5斤装', 200, 1630, '天津蓟州', '盘山磨盘柿 5斤装（特选），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (95, 1, 1, '盘山磨盘柿 3斤装（家庭装）', '/api/file/placeholder/p95.png', '', 53.10, '3斤装,5斤装', 300, 960, '天津蓟州', '盘山磨盘柿 3斤装（家庭装），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (96, 1, 1, '盘山磨盘柿 5斤装（家庭装）', '/api/file/placeholder/p96.png', '', 59.20, '3斤装,5斤装', 30, 13, '天津蓟州', '盘山磨盘柿 5斤装（家庭装），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (97, 1, 1, '盘山磨盘柿 3斤装（礼盒）', '/api/file/placeholder/p97.png', '', 29.80, '3斤装,5斤装', 50, 1748, '天津蓟州', '盘山磨盘柿 3斤装（礼盒），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (98, 1, 1, '盘山磨盘柿 5斤装（礼盒）', '/api/file/placeholder/p98.png', '', 54.20, '3斤装,5斤装', 500, 479, '天津蓟州', '盘山磨盘柿 5斤装（礼盒），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (99, 1, 1, '盘山磨盘柿 3斤装（生态）', '/api/file/placeholder/p99.png', '', 24.30, '3斤装,5斤装', 15, 947, '天津蓟州', '盘山磨盘柿 3斤装（生态），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (100, 1, 1, '盘山磨盘柿 5斤装（生态）', '/api/file/placeholder/p100.png', '', 40.50, '3斤装,5斤装', 15, 1672, '天津蓟州', '盘山磨盘柿 5斤装（生态），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (101, 1, 1, '盘山磨盘柿 3斤装（头茬）', '/api/file/placeholder/p101.png', '', 54.90, '3斤装,5斤装', 30, 1178, '天津蓟州', '盘山磨盘柿 3斤装（头茬），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (102, 1, 1, '盘山磨盘柿 5斤装（头茬）', '/api/file/placeholder/p102.png', '', 54.70, '3斤装,5斤装', 30, 1129, '天津蓟州', '盘山磨盘柿 5斤装（头茬），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (103, 1, 1, '盘山磨盘柿 3斤装（新货）', '/api/file/placeholder/p103.png', '', 25.70, '3斤装,5斤装', 30, 1662, '天津蓟州', '盘山磨盘柿 3斤装（新货），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (104, 1, 1, '盘山磨盘柿 5斤装（新货）', '/api/file/placeholder/p104.png', '', 28.40, '3斤装,5斤装', 300, 538, '天津蓟州', '盘山磨盘柿 5斤装（新货），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (105, 1, 1, '盘山磨盘柿 3斤装（直供）', '/api/file/placeholder/p105.png', '', 23.80, '3斤装,5斤装', 80, 1773, '天津蓟州', '盘山磨盘柿 3斤装（直供），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (106, 1, 1, '盘山磨盘柿 5斤装（直供）', '/api/file/placeholder/p106.png', '', 54.30, '3斤装,5斤装', 50, 1220, '天津蓟州', '盘山磨盘柿 5斤装（直供），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (107, 1, 1, '盘山磨盘柿 3斤装（老树）', '/api/file/placeholder/p107.png', '', 19.30, '3斤装,5斤装', 15, 1083, '天津蓟州', '盘山磨盘柿 3斤装（老树），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (108, 1, 1, '盘山磨盘柿 5斤装（老树）', '/api/file/placeholder/p108.png', '', 34.40, '3斤装,5斤装', 300, 874, '天津蓟州', '盘山磨盘柿 5斤装（老树），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (109, 1, 1, '盘山磨盘柿 3斤装（当季）', '/api/file/placeholder/p109.png', '', 31.00, '3斤装,5斤装', 500, 1066, '天津蓟州', '盘山磨盘柿 3斤装（当季），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (110, 1, 1, '盘山磨盘柿 5斤装（当季）', '/api/file/placeholder/p110.png', '', 52.90, '3斤装,5斤装', 30, 1292, '天津蓟州', '盘山磨盘柿 5斤装（当季），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (111, 5, 4, '七里海河蟹 公蟹4只装（精选）', '/api/file/placeholder/p111.png', '', 114.10, '公蟹4只装,母蟹4只装,公母混装8只', 50, 968, '天津宁河', '七里海河蟹 公蟹4只装（精选），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (112, 5, 4, '七里海河蟹 母蟹4只装（精选）', '/api/file/placeholder/p112.png', '', 168.90, '公蟹4只装,母蟹4只装,公母混装8只', 150, 1225, '天津宁河', '七里海河蟹 母蟹4只装（精选），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (113, 5, 4, '七里海河蟹 公母混装8只（精选）', '/api/file/placeholder/p113.png', '', 184.10, '公蟹4只装,母蟹4只装,公母混装8只', 300, 1991, '天津宁河', '七里海河蟹 公母混装8只（精选），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (114, 5, 4, '七里海河蟹 公蟹4只装（特选）', '/api/file/placeholder/p114.png', '', 122.00, '公蟹4只装,母蟹4只装,公母混装8只', 15, 510, '天津宁河', '七里海河蟹 公蟹4只装（特选），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (115, 5, 4, '七里海河蟹 母蟹4只装（特选）', '/api/file/placeholder/p115.png', '', 204.70, '公蟹4只装,母蟹4只装,公母混装8只', 50, 1870, '天津宁河', '七里海河蟹 母蟹4只装（特选），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (116, 5, 4, '七里海河蟹 公母混装8只（特选）', '/api/file/placeholder/p116.png', '', 120.70, '公蟹4只装,母蟹4只装,公母混装8只', 80, 448, '天津宁河', '七里海河蟹 公母混装8只（特选），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (117, 5, 4, '七里海河蟹 公蟹4只装（家庭装）', '/api/file/placeholder/p117.png', '', 304.70, '公蟹4只装,母蟹4只装,公母混装8只', 150, 1726, '天津宁河', '七里海河蟹 公蟹4只装（家庭装），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (118, 5, 4, '七里海河蟹 母蟹4只装（家庭装）', '/api/file/placeholder/p118.png', '', 248.30, '公蟹4只装,母蟹4只装,公母混装8只', 50, 620, '天津宁河', '七里海河蟹 母蟹4只装（家庭装），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (119, 5, 4, '七里海河蟹 公母混装8只（家庭装）', '/api/file/placeholder/p119.png', '', 220.90, '公蟹4只装,母蟹4只装,公母混装8只', 300, 450, '天津宁河', '七里海河蟹 公母混装8只（家庭装），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (120, 5, 4, '七里海河蟹 公蟹4只装（礼盒）', '/api/file/placeholder/p120.png', '', 218.00, '公蟹4只装,母蟹4只装,公母混装8只', 150, 553, '天津宁河', '七里海河蟹 公蟹4只装（礼盒），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (121, 5, 4, '七里海河蟹 母蟹4只装（礼盒）', '/api/file/placeholder/p121.png', '', 218.70, '公蟹4只装,母蟹4只装,公母混装8只', 15, 1145, '天津宁河', '七里海河蟹 母蟹4只装（礼盒），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (122, 5, 4, '七里海河蟹 公母混装8只（礼盒）', '/api/file/placeholder/p122.png', '', 203.30, '公蟹4只装,母蟹4只装,公母混装8只', 50, 204, '天津宁河', '七里海河蟹 公母混装8只（礼盒），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (123, 5, 4, '七里海河蟹 公蟹4只装（生态）', '/api/file/placeholder/p123.png', '', 172.00, '公蟹4只装,母蟹4只装,公母混装8只', 200, 236, '天津宁河', '七里海河蟹 公蟹4只装（生态），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (124, 5, 4, '七里海河蟹 母蟹4只装（生态）', '/api/file/placeholder/p124.png', '', 103.60, '公蟹4只装,母蟹4只装,公母混装8只', 150, 1996, '天津宁河', '七里海河蟹 母蟹4只装（生态），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (125, 5, 4, '七里海河蟹 公母混装8只（生态）', '/api/file/placeholder/p125.png', '', 150.60, '公蟹4只装,母蟹4只装,公母混装8只', 100, 1543, '天津宁河', '七里海河蟹 公母混装8只（生态），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (126, 5, 4, '七里海河蟹 公蟹4只装（头茬）', '/api/file/placeholder/p126.png', '', 265.50, '公蟹4只装,母蟹4只装,公母混装8只', 0, 23, '天津宁河', '七里海河蟹 公蟹4只装（头茬），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (127, 5, 4, '七里海河蟹 母蟹4只装（头茬）', '/api/file/placeholder/p127.png', '', 125.80, '公蟹4只装,母蟹4只装,公母混装8只', 30, 847, '天津宁河', '七里海河蟹 母蟹4只装（头茬），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (128, 5, 4, '七里海河蟹 公母混装8只（头茬）', '/api/file/placeholder/p128.png', '', 108.00, '公蟹4只装,母蟹4只装,公母混装8只', 50, 1100, '天津宁河', '七里海河蟹 公母混装8只（头茬），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (129, 5, 4, '七里海河蟹 公蟹4只装（新货）', '/api/file/placeholder/p129.png', '', 251.60, '公蟹4只装,母蟹4只装,公母混装8只', 200, 710, '天津宁河', '七里海河蟹 公蟹4只装（新货），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (130, 5, 4, '七里海河蟹 母蟹4只装（新货）', '/api/file/placeholder/p130.png', '', 210.00, '公蟹4只装,母蟹4只装,公母混装8只', 300, 188, '天津宁河', '七里海河蟹 母蟹4只装（新货），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (131, 5, 4, '七里海河蟹 公母混装8只（新货）', '/api/file/placeholder/p131.png', '', 92.10, '公蟹4只装,母蟹4只装,公母混装8只', 30, 842, '天津宁河', '七里海河蟹 公母混装8只（新货），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (132, 5, 4, '七里海河蟹 公蟹4只装（直供）', '/api/file/placeholder/p132.png', '', 263.60, '公蟹4只装,母蟹4只装,公母混装8只', 150, 934, '天津宁河', '七里海河蟹 公蟹4只装（直供），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (133, 5, 4, '七里海河蟹 母蟹4只装（直供）', '/api/file/placeholder/p133.png', '', 310.20, '公蟹4只装,母蟹4只装,公母混装8只', 200, 302, '天津宁河', '七里海河蟹 母蟹4只装（直供），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (134, 5, 4, '七里海河蟹 公母混装8只（直供）', '/api/file/placeholder/p134.png', '', 312.50, '公蟹4只装,母蟹4只装,公母混装8只', 150, 1050, '天津宁河', '七里海河蟹 公母混装8只（直供），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (135, 5, 4, '七里海河蟹 公蟹4只装（老树）', '/api/file/placeholder/p135.png', '', 288.00, '公蟹4只装,母蟹4只装,公母混装8只', 15, 937, '天津宁河', '七里海河蟹 公蟹4只装（老树），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (136, 5, 4, '七里海河蟹 母蟹4只装（老树）', '/api/file/placeholder/p136.png', '', 204.50, '公蟹4只装,母蟹4只装,公母混装8只', 15, 1664, '天津宁河', '七里海河蟹 母蟹4只装（老树），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (137, 5, 4, '七里海河蟹 公母混装8只（老树）', '/api/file/placeholder/p137.png', '', 270.00, '公蟹4只装,母蟹4只装,公母混装8只', 80, 432, '天津宁河', '七里海河蟹 公母混装8只（老树），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (138, 5, 4, '七里海河蟹 公蟹4只装（当季）', '/api/file/placeholder/p138.png', '', 231.10, '公蟹4只装,母蟹4只装,公母混装8只', 200, 81, '天津宁河', '七里海河蟹 公蟹4只装（当季），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (139, 5, 4, '七里海河蟹 母蟹4只装（当季）', '/api/file/placeholder/p139.png', '', 233.40, '公蟹4只装,母蟹4只装,公母混装8只', 200, 1602, '天津宁河', '七里海河蟹 母蟹4只装（当季），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (140, 5, 4, '七里海河蟹 公母混装8只（当季）', '/api/file/placeholder/p140.png', '', 323.20, '公蟹4只装,母蟹4只装,公母混装8只', 150, 464, '天津宁河', '七里海河蟹 公母混装8只（当季），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (141, 4, 5, '静海金丝小枣 1斤装（精选）', '/api/file/placeholder/p141.png', '', 41.50, '1斤装,2斤装,5斤装', 50, 1244, '天津静海', '静海金丝小枣 1斤装（精选），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (142, 4, 5, '静海金丝小枣 2斤装（精选）', '/api/file/placeholder/p142.png', '', 40.90, '1斤装,2斤装,5斤装', 500, 380, '天津静海', '静海金丝小枣 2斤装（精选），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (143, 4, 5, '静海金丝小枣 5斤装（精选）', '/api/file/placeholder/p143.png', '', 20.00, '1斤装,2斤装,5斤装', 300, 938, '天津静海', '静海金丝小枣 5斤装（精选），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (144, 4, 5, '静海金丝小枣 1斤装（特选）', '/api/file/placeholder/p144.png', '', 40.60, '1斤装,2斤装,5斤装', 15, 238, '天津静海', '静海金丝小枣 1斤装（特选），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (145, 4, 5, '静海金丝小枣 2斤装（特选）', '/api/file/placeholder/p145.png', '', 58.60, '1斤装,2斤装,5斤装', 200, 107, '天津静海', '静海金丝小枣 2斤装（特选），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (146, 4, 5, '静海金丝小枣 5斤装（特选）', '/api/file/placeholder/p146.png', '', 53.80, '1斤装,2斤装,5斤装', 150, 1846, '天津静海', '静海金丝小枣 5斤装（特选），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (147, 4, 5, '静海金丝小枣 1斤装（家庭装）', '/api/file/placeholder/p147.png', '', 34.90, '1斤装,2斤装,5斤装', 80, 209, '天津静海', '静海金丝小枣 1斤装（家庭装），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (148, 4, 5, '静海金丝小枣 2斤装（家庭装）', '/api/file/placeholder/p148.png', '', 25.70, '1斤装,2斤装,5斤装', 100, 638, '天津静海', '静海金丝小枣 2斤装（家庭装），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (149, 4, 5, '静海金丝小枣 5斤装（家庭装）', '/api/file/placeholder/p149.png', '', 54.10, '1斤装,2斤装,5斤装', 100, 1306, '天津静海', '静海金丝小枣 5斤装（家庭装），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (150, 4, 5, '静海金丝小枣 1斤装（礼盒）', '/api/file/placeholder/p150.png', '', 46.00, '1斤装,2斤装,5斤装', 500, 951, '天津静海', '静海金丝小枣 1斤装（礼盒），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (151, 4, 5, '静海金丝小枣 2斤装（礼盒）', '/api/file/placeholder/p151.png', '', 18.90, '1斤装,2斤装,5斤装', 15, 1022, '天津静海', '静海金丝小枣 2斤装（礼盒），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (152, 4, 5, '静海金丝小枣 5斤装（礼盒）', '/api/file/placeholder/p152.png', '', 32.90, '1斤装,2斤装,5斤装', 200, 1548, '天津静海', '静海金丝小枣 5斤装（礼盒），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (153, 4, 5, '静海金丝小枣 1斤装（生态）', '/api/file/placeholder/p153.png', '', 56.00, '1斤装,2斤装,5斤装', 150, 1162, '天津静海', '静海金丝小枣 1斤装（生态），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (154, 4, 5, '静海金丝小枣 2斤装（生态）', '/api/file/placeholder/p154.png', '', 30.20, '1斤装,2斤装,5斤装', 15, 836, '天津静海', '静海金丝小枣 2斤装（生态），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (155, 4, 5, '静海金丝小枣 5斤装（生态）', '/api/file/placeholder/p155.png', '', 38.00, '1斤装,2斤装,5斤装', 80, 1511, '天津静海', '静海金丝小枣 5斤装（生态），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (156, 4, 5, '静海金丝小枣 1斤装（头茬）', '/api/file/placeholder/p156.png', '', 46.80, '1斤装,2斤装,5斤装', 300, 1060, '天津静海', '静海金丝小枣 1斤装（头茬），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (157, 4, 5, '静海金丝小枣 2斤装（头茬）', '/api/file/placeholder/p157.png', '', 54.40, '1斤装,2斤装,5斤装', 100, 753, '天津静海', '静海金丝小枣 2斤装（头茬），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (158, 4, 5, '静海金丝小枣 5斤装（头茬）', '/api/file/placeholder/p158.png', '', 62.40, '1斤装,2斤装,5斤装', 30, 719, '天津静海', '静海金丝小枣 5斤装（头茬），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (159, 4, 5, '静海金丝小枣 1斤装（新货）', '/api/file/placeholder/p159.png', '', 58.30, '1斤装,2斤装,5斤装', 0, 15, '天津静海', '静海金丝小枣 1斤装（新货），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (160, 4, 5, '静海金丝小枣 2斤装（新货）', '/api/file/placeholder/p160.png', '', 55.70, '1斤装,2斤装,5斤装', 15, 1895, '天津静海', '静海金丝小枣 2斤装（新货），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (161, 4, 5, '静海金丝小枣 5斤装（新货）', '/api/file/placeholder/p161.png', '', 16.90, '1斤装,2斤装,5斤装', 200, 698, '天津静海', '静海金丝小枣 5斤装（新货），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (162, 4, 5, '静海金丝小枣 1斤装（直供）', '/api/file/placeholder/p162.png', '', 47.10, '1斤装,2斤装,5斤装', 200, 771, '天津静海', '静海金丝小枣 1斤装（直供），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (163, 4, 5, '静海金丝小枣 2斤装（直供）', '/api/file/placeholder/p163.png', '', 35.50, '1斤装,2斤装,5斤装', 15, 773, '天津静海', '静海金丝小枣 2斤装（直供），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (164, 4, 5, '静海金丝小枣 5斤装（直供）', '/api/file/placeholder/p164.png', '', 39.40, '1斤装,2斤装,5斤装', 300, 685, '天津静海', '静海金丝小枣 5斤装（直供），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (165, 4, 5, '静海金丝小枣 1斤装（老树）', '/api/file/placeholder/p165.png', '', 52.20, '1斤装,2斤装,5斤装', 300, 1868, '天津静海', '静海金丝小枣 1斤装（老树），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (166, 4, 5, '静海金丝小枣 2斤装（老树）', '/api/file/placeholder/p166.png', '', 40.50, '1斤装,2斤装,5斤装', 30, 634, '天津静海', '静海金丝小枣 2斤装（老树），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (167, 4, 5, '静海金丝小枣 5斤装（老树）', '/api/file/placeholder/p167.png', '', 47.20, '1斤装,2斤装,5斤装', 80, 1826, '天津静海', '静海金丝小枣 5斤装（老树），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (168, 4, 5, '静海金丝小枣 1斤装（当季）', '/api/file/placeholder/p168.png', '', 35.80, '1斤装,2斤装,5斤装', 100, 776, '天津静海', '静海金丝小枣 1斤装（当季），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (169, 4, 5, '静海金丝小枣 2斤装（当季）', '/api/file/placeholder/p169.png', '', 52.10, '1斤装,2斤装,5斤装', 15, 1399, '天津静海', '静海金丝小枣 2斤装（当季），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (170, 4, 5, '静海金丝小枣 5斤装（当季）', '/api/file/placeholder/p170.png', '', 62.40, '1斤装,2斤装,5斤装', 15, 1040, '天津静海', '静海金丝小枣 5斤装（当季），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (171, 1, 5, '燕山板栗 2斤装（精选）', '/api/file/placeholder/p171.png', '', 28.90, '2斤装,4斤装', 150, 931, '天津蓟州', '燕山板栗 2斤装（精选），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (172, 1, 5, '燕山板栗 4斤装（精选）', '/api/file/placeholder/p172.png', '', 41.90, '2斤装,4斤装', 15, 1860, '天津蓟州', '燕山板栗 4斤装（精选），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (173, 1, 5, '燕山板栗 2斤装（特选）', '/api/file/placeholder/p173.png', '', 61.30, '2斤装,4斤装', 150, 1823, '天津蓟州', '燕山板栗 2斤装（特选），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (174, 1, 5, '燕山板栗 4斤装（特选）', '/api/file/placeholder/p174.png', '', 46.60, '2斤装,4斤装', 0, 26, '天津蓟州', '燕山板栗 4斤装（特选），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (175, 1, 5, '燕山板栗 2斤装（家庭装）', '/api/file/placeholder/p175.png', '', 49.10, '2斤装,4斤装', 0, 22, '天津蓟州', '燕山板栗 2斤装（家庭装），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (176, 1, 5, '燕山板栗 4斤装（家庭装）', '/api/file/placeholder/p176.png', '', 49.30, '2斤装,4斤装', 300, 418, '天津蓟州', '燕山板栗 4斤装（家庭装），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (177, 1, 5, '燕山板栗 2斤装（礼盒）', '/api/file/placeholder/p177.png', '', 44.60, '2斤装,4斤装', 100, 1960, '天津蓟州', '燕山板栗 2斤装（礼盒），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (178, 1, 5, '燕山板栗 4斤装（礼盒）', '/api/file/placeholder/p178.png', '', 63.20, '2斤装,4斤装', 80, 962, '天津蓟州', '燕山板栗 4斤装（礼盒），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (179, 1, 5, '燕山板栗 2斤装（生态）', '/api/file/placeholder/p179.png', '', 50.00, '2斤装,4斤装', 100, 768, '天津蓟州', '燕山板栗 2斤装（生态），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (180, 1, 5, '燕山板栗 4斤装（生态）', '/api/file/placeholder/p180.png', '', 26.60, '2斤装,4斤装', 300, 1329, '天津蓟州', '燕山板栗 4斤装（生态），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (181, 1, 5, '燕山板栗 2斤装（头茬）', '/api/file/placeholder/p181.png', '', 68.30, '2斤装,4斤装', 100, 394, '天津蓟州', '燕山板栗 2斤装（头茬），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (182, 1, 5, '燕山板栗 4斤装（头茬）', '/api/file/placeholder/p182.png', '', 30.20, '2斤装,4斤装', 500, 302, '天津蓟州', '燕山板栗 4斤装（头茬），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (183, 1, 5, '燕山板栗 2斤装（新货）', '/api/file/placeholder/p183.png', '', 40.70, '2斤装,4斤装', 100, 1977, '天津蓟州', '燕山板栗 2斤装（新货），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (184, 1, 5, '燕山板栗 4斤装（新货）', '/api/file/placeholder/p184.png', '', 30.90, '2斤装,4斤装', 80, 905, '天津蓟州', '燕山板栗 4斤装（新货），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (185, 1, 5, '燕山板栗 2斤装（直供）', '/api/file/placeholder/p185.png', '', 44.80, '2斤装,4斤装', 50, 1764, '天津蓟州', '燕山板栗 2斤装（直供），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (186, 1, 5, '燕山板栗 4斤装（直供）', '/api/file/placeholder/p186.png', '', 63.20, '2斤装,4斤装', 30, 899, '天津蓟州', '燕山板栗 4斤装（直供），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (187, 1, 5, '燕山板栗 2斤装（老树）', '/api/file/placeholder/p187.png', '', 36.00, '2斤装,4斤装', 100, 713, '天津蓟州', '燕山板栗 2斤装（老树），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (188, 1, 5, '燕山板栗 4斤装（老树）', '/api/file/placeholder/p188.png', '', 30.50, '2斤装,4斤装', 80, 1932, '天津蓟州', '燕山板栗 4斤装（老树），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (189, 1, 5, '燕山板栗 2斤装（当季）', '/api/file/placeholder/p189.png', '', 57.00, '2斤装,4斤装', 100, 1930, '天津蓟州', '燕山板栗 2斤装（当季），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (190, 1, 5, '燕山板栗 4斤装（当季）', '/api/file/placeholder/p190.png', '', 65.10, '2斤装,4斤装', 200, 384, '天津蓟州', '燕山板栗 4斤装（当季），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (191, 6, 6, '宝坻天鹰椒 1斤装（精选）', '/api/file/placeholder/p191.png', '', 24.70, '1斤装,2斤装', 200, 919, '天津宝坻', '宝坻天鹰椒 1斤装（精选），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (192, 6, 6, '宝坻天鹰椒 2斤装（精选）', '/api/file/placeholder/p192.png', '', 22.80, '1斤装,2斤装', 100, 1207, '天津宝坻', '宝坻天鹰椒 2斤装（精选），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (193, 6, 6, '宝坻天鹰椒 1斤装（特选）', '/api/file/placeholder/p193.png', '', 27.40, '1斤装,2斤装', 200, 1029, '天津宝坻', '宝坻天鹰椒 1斤装（特选），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (194, 6, 6, '宝坻天鹰椒 2斤装（特选）', '/api/file/placeholder/p194.png', '', 17.80, '1斤装,2斤装', 30, 525, '天津宝坻', '宝坻天鹰椒 2斤装（特选），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (195, 6, 6, '宝坻天鹰椒 1斤装（家庭装）', '/api/file/placeholder/p195.png', '', 12.60, '1斤装,2斤装', 150, 1651, '天津宝坻', '宝坻天鹰椒 1斤装（家庭装），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (196, 6, 6, '宝坻天鹰椒 2斤装（家庭装）', '/api/file/placeholder/p196.png', '', 31.80, '1斤装,2斤装', 50, 1960, '天津宝坻', '宝坻天鹰椒 2斤装（家庭装），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (197, 6, 6, '宝坻天鹰椒 1斤装（礼盒）', '/api/file/placeholder/p197.png', '', 25.10, '1斤装,2斤装', 0, 21, '天津宝坻', '宝坻天鹰椒 1斤装（礼盒），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (198, 6, 6, '宝坻天鹰椒 2斤装（礼盒）', '/api/file/placeholder/p198.png', '', 29.10, '1斤装,2斤装', 500, 967, '天津宝坻', '宝坻天鹰椒 2斤装（礼盒），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (199, 6, 6, '宝坻天鹰椒 1斤装（生态）', '/api/file/placeholder/p199.png', '', 35.20, '1斤装,2斤装', 80, 447, '天津宝坻', '宝坻天鹰椒 1斤装（生态），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (200, 6, 6, '宝坻天鹰椒 2斤装（生态）', '/api/file/placeholder/p200.png', '', 18.00, '1斤装,2斤装', 300, 81, '天津宝坻', '宝坻天鹰椒 2斤装（生态），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (201, 6, 6, '宝坻天鹰椒 1斤装（头茬）', '/api/file/placeholder/p201.png', '', 16.80, '1斤装,2斤装', 500, 1060, '天津宝坻', '宝坻天鹰椒 1斤装（头茬），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (202, 6, 6, '宝坻天鹰椒 2斤装（头茬）', '/api/file/placeholder/p202.png', '', 23.30, '1斤装,2斤装', 0, 1, '天津宝坻', '宝坻天鹰椒 2斤装（头茬），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (203, 6, 6, '宝坻天鹰椒 1斤装（新货）', '/api/file/placeholder/p203.png', '', 17.30, '1斤装,2斤装', 300, 186, '天津宝坻', '宝坻天鹰椒 1斤装（新货），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (204, 6, 6, '宝坻天鹰椒 2斤装（新货）', '/api/file/placeholder/p204.png', '', 21.70, '1斤装,2斤装', 30, 399, '天津宝坻', '宝坻天鹰椒 2斤装（新货），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (205, 6, 6, '宝坻天鹰椒 1斤装（直供）', '/api/file/placeholder/p205.png', '', 23.80, '1斤装,2斤装', 80, 1742, '天津宝坻', '宝坻天鹰椒 1斤装（直供），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (206, 6, 6, '宝坻天鹰椒 2斤装（直供）', '/api/file/placeholder/p206.png', '', 23.80, '1斤装,2斤装', 100, 1386, '天津宝坻', '宝坻天鹰椒 2斤装（直供），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (207, 6, 6, '宝坻天鹰椒 1斤装（老树）', '/api/file/placeholder/p207.png', '', 14.30, '1斤装,2斤装', 30, 1182, '天津宝坻', '宝坻天鹰椒 1斤装（老树），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (208, 6, 6, '宝坻天鹰椒 2斤装（老树）', '/api/file/placeholder/p208.png', '', 28.70, '1斤装,2斤装', 500, 96, '天津宝坻', '宝坻天鹰椒 2斤装（老树），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (209, 6, 6, '宝坻天鹰椒 1斤装（当季）', '/api/file/placeholder/p209.png', '', 24.30, '1斤装,2斤装', 150, 550, '天津宝坻', '宝坻天鹰椒 1斤装（当季），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (210, 6, 6, '宝坻天鹰椒 2斤装（当季）', '/api/file/placeholder/p210.png', '', 18.30, '1斤装,2斤装', 15, 1693, '天津宝坻', '宝坻天鹰椒 2斤装（当季），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (211, 7, 1, '武清奶油草莓 2盒装（精选）', '/api/file/placeholder/p211.png', '', 55.00, '2盒装,4盒装', 300, 308, '天津武清', '武清奶油草莓 2盒装（精选），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (212, 7, 1, '武清奶油草莓 4盒装（精选）', '/api/file/placeholder/p212.png', '', 46.60, '2盒装,4盒装', 200, 1865, '天津武清', '武清奶油草莓 4盒装（精选），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (213, 7, 1, '武清奶油草莓 2盒装（特选）', '/api/file/placeholder/p213.png', '', 75.30, '2盒装,4盒装', 15, 292, '天津武清', '武清奶油草莓 2盒装（特选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (214, 7, 1, '武清奶油草莓 4盒装（特选）', '/api/file/placeholder/p214.png', '', 42.30, '2盒装,4盒装', 0, 10, '天津武清', '武清奶油草莓 4盒装（特选），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (215, 7, 1, '武清奶油草莓 2盒装（家庭装）', '/api/file/placeholder/p215.png', '', 58.40, '2盒装,4盒装', 300, 1835, '天津武清', '武清奶油草莓 2盒装（家庭装），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (216, 7, 1, '武清奶油草莓 4盒装（家庭装）', '/api/file/placeholder/p216.png', '', 83.20, '2盒装,4盒装', 30, 1485, '天津武清', '武清奶油草莓 4盒装（家庭装），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (217, 7, 1, '武清奶油草莓 2盒装（礼盒）', '/api/file/placeholder/p217.png', '', 59.90, '2盒装,4盒装', 80, 280, '天津武清', '武清奶油草莓 2盒装（礼盒），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (218, 7, 1, '武清奶油草莓 4盒装（礼盒）', '/api/file/placeholder/p218.png', '', 65.70, '2盒装,4盒装', 15, 1162, '天津武清', '武清奶油草莓 4盒装（礼盒），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (219, 7, 1, '武清奶油草莓 2盒装（生态）', '/api/file/placeholder/p219.png', '', 93.10, '2盒装,4盒装', 30, 1347, '天津武清', '武清奶油草莓 2盒装（生态），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (220, 7, 1, '武清奶油草莓 4盒装（生态）', '/api/file/placeholder/p220.png', '', 47.40, '2盒装,4盒装', 300, 548, '天津武清', '武清奶油草莓 4盒装（生态），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (221, 7, 1, '武清奶油草莓 2盒装（头茬）', '/api/file/placeholder/p221.png', '', 40.70, '2盒装,4盒装', 100, 1623, '天津武清', '武清奶油草莓 2盒装（头茬），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (222, 7, 1, '武清奶油草莓 4盒装（头茬）', '/api/file/placeholder/p222.png', '', 77.60, '2盒装,4盒装', 150, 375, '天津武清', '武清奶油草莓 4盒装（头茬），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (223, 7, 1, '武清奶油草莓 2盒装（新货）', '/api/file/placeholder/p223.png', '', 74.20, '2盒装,4盒装', 80, 1908, '天津武清', '武清奶油草莓 2盒装（新货），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (224, 7, 1, '武清奶油草莓 4盒装（新货）', '/api/file/placeholder/p224.png', '', 71.20, '2盒装,4盒装', 80, 1903, '天津武清', '武清奶油草莓 4盒装（新货），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (225, 7, 1, '武清奶油草莓 2盒装（直供）', '/api/file/placeholder/p225.png', '', 86.40, '2盒装,4盒装', 300, 473, '天津武清', '武清奶油草莓 2盒装（直供），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (226, 7, 1, '武清奶油草莓 4盒装（直供）', '/api/file/placeholder/p226.png', '', 58.80, '2盒装,4盒装', 15, 1233, '天津武清', '武清奶油草莓 4盒装（直供），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (227, 7, 1, '武清奶油草莓 2盒装（老树）', '/api/file/placeholder/p227.png', '', 62.30, '2盒装,4盒装', 150, 1418, '天津武清', '武清奶油草莓 2盒装（老树），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (228, 7, 1, '武清奶油草莓 4盒装（老树）', '/api/file/placeholder/p228.png', '', 71.40, '2盒装,4盒装', 80, 1450, '天津武清', '武清奶油草莓 4盒装（老树），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (229, 7, 1, '武清奶油草莓 2盒装（当季）', '/api/file/placeholder/p229.png', '', 37.00, '2盒装,4盒装', 0, 12, '天津武清', '武清奶油草莓 2盒装（当季），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (230, 7, 1, '武清奶油草莓 4盒装（当季）', '/api/file/placeholder/p230.png', '', 51.20, '2盒装,4盒装', 30, 1771, '天津武清', '武清奶油草莓 4盒装（当季），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (231, 7, 2, '有机番茄 3斤装（精选）', '/api/file/placeholder/p231.png', '', 22.70, '3斤装,5斤装', 80, 1933, '天津武清', '有机番茄 3斤装（精选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (232, 7, 2, '有机番茄 5斤装（精选）', '/api/file/placeholder/p232.png', '', 27.60, '3斤装,5斤装', 30, 1398, '天津武清', '有机番茄 5斤装（精选），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (233, 7, 2, '有机番茄 3斤装（特选）', '/api/file/placeholder/p233.png', '', 15.30, '3斤装,5斤装', 500, 1906, '天津武清', '有机番茄 3斤装（特选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (234, 7, 2, '有机番茄 5斤装（特选）', '/api/file/placeholder/p234.png', '', 16.80, '3斤装,5斤装', 300, 471, '天津武清', '有机番茄 5斤装（特选），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (235, 7, 2, '有机番茄 3斤装（家庭装）', '/api/file/placeholder/p235.png', '', 22.30, '3斤装,5斤装', 0, 8, '天津武清', '有机番茄 3斤装（家庭装），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (236, 7, 2, '有机番茄 5斤装（家庭装）', '/api/file/placeholder/p236.png', '', 20.20, '3斤装,5斤装', 200, 175, '天津武清', '有机番茄 5斤装（家庭装），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (237, 7, 2, '有机番茄 3斤装（礼盒）', '/api/file/placeholder/p237.png', '', 39.90, '3斤装,5斤装', 15, 1494, '天津武清', '有机番茄 3斤装（礼盒），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (238, 7, 2, '有机番茄 5斤装（礼盒）', '/api/file/placeholder/p238.png', '', 17.20, '3斤装,5斤装', 200, 694, '天津武清', '有机番茄 5斤装（礼盒），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (239, 7, 2, '有机番茄 3斤装（生态）', '/api/file/placeholder/p239.png', '', 38.90, '3斤装,5斤装', 100, 1966, '天津武清', '有机番茄 3斤装（生态），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (240, 7, 2, '有机番茄 5斤装（生态）', '/api/file/placeholder/p240.png', '', 22.80, '3斤装,5斤装', 50, 1246, '天津武清', '有机番茄 5斤装（生态），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (241, 7, 2, '有机番茄 3斤装（头茬）', '/api/file/placeholder/p241.png', '', 21.50, '3斤装,5斤装', 15, 143, '天津武清', '有机番茄 3斤装（头茬），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (242, 7, 2, '有机番茄 5斤装（头茬）', '/api/file/placeholder/p242.png', '', 19.00, '3斤装,5斤装', 80, 1217, '天津武清', '有机番茄 5斤装（头茬），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (243, 7, 2, '有机番茄 3斤装（新货）', '/api/file/placeholder/p243.png', '', 42.70, '3斤装,5斤装', 15, 1592, '天津武清', '有机番茄 3斤装（新货），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (244, 7, 2, '有机番茄 5斤装（新货）', '/api/file/placeholder/p244.png', '', 23.30, '3斤装,5斤装', 300, 186, '天津武清', '有机番茄 5斤装（新货），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (245, 7, 2, '有机番茄 3斤装（直供）', '/api/file/placeholder/p245.png', '', 17.30, '3斤装,5斤装', 200, 927, '天津武清', '有机番茄 3斤装（直供），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (246, 7, 2, '有机番茄 5斤装（直供）', '/api/file/placeholder/p246.png', '', 26.90, '3斤装,5斤装', 30, 129, '天津武清', '有机番茄 5斤装（直供），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (247, 7, 2, '有机番茄 3斤装（老树）', '/api/file/placeholder/p247.png', '', 19.60, '3斤装,5斤装', 15, 405, '天津武清', '有机番茄 3斤装（老树），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (248, 7, 2, '有机番茄 5斤装（老树）', '/api/file/placeholder/p248.png', '', 18.20, '3斤装,5斤装', 200, 720, '天津武清', '有机番茄 5斤装（老树），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (249, 7, 2, '有机番茄 3斤装（当季）', '/api/file/placeholder/p249.png', '', 23.60, '3斤装,5斤装', 0, 2, '天津武清', '有机番茄 3斤装（当季），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (250, 7, 2, '有机番茄 5斤装（当季）', '/api/file/placeholder/p250.png', '', 33.90, '3斤装,5斤装', 500, 697, '天津武清', '有机番茄 5斤装（当季），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (251, 8, 1, '北辰红颜草莓 3盒装（精选）', '/api/file/placeholder/p251.png', '', 79.50, '3盒装,6盒装', 15, 1046, '天津北辰', '北辰红颜草莓 3盒装（精选），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (252, 8, 1, '北辰红颜草莓 6盒装（精选）', '/api/file/placeholder/p252.png', '', 76.10, '3盒装,6盒装', 30, 644, '天津北辰', '北辰红颜草莓 6盒装（精选），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (253, 8, 1, '北辰红颜草莓 3盒装（特选）', '/api/file/placeholder/p253.png', '', 81.20, '3盒装,6盒装', 150, 1859, '天津北辰', '北辰红颜草莓 3盒装（特选），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (254, 8, 1, '北辰红颜草莓 6盒装（特选）', '/api/file/placeholder/p254.png', '', 89.50, '3盒装,6盒装', 15, 1572, '天津北辰', '北辰红颜草莓 6盒装（特选），产自天津北辰，坏果包赔。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (255, 8, 1, '北辰红颜草莓 3盒装（家庭装）', '/api/file/placeholder/p255.png', '', 100.60, '3盒装,6盒装', 50, 1569, '天津北辰', '北辰红颜草莓 3盒装（家庭装），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (256, 8, 1, '北辰红颜草莓 6盒装（家庭装）', '/api/file/placeholder/p256.png', '', 50.60, '3盒装,6盒装', 0, 18, '天津北辰', '北辰红颜草莓 6盒装（家庭装），产自天津北辰，当日现摘现发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (257, 8, 1, '北辰红颜草莓 3盒装（礼盒）', '/api/file/placeholder/p257.png', '', 91.70, '3盒装,6盒装', 50, 1182, '天津北辰', '北辰红颜草莓 3盒装（礼盒），产自天津北辰，坏果包赔。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (258, 8, 1, '北辰红颜草莓 6盒装（礼盒）', '/api/file/placeholder/p258.png', '', 59.70, '3盒装,6盒装', 50, 734, '天津北辰', '北辰红颜草莓 6盒装（礼盒），产自天津北辰，坏果包赔。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (259, 8, 1, '北辰红颜草莓 3盒装（生态）', '/api/file/placeholder/p259.png', '', 103.80, '3盒装,6盒装', 200, 1823, '天津北辰', '北辰红颜草莓 3盒装（生态），产自天津北辰，当日现摘现发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (260, 8, 1, '北辰红颜草莓 6盒装（生态）', '/api/file/placeholder/p260.png', '', 109.30, '3盒装,6盒装', 300, 1558, '天津北辰', '北辰红颜草莓 6盒装（生态），产自天津北辰，产地直发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (261, 8, 1, '北辰红颜草莓 3盒装（头茬）', '/api/file/placeholder/p261.png', '', 107.10, '3盒装,6盒装', 0, 17, '天津北辰', '北辰红颜草莓 3盒装（头茬），产自天津北辰，当日现摘现发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (262, 8, 1, '北辰红颜草莓 6盒装（头茬）', '/api/file/placeholder/p262.png', '', 88.90, '3盒装,6盒装', 100, 437, '天津北辰', '北辰红颜草莓 6盒装（头茬），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (263, 8, 1, '北辰红颜草莓 3盒装（新货）', '/api/file/placeholder/p263.png', '', 108.90, '3盒装,6盒装', 50, 231, '天津北辰', '北辰红颜草莓 3盒装（新货），产自天津北辰，坏果包赔。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (264, 8, 1, '北辰红颜草莓 6盒装（新货）', '/api/file/placeholder/p264.png', '', 125.80, '3盒装,6盒装', 500, 203, '天津北辰', '北辰红颜草莓 6盒装（新货），产自天津北辰，产地直发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (265, 8, 1, '北辰红颜草莓 3盒装（直供）', '/api/file/placeholder/p265.png', '', 73.50, '3盒装,6盒装', 500, 163, '天津北辰', '北辰红颜草莓 3盒装（直供），产自天津北辰，当日现摘现发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (266, 8, 1, '北辰红颜草莓 6盒装（直供）', '/api/file/placeholder/p266.png', '', 109.60, '3盒装,6盒装', 50, 225, '天津北辰', '北辰红颜草莓 6盒装（直供），产自天津北辰，产地直发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (267, 8, 1, '北辰红颜草莓 3盒装（老树）', '/api/file/placeholder/p267.png', '', 69.60, '3盒装,6盒装', 300, 798, '天津北辰', '北辰红颜草莓 3盒装（老树），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (268, 8, 1, '北辰红颜草莓 6盒装（老树）', '/api/file/placeholder/p268.png', '', 98.20, '3盒装,6盒装', 50, 947, '天津北辰', '北辰红颜草莓 6盒装（老树），产自天津北辰，冷链直达。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (269, 8, 1, '北辰红颜草莓 3盒装（当季）', '/api/file/placeholder/p269.png', '', 50.70, '3盒装,6盒装', 300, 1241, '天津北辰', '北辰红颜草莓 3盒装（当季），产自天津北辰，产地直发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (270, 8, 1, '北辰红颜草莓 6盒装（当季）', '/api/file/placeholder/p270.png', '', 79.00, '3盒装,6盒装', 500, 1707, '天津北辰', '北辰红颜草莓 6盒装（当季），产自天津北辰，当日现摘现发。由北辰果蔬采摘园直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (271, 9, 1, '津南无花果 2斤装（精选）', '/api/file/placeholder/p271.png', '', 28.50, '2斤装,4斤装', 150, 394, '天津津南', '津南无花果 2斤装（精选），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (272, 9, 1, '津南无花果 4斤装（精选）', '/api/file/placeholder/p272.png', '', 46.50, '2斤装,4斤装', 0, 29, '天津津南', '津南无花果 4斤装（精选），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (273, 9, 1, '津南无花果 2斤装（特选）', '/api/file/placeholder/p273.png', '', 32.80, '2斤装,4斤装', 0, 14, '天津津南', '津南无花果 2斤装（特选），产自天津津南，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (274, 9, 1, '津南无花果 4斤装（特选）', '/api/file/placeholder/p274.png', '', 72.40, '2斤装,4斤装', 150, 1906, '天津津南', '津南无花果 4斤装（特选），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (275, 9, 1, '津南无花果 2斤装（家庭装）', '/api/file/placeholder/p275.png', '', 49.20, '2斤装,4斤装', 500, 74, '天津津南', '津南无花果 2斤装（家庭装），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (276, 9, 1, '津南无花果 4斤装（家庭装）', '/api/file/placeholder/p276.png', '', 33.00, '2斤装,4斤装', 30, 422, '天津津南', '津南无花果 4斤装（家庭装），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (277, 9, 1, '津南无花果 2斤装（礼盒）', '/api/file/placeholder/p277.png', '', 40.50, '2斤装,4斤装', 300, 1052, '天津津南', '津南无花果 2斤装（礼盒），产自天津津南，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (278, 9, 1, '津南无花果 4斤装（礼盒）', '/api/file/placeholder/p278.png', '', 46.00, '2斤装,4斤装', 100, 1711, '天津津南', '津南无花果 4斤装（礼盒），产自天津津南，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (279, 9, 1, '津南无花果 2斤装（生态）', '/api/file/placeholder/p279.png', '', 59.70, '2斤装,4斤装', 300, 612, '天津津南', '津南无花果 2斤装（生态），产自天津津南，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (280, 9, 1, '津南无花果 4斤装（生态）', '/api/file/placeholder/p280.png', '', 41.50, '2斤装,4斤装', 50, 322, '天津津南', '津南无花果 4斤装（生态），产自天津津南，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (281, 9, 1, '津南无花果 2斤装（头茬）', '/api/file/placeholder/p281.png', '', 67.50, '2斤装,4斤装', 300, 487, '天津津南', '津南无花果 2斤装（头茬），产自天津津南，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (282, 9, 1, '津南无花果 4斤装（头茬）', '/api/file/placeholder/p282.png', '', 33.50, '2斤装,4斤装', 50, 175, '天津津南', '津南无花果 4斤装（头茬），产自天津津南，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (283, 9, 1, '津南无花果 2斤装（新货）', '/api/file/placeholder/p283.png', '', 31.60, '2斤装,4斤装', 30, 517, '天津津南', '津南无花果 2斤装（新货），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (284, 9, 1, '津南无花果 4斤装（新货）', '/api/file/placeholder/p284.png', '', 76.70, '2斤装,4斤装', 200, 1899, '天津津南', '津南无花果 4斤装（新货），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (285, 9, 1, '津南无花果 2斤装（直供）', '/api/file/placeholder/p285.png', '', 38.90, '2斤装,4斤装', 100, 1637, '天津津南', '津南无花果 2斤装（直供），产自天津津南，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (286, 9, 1, '津南无花果 4斤装（直供）', '/api/file/placeholder/p286.png', '', 68.40, '2斤装,4斤装', 50, 233, '天津津南', '津南无花果 4斤装（直供），产自天津津南，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (287, 9, 1, '津南无花果 2斤装（老树）', '/api/file/placeholder/p287.png', '', 62.60, '2斤装,4斤装', 100, 367, '天津津南', '津南无花果 2斤装（老树），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (288, 9, 1, '津南无花果 4斤装（老树）', '/api/file/placeholder/p288.png', '', 35.60, '2斤装,4斤装', 150, 90, '天津津南', '津南无花果 4斤装（老树），产自天津津南，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (289, 9, 1, '津南无花果 2斤装（当季）', '/api/file/placeholder/p289.png', '', 50.50, '2斤装,4斤装', 500, 1789, '天津津南', '津南无花果 2斤装（当季），产自天津津南，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (290, 9, 1, '津南无花果 4斤装（当季）', '/api/file/placeholder/p290.png', '', 56.60, '2斤装,4斤装', 80, 1538, '天津津南', '津南无花果 4斤装（当季），产自天津津南，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (291, 6, 6, '宝坻大蒜 3头装（精选）', '/api/file/placeholder/p291.png', '', 13.00, '3头装,10头装', 300, 1810, '天津宝坻', '宝坻大蒜 3头装（精选），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (292, 6, 6, '宝坻大蒜 10头装（精选）', '/api/file/placeholder/p292.png', '', 9.80, '3头装,10头装', 0, 4, '天津宝坻', '宝坻大蒜 10头装（精选），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (293, 6, 6, '宝坻大蒜 3头装（特选）', '/api/file/placeholder/p293.png', '', 9.00, '3头装,10头装', 80, 1989, '天津宝坻', '宝坻大蒜 3头装（特选），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (294, 6, 6, '宝坻大蒜 10头装（特选）', '/api/file/placeholder/p294.png', '', 23.70, '3头装,10头装', 15, 76, '天津宝坻', '宝坻大蒜 10头装（特选），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (295, 6, 6, '宝坻大蒜 3头装（家庭装）', '/api/file/placeholder/p295.png', '', 14.50, '3头装,10头装', 80, 693, '天津宝坻', '宝坻大蒜 3头装（家庭装），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (296, 6, 6, '宝坻大蒜 10头装（家庭装）', '/api/file/placeholder/p296.png', '', 11.30, '3头装,10头装', 100, 1779, '天津宝坻', '宝坻大蒜 10头装（家庭装），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (297, 6, 6, '宝坻大蒜 3头装（礼盒）', '/api/file/placeholder/p297.png', '', 11.30, '3头装,10头装', 500, 1473, '天津宝坻', '宝坻大蒜 3头装（礼盒），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (298, 6, 6, '宝坻大蒜 10头装（礼盒）', '/api/file/placeholder/p298.png', '', 14.60, '3头装,10头装', 150, 954, '天津宝坻', '宝坻大蒜 10头装（礼盒），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (299, 6, 6, '宝坻大蒜 3头装（生态）', '/api/file/placeholder/p299.png', '', 22.90, '3头装,10头装', 50, 356, '天津宝坻', '宝坻大蒜 3头装（生态），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (300, 6, 6, '宝坻大蒜 10头装（生态）', '/api/file/placeholder/p300.png', '', 8.70, '3头装,10头装', 50, 1909, '天津宝坻', '宝坻大蒜 10头装（生态），产自天津宝坻，产地直发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (301, 6, 6, '宝坻大蒜 3头装（头茬）', '/api/file/placeholder/p301.png', '', 18.50, '3头装,10头装', 100, 1211, '天津宝坻', '宝坻大蒜 3头装（头茬），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (302, 6, 6, '宝坻大蒜 10头装（头茬）', '/api/file/placeholder/p302.png', '', 13.10, '3头装,10头装', 150, 731, '天津宝坻', '宝坻大蒜 10头装（头茬），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (303, 6, 6, '宝坻大蒜 3头装（新货）', '/api/file/placeholder/p303.png', '', 9.80, '3头装,10头装', 500, 1716, '天津宝坻', '宝坻大蒜 3头装（新货），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (304, 6, 6, '宝坻大蒜 10头装（新货）', '/api/file/placeholder/p304.png', '', 26.50, '3头装,10头装', 80, 1158, '天津宝坻', '宝坻大蒜 10头装（新货），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (305, 6, 6, '宝坻大蒜 3头装（直供）', '/api/file/placeholder/p305.png', '', 10.30, '3头装,10头装', 200, 986, '天津宝坻', '宝坻大蒜 3头装（直供），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (306, 6, 6, '宝坻大蒜 10头装（直供）', '/api/file/placeholder/p306.png', '', 24.50, '3头装,10头装', 50, 1884, '天津宝坻', '宝坻大蒜 10头装（直供），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (307, 6, 6, '宝坻大蒜 3头装（老树）', '/api/file/placeholder/p307.png', '', 10.90, '3头装,10头装', 50, 1008, '天津宝坻', '宝坻大蒜 3头装（老树），产自天津宝坻，当日现摘现发。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (308, 6, 6, '宝坻大蒜 10头装（老树）', '/api/file/placeholder/p308.png', '', 15.70, '3头装,10头装', 30, 777, '天津宝坻', '宝坻大蒜 10头装（老树），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (309, 6, 6, '宝坻大蒜 3头装（当季）', '/api/file/placeholder/p309.png', '', 12.70, '3头装,10头装', 80, 1411, '天津宝坻', '宝坻大蒜 3头装（当季），产自天津宝坻，冷链直达。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (310, 6, 6, '宝坻大蒜 10头装（当季）', '/api/file/placeholder/p310.png', '', 12.90, '3头装,10头装', 100, 100, '天津宝坻', '宝坻大蒜 10头装（当季），产自天津宝坻，坏果包赔。由宝坻小站稻米业公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (311, 7, 2, '武清鲜食玉米 8根装（精选）', '/api/file/placeholder/p311.png', '', 31.30, '8根装,16根装', 500, 1421, '天津武清', '武清鲜食玉米 8根装（精选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (312, 7, 2, '武清鲜食玉米 16根装（精选）', '/api/file/placeholder/p312.png', '', 34.50, '8根装,16根装', 150, 580, '天津武清', '武清鲜食玉米 16根装（精选），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (313, 7, 2, '武清鲜食玉米 8根装（特选）', '/api/file/placeholder/p313.png', '', 29.90, '8根装,16根装', 50, 1720, '天津武清', '武清鲜食玉米 8根装（特选），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (314, 7, 2, '武清鲜食玉米 16根装（特选）', '/api/file/placeholder/p314.png', '', 46.40, '8根装,16根装', 300, 738, '天津武清', '武清鲜食玉米 16根装（特选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (315, 7, 2, '武清鲜食玉米 8根装（家庭装）', '/api/file/placeholder/p315.png', '', 35.80, '8根装,16根装', 150, 870, '天津武清', '武清鲜食玉米 8根装（家庭装），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (316, 7, 2, '武清鲜食玉米 16根装（家庭装）', '/api/file/placeholder/p316.png', '', 35.00, '8根装,16根装', 100, 27, '天津武清', '武清鲜食玉米 16根装（家庭装），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (317, 7, 2, '武清鲜食玉米 8根装（礼盒）', '/api/file/placeholder/p317.png', '', 24.40, '8根装,16根装', 0, 8, '天津武清', '武清鲜食玉米 8根装（礼盒），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (318, 7, 2, '武清鲜食玉米 16根装（礼盒）', '/api/file/placeholder/p318.png', '', 20.10, '8根装,16根装', 500, 1215, '天津武清', '武清鲜食玉米 16根装（礼盒），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (319, 7, 2, '武清鲜食玉米 8根装（生态）', '/api/file/placeholder/p319.png', '', 41.20, '8根装,16根装', 15, 1987, '天津武清', '武清鲜食玉米 8根装（生态），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (320, 7, 2, '武清鲜食玉米 16根装（生态）', '/api/file/placeholder/p320.png', '', 25.50, '8根装,16根装', 0, 6, '天津武清', '武清鲜食玉米 16根装（生态），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (321, 7, 2, '武清鲜食玉米 8根装（头茬）', '/api/file/placeholder/p321.png', '', 31.00, '8根装,16根装', 80, 1769, '天津武清', '武清鲜食玉米 8根装（头茬），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (322, 7, 2, '武清鲜食玉米 16根装（头茬）', '/api/file/placeholder/p322.png', '', 34.80, '8根装,16根装', 100, 355, '天津武清', '武清鲜食玉米 16根装（头茬），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (323, 7, 2, '武清鲜食玉米 8根装（新货）', '/api/file/placeholder/p323.png', '', 24.00, '8根装,16根装', 500, 77, '天津武清', '武清鲜食玉米 8根装（新货），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (324, 7, 2, '武清鲜食玉米 16根装（新货）', '/api/file/placeholder/p324.png', '', 21.00, '8根装,16根装', 100, 1878, '天津武清', '武清鲜食玉米 16根装（新货），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (325, 7, 2, '武清鲜食玉米 8根装（直供）', '/api/file/placeholder/p325.png', '', 43.70, '8根装,16根装', 150, 543, '天津武清', '武清鲜食玉米 8根装（直供），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (326, 7, 2, '武清鲜食玉米 16根装（直供）', '/api/file/placeholder/p326.png', '', 54.50, '8根装,16根装', 300, 710, '天津武清', '武清鲜食玉米 16根装（直供），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (327, 7, 2, '武清鲜食玉米 8根装（老树）', '/api/file/placeholder/p327.png', '', 26.20, '8根装,16根装', 0, 28, '天津武清', '武清鲜食玉米 8根装（老树），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (328, 7, 2, '武清鲜食玉米 16根装（老树）', '/api/file/placeholder/p328.png', '', 41.20, '8根装,16根装', 100, 1898, '天津武清', '武清鲜食玉米 16根装（老树），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (329, 7, 2, '武清鲜食玉米 8根装（当季）', '/api/file/placeholder/p329.png', '', 54.50, '8根装,16根装', 100, 1282, '天津武清', '武清鲜食玉米 8根装（当季），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (330, 7, 2, '武清鲜食玉米 16根装（当季）', '/api/file/placeholder/p330.png', '', 36.00, '8根装,16根装', 50, 177, '天津武清', '武清鲜食玉米 16根装（当季），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (331, 1, 1, '蓟州山里红山楂 2斤装（精选）', '/api/file/placeholder/p331.png', '', 20.70, '2斤装,5斤装', 500, 1786, '天津蓟州', '蓟州山里红山楂 2斤装（精选），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (332, 1, 1, '蓟州山里红山楂 5斤装（精选）', '/api/file/placeholder/p332.png', '', 12.30, '2斤装,5斤装', 500, 1959, '天津蓟州', '蓟州山里红山楂 5斤装（精选），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (333, 1, 1, '蓟州山里红山楂 2斤装（特选）', '/api/file/placeholder/p333.png', '', 38.80, '2斤装,5斤装', 150, 1252, '天津蓟州', '蓟州山里红山楂 2斤装（特选），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (334, 1, 1, '蓟州山里红山楂 5斤装（特选）', '/api/file/placeholder/p334.png', '', 19.50, '2斤装,5斤装', 100, 827, '天津蓟州', '蓟州山里红山楂 5斤装（特选），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (335, 1, 1, '蓟州山里红山楂 2斤装（家庭装）', '/api/file/placeholder/p335.png', '', 37.60, '2斤装,5斤装', 150, 949, '天津蓟州', '蓟州山里红山楂 2斤装（家庭装），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (336, 1, 1, '蓟州山里红山楂 5斤装（家庭装）', '/api/file/placeholder/p336.png', '', 31.40, '2斤装,5斤装', 500, 1469, '天津蓟州', '蓟州山里红山楂 5斤装（家庭装），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (337, 1, 1, '蓟州山里红山楂 2斤装（礼盒）', '/api/file/placeholder/p337.png', '', 37.10, '2斤装,5斤装', 80, 1813, '天津蓟州', '蓟州山里红山楂 2斤装（礼盒），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (338, 1, 1, '蓟州山里红山楂 5斤装（礼盒）', '/api/file/placeholder/p338.png', '', 29.90, '2斤装,5斤装', 500, 370, '天津蓟州', '蓟州山里红山楂 5斤装（礼盒），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (339, 1, 1, '蓟州山里红山楂 2斤装（生态）', '/api/file/placeholder/p339.png', '', 18.70, '2斤装,5斤装', 30, 1666, '天津蓟州', '蓟州山里红山楂 2斤装（生态），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (340, 1, 1, '蓟州山里红山楂 5斤装（生态）', '/api/file/placeholder/p340.png', '', 31.50, '2斤装,5斤装', 500, 1802, '天津蓟州', '蓟州山里红山楂 5斤装（生态），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (341, 1, 1, '蓟州山里红山楂 2斤装（头茬）', '/api/file/placeholder/p341.png', '', 18.10, '2斤装,5斤装', 50, 1394, '天津蓟州', '蓟州山里红山楂 2斤装（头茬），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (342, 1, 1, '蓟州山里红山楂 5斤装（头茬）', '/api/file/placeholder/p342.png', '', 27.90, '2斤装,5斤装', 500, 1756, '天津蓟州', '蓟州山里红山楂 5斤装（头茬），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (343, 1, 1, '蓟州山里红山楂 2斤装（新货）', '/api/file/placeholder/p343.png', '', 27.40, '2斤装,5斤装', 200, 259, '天津蓟州', '蓟州山里红山楂 2斤装（新货），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (344, 1, 1, '蓟州山里红山楂 5斤装（新货）', '/api/file/placeholder/p344.png', '', 21.30, '2斤装,5斤装', 500, 1083, '天津蓟州', '蓟州山里红山楂 5斤装（新货），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (345, 1, 1, '蓟州山里红山楂 2斤装（直供）', '/api/file/placeholder/p345.png', '', 17.60, '2斤装,5斤装', 30, 1421, '天津蓟州', '蓟州山里红山楂 2斤装（直供），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (346, 1, 1, '蓟州山里红山楂 5斤装（直供）', '/api/file/placeholder/p346.png', '', 22.80, '2斤装,5斤装', 50, 1857, '天津蓟州', '蓟州山里红山楂 5斤装（直供），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (347, 1, 1, '蓟州山里红山楂 2斤装（老树）', '/api/file/placeholder/p347.png', '', 30.80, '2斤装,5斤装', 100, 772, '天津蓟州', '蓟州山里红山楂 2斤装（老树），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (348, 1, 1, '蓟州山里红山楂 5斤装（老树）', '/api/file/placeholder/p348.png', '', 32.60, '2斤装,5斤装', 300, 1741, '天津蓟州', '蓟州山里红山楂 5斤装（老树），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (349, 1, 1, '蓟州山里红山楂 2斤装（当季）', '/api/file/placeholder/p349.png', '', 29.20, '2斤装,5斤装', 500, 483, '天津蓟州', '蓟州山里红山楂 2斤装（当季），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (350, 1, 1, '蓟州山里红山楂 5斤装（当季）', '/api/file/placeholder/p350.png', '', 15.00, '2斤装,5斤装', 0, 5, '天津蓟州', '蓟州山里红山楂 5斤装（当季），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (351, 4, 1, '静海冬枣 2斤装（精选）', '/api/file/placeholder/p351.png', '', 29.30, '2斤装,4斤装', 200, 1406, '天津静海', '静海冬枣 2斤装（精选），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (352, 4, 1, '静海冬枣 4斤装（精选）', '/api/file/placeholder/p352.png', '', 19.90, '2斤装,4斤装', 15, 954, '天津静海', '静海冬枣 4斤装（精选），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (353, 4, 1, '静海冬枣 2斤装（特选）', '/api/file/placeholder/p353.png', '', 35.00, '2斤装,4斤装', 500, 802, '天津静海', '静海冬枣 2斤装（特选），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (354, 4, 1, '静海冬枣 4斤装（特选）', '/api/file/placeholder/p354.png', '', 48.00, '2斤装,4斤装', 80, 1612, '天津静海', '静海冬枣 4斤装（特选），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (355, 4, 1, '静海冬枣 2斤装（家庭装）', '/api/file/placeholder/p355.png', '', 48.90, '2斤装,4斤装', 200, 753, '天津静海', '静海冬枣 2斤装（家庭装），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (356, 4, 1, '静海冬枣 4斤装（家庭装）', '/api/file/placeholder/p356.png', '', 39.50, '2斤装,4斤装', 15, 1493, '天津静海', '静海冬枣 4斤装（家庭装），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (357, 4, 1, '静海冬枣 2斤装（礼盒）', '/api/file/placeholder/p357.png', '', 51.90, '2斤装,4斤装', 200, 1079, '天津静海', '静海冬枣 2斤装（礼盒），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (358, 4, 1, '静海冬枣 4斤装（礼盒）', '/api/file/placeholder/p358.png', '', 33.90, '2斤装,4斤装', 50, 1860, '天津静海', '静海冬枣 4斤装（礼盒），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (359, 4, 1, '静海冬枣 2斤装（生态）', '/api/file/placeholder/p359.png', '', 26.90, '2斤装,4斤装', 15, 826, '天津静海', '静海冬枣 2斤装（生态），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (360, 4, 1, '静海冬枣 4斤装（生态）', '/api/file/placeholder/p360.png', '', 18.10, '2斤装,4斤装', 300, 900, '天津静海', '静海冬枣 4斤装（生态），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (361, 4, 1, '静海冬枣 2斤装（头茬）', '/api/file/placeholder/p361.png', '', 20.10, '2斤装,4斤装', 0, 4, '天津静海', '静海冬枣 2斤装（头茬），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (362, 4, 1, '静海冬枣 4斤装（头茬）', '/api/file/placeholder/p362.png', '', 34.00, '2斤装,4斤装', 150, 1547, '天津静海', '静海冬枣 4斤装（头茬），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (363, 4, 1, '静海冬枣 2斤装（新货）', '/api/file/placeholder/p363.png', '', 50.50, '2斤装,4斤装', 0, 17, '天津静海', '静海冬枣 2斤装（新货），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (364, 4, 1, '静海冬枣 4斤装（新货）', '/api/file/placeholder/p364.png', '', 23.30, '2斤装,4斤装', 30, 345, '天津静海', '静海冬枣 4斤装（新货），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (365, 4, 1, '静海冬枣 2斤装（直供）', '/api/file/placeholder/p365.png', '', 27.50, '2斤装,4斤装', 80, 1028, '天津静海', '静海冬枣 2斤装（直供），产自天津静海，冷链直达。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (366, 4, 1, '静海冬枣 4斤装（直供）', '/api/file/placeholder/p366.png', '', 34.90, '2斤装,4斤装', 30, 350, '天津静海', '静海冬枣 4斤装（直供），产自天津静海，当日现摘现发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (367, 4, 1, '静海冬枣 2斤装（老树）', '/api/file/placeholder/p367.png', '', 42.50, '2斤装,4斤装', 200, 1735, '天津静海', '静海冬枣 2斤装（老树），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (368, 4, 1, '静海冬枣 4斤装（老树）', '/api/file/placeholder/p368.png', '', 16.80, '2斤装,4斤装', 100, 687, '天津静海', '静海冬枣 4斤装（老树），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (369, 4, 1, '静海冬枣 2斤装（当季）', '/api/file/placeholder/p369.png', '', 26.10, '2斤装,4斤装', 300, 1557, '天津静海', '静海冬枣 2斤装（当季），产自天津静海，产地直发。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (370, 4, 1, '静海冬枣 4斤装（当季）', '/api/file/placeholder/p370.png', '', 38.80, '2斤装,4斤装', 150, 187, '天津静海', '静海冬枣 4斤装（当季），产自天津静海，坏果包赔。由静海金丝小枣家庭农场直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (371, 7, 2, '武清西兰花 2颗装（精选）', '/api/file/placeholder/p371.png', '', 13.30, '2颗装,4颗装', 0, 8, '天津武清', '武清西兰花 2颗装（精选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (372, 7, 2, '武清西兰花 4颗装（精选）', '/api/file/placeholder/p372.png', '', 20.90, '2颗装,4颗装', 30, 1355, '天津武清', '武清西兰花 4颗装（精选），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (373, 7, 2, '武清西兰花 2颗装（特选）', '/api/file/placeholder/p373.png', '', 14.10, '2颗装,4颗装', 50, 258, '天津武清', '武清西兰花 2颗装（特选），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (374, 7, 2, '武清西兰花 4颗装（特选）', '/api/file/placeholder/p374.png', '', 10.30, '2颗装,4颗装', 150, 1695, '天津武清', '武清西兰花 4颗装（特选），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (375, 7, 2, '武清西兰花 2颗装（家庭装）', '/api/file/placeholder/p375.png', '', 17.80, '2颗装,4颗装', 300, 895, '天津武清', '武清西兰花 2颗装（家庭装），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (376, 7, 2, '武清西兰花 4颗装（家庭装）', '/api/file/placeholder/p376.png', '', 12.60, '2颗装,4颗装', 15, 380, '天津武清', '武清西兰花 4颗装（家庭装），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (377, 7, 2, '武清西兰花 2颗装（礼盒）', '/api/file/placeholder/p377.png', '', 19.30, '2颗装,4颗装', 300, 912, '天津武清', '武清西兰花 2颗装（礼盒），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (378, 7, 2, '武清西兰花 4颗装（礼盒）', '/api/file/placeholder/p378.png', '', 23.80, '2颗装,4颗装', 80, 1887, '天津武清', '武清西兰花 4颗装（礼盒），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (379, 7, 2, '武清西兰花 2颗装（生态）', '/api/file/placeholder/p379.png', '', 15.00, '2颗装,4颗装', 80, 71, '天津武清', '武清西兰花 2颗装（生态），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (380, 7, 2, '武清西兰花 4颗装（生态）', '/api/file/placeholder/p380.png', '', 22.40, '2颗装,4颗装', 50, 1349, '天津武清', '武清西兰花 4颗装（生态），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (381, 7, 2, '武清西兰花 2颗装（头茬）', '/api/file/placeholder/p381.png', '', 17.40, '2颗装,4颗装', 300, 581, '天津武清', '武清西兰花 2颗装（头茬），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (382, 7, 2, '武清西兰花 4颗装（头茬）', '/api/file/placeholder/p382.png', '', 15.50, '2颗装,4颗装', 100, 401, '天津武清', '武清西兰花 4颗装（头茬），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (383, 7, 2, '武清西兰花 2颗装（新货）', '/api/file/placeholder/p383.png', '', 20.40, '2颗装,4颗装', 15, 1463, '天津武清', '武清西兰花 2颗装（新货），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (384, 7, 2, '武清西兰花 4颗装（新货）', '/api/file/placeholder/p384.png', '', 11.10, '2颗装,4颗装', 300, 394, '天津武清', '武清西兰花 4颗装（新货），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (385, 7, 2, '武清西兰花 2颗装（直供）', '/api/file/placeholder/p385.png', '', 22.00, '2颗装,4颗装', 150, 1975, '天津武清', '武清西兰花 2颗装（直供），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (386, 7, 2, '武清西兰花 4颗装（直供）', '/api/file/placeholder/p386.png', '', 18.10, '2颗装,4颗装', 150, 935, '天津武清', '武清西兰花 4颗装（直供），产自天津武清，坏果包赔。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (387, 7, 2, '武清西兰花 2颗装（老树）', '/api/file/placeholder/p387.png', '', 14.60, '2颗装,4颗装', 0, 3, '天津武清', '武清西兰花 2颗装（老树），产自天津武清，冷链直达。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (388, 7, 2, '武清西兰花 4颗装（老树）', '/api/file/placeholder/p388.png', '', 22.40, '2颗装,4颗装', 100, 1330, '天津武清', '武清西兰花 4颗装（老树），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (389, 7, 2, '武清西兰花 2颗装（当季）', '/api/file/placeholder/p389.png', '', 10.90, '2颗装,4颗装', 150, 293, '天津武清', '武清西兰花 2颗装（当季），产自天津武清，产地直发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (390, 7, 2, '武清西兰花 4颗装（当季）', '/api/file/placeholder/p390.png', '', 10.40, '2颗装,4颗装', 200, 1705, '天津武清', '武清西兰花 4颗装（当季），产自天津武清，当日现摘现发。由武清有机蔬菜农场联盟直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (391, 3, 1, '汉沽桃子 3斤装（精选）', '/api/file/placeholder/p391.png', '', 41.30, '3斤装,6斤装', 200, 285, '天津汉沽', '汉沽桃子 3斤装（精选），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (392, 3, 1, '汉沽桃子 6斤装（精选）', '/api/file/placeholder/p392.png', '', 53.70, '3斤装,6斤装', 150, 1494, '天津汉沽', '汉沽桃子 6斤装（精选），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (393, 3, 1, '汉沽桃子 3斤装（特选）', '/api/file/placeholder/p393.png', '', 28.10, '3斤装,6斤装', 150, 1287, '天津汉沽', '汉沽桃子 3斤装（特选），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (394, 3, 1, '汉沽桃子 6斤装（特选）', '/api/file/placeholder/p394.png', '', 57.20, '3斤装,6斤装', 300, 437, '天津汉沽', '汉沽桃子 6斤装（特选），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (395, 3, 1, '汉沽桃子 3斤装（家庭装）', '/api/file/placeholder/p395.png', '', 45.60, '3斤装,6斤装', 50, 1707, '天津汉沽', '汉沽桃子 3斤装（家庭装），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (396, 3, 1, '汉沽桃子 6斤装（家庭装）', '/api/file/placeholder/p396.png', '', 20.90, '3斤装,6斤装', 300, 1273, '天津汉沽', '汉沽桃子 6斤装（家庭装），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (397, 3, 1, '汉沽桃子 3斤装（礼盒）', '/api/file/placeholder/p397.png', '', 54.70, '3斤装,6斤装', 15, 1095, '天津汉沽', '汉沽桃子 3斤装（礼盒），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (398, 3, 1, '汉沽桃子 6斤装（礼盒）', '/api/file/placeholder/p398.png', '', 44.20, '3斤装,6斤装', 30, 1427, '天津汉沽', '汉沽桃子 6斤装（礼盒），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (399, 3, 1, '汉沽桃子 3斤装（生态）', '/api/file/placeholder/p399.png', '', 20.30, '3斤装,6斤装', 300, 1709, '天津汉沽', '汉沽桃子 3斤装（生态），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (400, 3, 1, '汉沽桃子 6斤装（生态）', '/api/file/placeholder/p400.png', '', 32.70, '3斤装,6斤装', 100, 1616, '天津汉沽', '汉沽桃子 6斤装（生态），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (401, 3, 1, '汉沽桃子 3斤装（头茬）', '/api/file/placeholder/p401.png', '', 24.80, '3斤装,6斤装', 500, 1300, '天津汉沽', '汉沽桃子 3斤装（头茬），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (402, 3, 1, '汉沽桃子 6斤装（头茬）', '/api/file/placeholder/p402.png', '', 32.10, '3斤装,6斤装', 200, 394, '天津汉沽', '汉沽桃子 6斤装（头茬），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (403, 3, 1, '汉沽桃子 3斤装（新货）', '/api/file/placeholder/p403.png', '', 47.40, '3斤装,6斤装', 15, 1657, '天津汉沽', '汉沽桃子 3斤装（新货），产自天津汉沽，当日现摘现发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (404, 3, 1, '汉沽桃子 6斤装（新货）', '/api/file/placeholder/p404.png', '', 30.30, '3斤装,6斤装', 500, 980, '天津汉沽', '汉沽桃子 6斤装（新货），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (405, 3, 1, '汉沽桃子 3斤装（直供）', '/api/file/placeholder/p405.png', '', 21.80, '3斤装,6斤装', 100, 357, '天津汉沽', '汉沽桃子 3斤装（直供），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (406, 3, 1, '汉沽桃子 6斤装（直供）', '/api/file/placeholder/p406.png', '', 34.10, '3斤装,6斤装', 30, 344, '天津汉沽', '汉沽桃子 6斤装（直供），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (407, 3, 1, '汉沽桃子 3斤装（老树）', '/api/file/placeholder/p407.png', '', 28.00, '3斤装,6斤装', 80, 1766, '天津汉沽', '汉沽桃子 3斤装（老树），产自天津汉沽，产地直发。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (408, 3, 1, '汉沽桃子 6斤装（老树）', '/api/file/placeholder/p408.png', '', 26.50, '3斤装,6斤装', 150, 419, '天津汉沽', '汉沽桃子 6斤装（老树），产自天津汉沽，坏果包赔。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (409, 3, 1, '汉沽桃子 3斤装（当季）', '/api/file/placeholder/p409.png', '', 26.00, '3斤装,6斤装', 100, 380, '天津汉沽', '汉沽桃子 3斤装（当季），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (410, 3, 1, '汉沽桃子 6斤装（当季）', '/api/file/placeholder/p410.png', '', 53.70, '3斤装,6斤装', 15, 374, '天津汉沽', '汉沽桃子 6斤装（当季），产自天津汉沽，冷链直达。由汉沽茶淀葡萄合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (411, 5, 3, '小站稻蟹田米 5斤装（精选）', '/api/file/placeholder/p411.png', '', 123.10, '5斤装,10斤装', 100, 600, '天津宁河', '小站稻蟹田米 5斤装（精选），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (412, 5, 3, '小站稻蟹田米 10斤装（精选）', '/api/file/placeholder/p412.png', '', 60.60, '5斤装,10斤装', 100, 1195, '天津宁河', '小站稻蟹田米 10斤装（精选），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (413, 5, 3, '小站稻蟹田米 5斤装（特选）', '/api/file/placeholder/p413.png', '', 68.90, '5斤装,10斤装', 30, 351, '天津宁河', '小站稻蟹田米 5斤装（特选），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (414, 5, 3, '小站稻蟹田米 10斤装（特选）', '/api/file/placeholder/p414.png', '', 72.70, '5斤装,10斤装', 500, 1456, '天津宁河', '小站稻蟹田米 10斤装（特选），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (415, 5, 3, '小站稻蟹田米 5斤装（家庭装）', '/api/file/placeholder/p415.png', '', 104.90, '5斤装,10斤装', 0, 9, '天津宁河', '小站稻蟹田米 5斤装（家庭装），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (416, 5, 3, '小站稻蟹田米 10斤装（家庭装）', '/api/file/placeholder/p416.png', '', 68.60, '5斤装,10斤装', 0, 15, '天津宁河', '小站稻蟹田米 10斤装（家庭装），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (417, 5, 3, '小站稻蟹田米 5斤装（礼盒）', '/api/file/placeholder/p417.png', '', 81.40, '5斤装,10斤装', 0, 24, '天津宁河', '小站稻蟹田米 5斤装（礼盒），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (418, 5, 3, '小站稻蟹田米 10斤装（礼盒）', '/api/file/placeholder/p418.png', '', 98.30, '5斤装,10斤装', 80, 1429, '天津宁河', '小站稻蟹田米 10斤装（礼盒），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (419, 5, 3, '小站稻蟹田米 5斤装（生态）', '/api/file/placeholder/p419.png', '', 130.20, '5斤装,10斤装', 50, 1037, '天津宁河', '小站稻蟹田米 5斤装（生态），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (420, 5, 3, '小站稻蟹田米 10斤装（生态）', '/api/file/placeholder/p420.png', '', 121.90, '5斤装,10斤装', 80, 103, '天津宁河', '小站稻蟹田米 10斤装（生态），产自天津宁河，当日现摘现发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (421, 5, 3, '小站稻蟹田米 5斤装（头茬）', '/api/file/placeholder/p421.png', '', 103.20, '5斤装,10斤装', 30, 1737, '天津宁河', '小站稻蟹田米 5斤装（头茬），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (422, 5, 3, '小站稻蟹田米 10斤装（头茬）', '/api/file/placeholder/p422.png', '', 126.00, '5斤装,10斤装', 150, 1403, '天津宁河', '小站稻蟹田米 10斤装（头茬），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (423, 5, 3, '小站稻蟹田米 5斤装（新货）', '/api/file/placeholder/p423.png', '', 97.80, '5斤装,10斤装', 50, 1633, '天津宁河', '小站稻蟹田米 5斤装（新货），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (424, 5, 3, '小站稻蟹田米 10斤装（新货）', '/api/file/placeholder/p424.png', '', 50.00, '5斤装,10斤装', 15, 140, '天津宁河', '小站稻蟹田米 10斤装（新货），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (425, 5, 3, '小站稻蟹田米 5斤装（直供）', '/api/file/placeholder/p425.png', '', 103.60, '5斤装,10斤装', 80, 1133, '天津宁河', '小站稻蟹田米 5斤装（直供），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (426, 5, 3, '小站稻蟹田米 10斤装（直供）', '/api/file/placeholder/p426.png', '', 72.80, '5斤装,10斤装', 50, 1630, '天津宁河', '小站稻蟹田米 10斤装（直供），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (427, 5, 3, '小站稻蟹田米 5斤装（老树）', '/api/file/placeholder/p427.png', '', 105.00, '5斤装,10斤装', 100, 791, '天津宁河', '小站稻蟹田米 5斤装（老树），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (428, 5, 3, '小站稻蟹田米 10斤装（老树）', '/api/file/placeholder/p428.png', '', 63.10, '5斤装,10斤装', 30, 1544, '天津宁河', '小站稻蟹田米 10斤装（老树），产自天津宁河，冷链直达。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (429, 5, 3, '小站稻蟹田米 5斤装（当季）', '/api/file/placeholder/p429.png', '', 56.40, '5斤装,10斤装', 0, 18, '天津宁河', '小站稻蟹田米 5斤装（当季），产自天津宁河，坏果包赔。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (430, 5, 3, '小站稻蟹田米 10斤装（当季）', '/api/file/placeholder/p430.png', '', 68.80, '5斤装,10斤装', 200, 65, '天津宁河', '小站稻蟹田米 10斤装（当季），产自天津宁河，产地直发。由宁河七里海河蟹养殖基地直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (431, 1, 1, '蓟州京白桃 3斤装（精选）', '/api/file/placeholder/p431.png', '', 58.70, '3斤装,5斤装', 30, 286, '天津蓟州', '蓟州京白桃 3斤装（精选），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (432, 1, 1, '蓟州京白桃 5斤装（精选）', '/api/file/placeholder/p432.png', '', 50.60, '3斤装,5斤装', 80, 194, '天津蓟州', '蓟州京白桃 5斤装（精选），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (433, 1, 1, '蓟州京白桃 3斤装（特选）', '/api/file/placeholder/p433.png', '', 55.80, '3斤装,5斤装', 80, 1995, '天津蓟州', '蓟州京白桃 3斤装（特选），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (434, 1, 1, '蓟州京白桃 5斤装（特选）', '/api/file/placeholder/p434.png', '', 63.40, '3斤装,5斤装', 100, 1499, '天津蓟州', '蓟州京白桃 5斤装（特选），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (435, 1, 1, '蓟州京白桃 3斤装（家庭装）', '/api/file/placeholder/p435.png', '', 53.90, '3斤装,5斤装', 100, 1848, '天津蓟州', '蓟州京白桃 3斤装（家庭装），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (436, 1, 1, '蓟州京白桃 5斤装（家庭装）', '/api/file/placeholder/p436.png', '', 58.60, '3斤装,5斤装', 150, 1496, '天津蓟州', '蓟州京白桃 5斤装（家庭装），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (437, 1, 1, '蓟州京白桃 3斤装（礼盒）', '/api/file/placeholder/p437.png', '', 28.60, '3斤装,5斤装', 50, 1841, '天津蓟州', '蓟州京白桃 3斤装（礼盒），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (438, 1, 1, '蓟州京白桃 5斤装（礼盒）', '/api/file/placeholder/p438.png', '', 41.90, '3斤装,5斤装', 100, 1426, '天津蓟州', '蓟州京白桃 5斤装（礼盒），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (439, 1, 1, '蓟州京白桃 3斤装（生态）', '/api/file/placeholder/p439.png', '', 47.00, '3斤装,5斤装', 200, 588, '天津蓟州', '蓟州京白桃 3斤装（生态），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (440, 1, 1, '蓟州京白桃 5斤装（生态）', '/api/file/placeholder/p440.png', '', 45.20, '3斤装,5斤装', 150, 974, '天津蓟州', '蓟州京白桃 5斤装（生态），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (441, 1, 1, '蓟州京白桃 3斤装（头茬）', '/api/file/placeholder/p441.png', '', 23.90, '3斤装,5斤装', 500, 1264, '天津蓟州', '蓟州京白桃 3斤装（头茬），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (442, 1, 1, '蓟州京白桃 5斤装（头茬）', '/api/file/placeholder/p442.png', '', 28.10, '3斤装,5斤装', 100, 236, '天津蓟州', '蓟州京白桃 5斤装（头茬），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (443, 1, 1, '蓟州京白桃 3斤装（新货）', '/api/file/placeholder/p443.png', '', 60.20, '3斤装,5斤装', 30, 667, '天津蓟州', '蓟州京白桃 3斤装（新货），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (444, 1, 1, '蓟州京白桃 5斤装（新货）', '/api/file/placeholder/p444.png', '', 32.50, '3斤装,5斤装', 300, 401, '天津蓟州', '蓟州京白桃 5斤装（新货），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (445, 1, 1, '蓟州京白桃 3斤装（直供）', '/api/file/placeholder/p445.png', '', 32.80, '3斤装,5斤装', 300, 983, '天津蓟州', '蓟州京白桃 3斤装（直供），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (446, 1, 1, '蓟州京白桃 5斤装（直供）', '/api/file/placeholder/p446.png', '', 62.70, '3斤装,5斤装', 80, 914, '天津蓟州', '蓟州京白桃 5斤装（直供），产自天津蓟州，坏果包赔。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (447, 1, 1, '蓟州京白桃 3斤装（老树）', '/api/file/placeholder/p447.png', '', 39.10, '3斤装,5斤装', 50, 942, '天津蓟州', '蓟州京白桃 3斤装（老树），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (448, 1, 1, '蓟州京白桃 5斤装（老树）', '/api/file/placeholder/p448.png', '', 44.90, '3斤装,5斤装', 500, 231, '天津蓟州', '蓟州京白桃 5斤装（老树），产自天津蓟州，产地直发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (449, 1, 1, '蓟州京白桃 3斤装（当季）', '/api/file/placeholder/p449.png', '', 57.50, '3斤装,5斤装', 150, 110, '天津蓟州', '蓟州京白桃 3斤装（当季），产自天津蓟州，冷链直达。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (450, 1, 1, '蓟州京白桃 5斤装（当季）', '/api/file/placeholder/p450.png', '', 63.70, '3斤装,5斤装', 200, 1155, '天津蓟州', '蓟州京白桃 5斤装（当季），产自天津蓟州，当日现摘现发。由蓟州盘山果业有限公司直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (451, 9, 5, '滨海新区虾干 半斤装（精选）', '/api/file/placeholder/p451.png', '', 77.90, '半斤装,1斤装', 300, 438, '天津滨海', '滨海新区虾干 半斤装（精选），产自天津滨海，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (452, 9, 5, '滨海新区虾干 1斤装（精选）', '/api/file/placeholder/p452.png', '', 64.90, '半斤装,1斤装', 30, 240, '天津滨海', '滨海新区虾干 1斤装（精选），产自天津滨海，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (453, 9, 5, '滨海新区虾干 半斤装（特选）', '/api/file/placeholder/p453.png', '', 54.00, '半斤装,1斤装', 30, 1553, '天津滨海', '滨海新区虾干 半斤装（特选），产自天津滨海，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (454, 9, 5, '滨海新区虾干 1斤装（特选）', '/api/file/placeholder/p454.png', '', 64.00, '半斤装,1斤装', 500, 1830, '天津滨海', '滨海新区虾干 1斤装（特选），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (455, 9, 5, '滨海新区虾干 半斤装（家庭装）', '/api/file/placeholder/p455.png', '', 56.20, '半斤装,1斤装', 500, 1402, '天津滨海', '滨海新区虾干 半斤装（家庭装），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (456, 9, 5, '滨海新区虾干 1斤装（家庭装）', '/api/file/placeholder/p456.png', '', 41.70, '半斤装,1斤装', 50, 1360, '天津滨海', '滨海新区虾干 1斤装（家庭装），产自天津滨海，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (457, 9, 5, '滨海新区虾干 半斤装（礼盒）', '/api/file/placeholder/p457.png', '', 83.00, '半斤装,1斤装', 500, 1805, '天津滨海', '滨海新区虾干 半斤装（礼盒），产自天津滨海，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (458, 9, 5, '滨海新区虾干 1斤装（礼盒）', '/api/file/placeholder/p458.png', '', 60.20, '半斤装,1斤装', 15, 1037, '天津滨海', '滨海新区虾干 1斤装（礼盒），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (459, 9, 5, '滨海新区虾干 半斤装（生态）', '/api/file/placeholder/p459.png', '', 78.80, '半斤装,1斤装', 200, 449, '天津滨海', '滨海新区虾干 半斤装（生态），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (460, 9, 5, '滨海新区虾干 1斤装（生态）', '/api/file/placeholder/p460.png', '', 72.70, '半斤装,1斤装', 150, 515, '天津滨海', '滨海新区虾干 1斤装（生态），产自天津滨海，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (461, 9, 5, '滨海新区虾干 半斤装（头茬）', '/api/file/placeholder/p461.png', '', 58.40, '半斤装,1斤装', 300, 1895, '天津滨海', '滨海新区虾干 半斤装（头茬），产自天津滨海，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (462, 9, 5, '滨海新区虾干 1斤装（头茬）', '/api/file/placeholder/p462.png', '', 45.20, '半斤装,1斤装', 80, 84, '天津滨海', '滨海新区虾干 1斤装（头茬），产自天津滨海，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (463, 9, 5, '滨海新区虾干 半斤装（新货）', '/api/file/placeholder/p463.png', '', 92.40, '半斤装,1斤装', 150, 802, '天津滨海', '滨海新区虾干 半斤装（新货），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (464, 9, 5, '滨海新区虾干 1斤装（新货）', '/api/file/placeholder/p464.png', '', 64.70, '半斤装,1斤装', 300, 844, '天津滨海', '滨海新区虾干 1斤装（新货），产自天津滨海，当日现摘现发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (465, 9, 5, '滨海新区虾干 半斤装（直供）', '/api/file/placeholder/p465.png', '', 65.60, '半斤装,1斤装', 80, 1170, '天津滨海', '滨海新区虾干 半斤装（直供），产自天津滨海，产地直发。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (466, 9, 5, '滨海新区虾干 1斤装（直供）', '/api/file/placeholder/p466.png', '', 38.30, '半斤装,1斤装', 80, 1034, '天津滨海', '滨海新区虾干 1斤装（直供），产自天津滨海，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (467, 9, 5, '滨海新区虾干 半斤装（老树）', '/api/file/placeholder/p467.png', '', 88.40, '半斤装,1斤装', 80, 1857, '天津滨海', '滨海新区虾干 半斤装（老树），产自天津滨海，坏果包赔。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (468, 9, 5, '滨海新区虾干 1斤装（老树）', '/api/file/placeholder/p468.png', '', 55.10, '半斤装,1斤装', 30, 950, '天津滨海', '滨海新区虾干 1斤装（老树），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (469, 9, 5, '滨海新区虾干 半斤装（当季）', '/api/file/placeholder/p469.png', '', 84.60, '半斤装,1斤装', 150, 241, '天津滨海', '滨海新区虾干 半斤装（当季），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (470, 9, 5, '滨海新区虾干 1斤装（当季）', '/api/file/placeholder/p470.png', '', 47.70, '半斤装,1斤装', 0, 13, '天津滨海', '滨海新区虾干 1斤装（当季），产自天津滨海，冷链直达。由津南绿色农庄直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (471, 2, 2, '盆栽有机蔬菜 单盆（精选）', '/api/file/placeholder/p471.png', '', 36.70, '单盆,三盆组合', 0, 4, '天津西青', '盆栽有机蔬菜 单盆（精选），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (472, 2, 2, '盆栽有机蔬菜 三盆组合（精选）', '/api/file/placeholder/p472.png', '', 18.10, '单盆,三盆组合', 150, 1016, '天津西青', '盆栽有机蔬菜 三盆组合（精选），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (473, 2, 2, '盆栽有机蔬菜 单盆（特选）', '/api/file/placeholder/p473.png', '', 30.50, '单盆,三盆组合', 15, 1064, '天津西青', '盆栽有机蔬菜 单盆（特选），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (474, 2, 2, '盆栽有机蔬菜 三盆组合（特选）', '/api/file/placeholder/p474.png', '', 23.30, '单盆,三盆组合', 200, 764, '天津西青', '盆栽有机蔬菜 三盆组合（特选），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (475, 2, 2, '盆栽有机蔬菜 单盆（家庭装）', '/api/file/placeholder/p475.png', '', 33.80, '单盆,三盆组合', 15, 1944, '天津西青', '盆栽有机蔬菜 单盆（家庭装），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (476, 2, 2, '盆栽有机蔬菜 三盆组合（家庭装）', '/api/file/placeholder/p476.png', '', 42.30, '单盆,三盆组合', 50, 1392, '天津西青', '盆栽有机蔬菜 三盆组合（家庭装），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (477, 2, 2, '盆栽有机蔬菜 单盆（礼盒）', '/api/file/placeholder/p477.png', '', 42.20, '单盆,三盆组合', 15, 1496, '天津西青', '盆栽有机蔬菜 单盆（礼盒），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (478, 2, 2, '盆栽有机蔬菜 三盆组合（礼盒）', '/api/file/placeholder/p478.png', '', 30.40, '单盆,三盆组合', 50, 1538, '天津西青', '盆栽有机蔬菜 三盆组合（礼盒），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (479, 2, 2, '盆栽有机蔬菜 单盆（生态）', '/api/file/placeholder/p479.png', '', 19.30, '单盆,三盆组合', 30, 338, '天津西青', '盆栽有机蔬菜 单盆（生态），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (480, 2, 2, '盆栽有机蔬菜 三盆组合（生态）', '/api/file/placeholder/p480.png', '', 24.00, '单盆,三盆组合', 200, 673, '天津西青', '盆栽有机蔬菜 三盆组合（生态），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (481, 2, 2, '盆栽有机蔬菜 单盆（头茬）', '/api/file/placeholder/p481.png', '', 28.60, '单盆,三盆组合', 80, 1286, '天津西青', '盆栽有机蔬菜 单盆（头茬），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (482, 2, 2, '盆栽有机蔬菜 三盆组合（头茬）', '/api/file/placeholder/p482.png', '', 30.00, '单盆,三盆组合', 150, 439, '天津西青', '盆栽有机蔬菜 三盆组合（头茬），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (483, 2, 2, '盆栽有机蔬菜 单盆（新货）', '/api/file/placeholder/p483.png', '', 31.80, '单盆,三盆组合', 500, 1583, '天津西青', '盆栽有机蔬菜 单盆（新货），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (484, 2, 2, '盆栽有机蔬菜 三盆组合（新货）', '/api/file/placeholder/p484.png', '', 46.60, '单盆,三盆组合', 80, 215, '天津西青', '盆栽有机蔬菜 三盆组合（新货），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (485, 2, 2, '盆栽有机蔬菜 单盆（直供）', '/api/file/placeholder/p485.png', '', 55.90, '单盆,三盆组合', 50, 278, '天津西青', '盆栽有机蔬菜 单盆（直供），产自天津西青，当日现摘现发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (486, 2, 2, '盆栽有机蔬菜 三盆组合（直供）', '/api/file/placeholder/p486.png', '', 52.10, '单盆,三盆组合', 300, 1174, '天津西青', '盆栽有机蔬菜 三盆组合（直供），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (487, 2, 2, '盆栽有机蔬菜 单盆（老树）', '/api/file/placeholder/p487.png', '', 51.20, '单盆,三盆组合', 300, 368, '天津西青', '盆栽有机蔬菜 单盆（老树），产自天津西青，冷链直达。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (488, 2, 2, '盆栽有机蔬菜 三盆组合（老树）', '/api/file/placeholder/p488.png', '', 26.30, '单盆,三盆组合', 15, 80, '天津西青', '盆栽有机蔬菜 三盆组合（老树），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (489, 2, 2, '盆栽有机蔬菜 单盆（当季）', '/api/file/placeholder/p489.png', '', 47.50, '单盆,三盆组合', 500, 349, '天津西青', '盆栽有机蔬菜 单盆（当季），产自天津西青，坏果包赔。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `product` VALUES (490, 2, 2, '盆栽有机蔬菜 三盆组合（当季）', '/api/file/placeholder/p490.png', '', 47.30, '单盆,三盆组合', 30, 859, '天津西青', '盆栽有机蔬菜 三盆组合（当季），产自天津西青，产地直发。由西青沙窝萝卜种植合作社直供发货，48小时内现摘现发，坏果包赔。', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for review
-- ----------------------------
DROP TABLE IF EXISTS `review`;
CREATE TABLE `review`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rel_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'product/farm',
  `rel_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `order_id` bigint(20) NULL DEFAULT NULL COMMENT '商品评价关联的订单',
  `appointment_id` bigint(20) NULL DEFAULT NULL COMMENT '农园评价关联的预约单',
  `rating` tinyint(4) NOT NULL DEFAULT 5 COMMENT '1-5星',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `images` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_rel`(`rel_type`, `rel_id`) USING BTREE,
  INDEX `idx_user`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '评价' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of review
-- ----------------------------
INSERT INTO `review` VALUES (1, 'product', 17, 5, NULL, NULL, 4, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-18 16:56:37');
INSERT INTO `review` VALUES (2, 'product', 155, 1, NULL, NULL, 5, '味道正宗，就是比菜市场稍微贵一点，胜在放心。', '', '2026-08-18 16:56:37');
INSERT INTO `review` VALUES (3, 'product', 70, 1, NULL, NULL, 5, '口感纯正，就是有大小不太均匀，总体满意。', '', '2026-08-27 16:56:37');
INSERT INTO `review` VALUES (4, 'product', 49, 3, NULL, NULL, 4, '口感纯正，就是有大小不太均匀，总体满意。', '', '2026-08-25 16:56:37');
INSERT INTO `review` VALUES (5, 'product', 104, 1, NULL, NULL, 4, '味道正宗，就是比菜市场稍微贵一点，胜在放心。', '', '2026-08-05 16:56:37');
INSERT INTO `review` VALUES (6, 'product', 92, 4, NULL, NULL, 5, '口感纯正，就是有大小不太均匀，总体满意。', '', '2026-08-19 16:56:37');
INSERT INTO `review` VALUES (7, 'product', 164, 4, NULL, NULL, 4, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-29 16:56:37');
INSERT INTO `review` VALUES (8, 'product', 122, 4, NULL, NULL, 4, '孩子特别喜欢，下次还来！客服态度也很好。', '', '2026-08-14 16:56:37');
INSERT INTO `review` VALUES (9, 'product', 93, 3, NULL, NULL, 5, '味道正宗，就是比菜市场稍微贵一点，胜在放心。', '', '2026-08-10 16:56:37');
INSERT INTO `review` VALUES (10, 'product', 42, 2, NULL, NULL, 3, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-16 16:56:37');
INSERT INTO `review` VALUES (11, 'product', 133, 5, NULL, NULL, 4, '味道正宗，就是比菜市场稍微贵一点，胜在放心。', '', '2026-08-21 16:56:37');
INSERT INTO `review` VALUES (12, 'product', 15, 2, NULL, NULL, 4, '孩子特别喜欢，下次还来！客服态度也很好。', '', '2026-08-20 16:56:37');
INSERT INTO `review` VALUES (13, 'product', 109, 1, NULL, NULL, 3, '孩子特别喜欢，下次还来！客服态度也很好。', '', '2026-08-27 16:56:37');
INSERT INTO `review` VALUES (14, 'product', 200, 4, NULL, NULL, 4, '孩子特别喜欢，下次还来！客服态度也很好。', '', '2026-08-15 16:56:37');
INSERT INTO `review` VALUES (15, 'product', 196, 2, NULL, NULL, 4, '口感纯正，就是有大小不太均匀，总体满意。', '', '2026-08-29 16:56:37');
INSERT INTO `review` VALUES (16, 'product', 108, 2, NULL, NULL, 5, '口感纯正，就是有大小不太均匀，总体满意。', '', '2026-08-17 16:56:37');
INSERT INTO `review` VALUES (17, 'product', 109, 2, NULL, NULL, 5, '味道正宗，就是比菜市场稍微贵一点，胜在放心。', '', '2026-08-25 16:56:37');
INSERT INTO `review` VALUES (18, 'product', 71, 2, NULL, NULL, 5, '孩子特别喜欢，下次还来！客服态度也很好。', '', '2026-08-19 16:56:37');
INSERT INTO `review` VALUES (19, 'product', 29, 4, NULL, NULL, 4, '味道正宗，就是比菜市场稍微贵一点，胜在放心。', '', '2026-08-16 16:56:37');
INSERT INTO `review` VALUES (20, 'product', 111, 1, NULL, NULL, 4, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-09-02 16:56:37');
INSERT INTO `review` VALUES (21, 'farm', 22, 1, NULL, NULL, 3, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-22 16:56:37');
INSERT INTO `review` VALUES (22, 'farm', 1, 3, NULL, NULL, 5, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-15 16:56:37');
INSERT INTO `review` VALUES (23, 'farm', 1, 5, NULL, NULL, 3, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-24 16:56:37');
INSERT INTO `review` VALUES (24, 'farm', 7, 3, NULL, NULL, 5, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-25 16:56:37');
INSERT INTO `review` VALUES (25, 'farm', 9, 1, NULL, NULL, 3, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-20 16:56:37');
INSERT INTO `review` VALUES (26, 'farm', 4, 1, NULL, NULL, 4, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-18 16:56:37');
INSERT INTO `review` VALUES (27, 'farm', 18, 3, NULL, NULL, 4, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-09-01 16:56:37');
INSERT INTO `review` VALUES (28, 'farm', 16, 3, NULL, NULL, 5, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-22 16:56:37');
INSERT INTO `review` VALUES (29, 'farm', 26, 5, NULL, NULL, 4, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-31 16:56:37');
INSERT INTO `review` VALUES (30, 'farm', 6, 3, NULL, NULL, 4, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-27 16:56:37');
INSERT INTO `review` VALUES (31, 'farm', 25, 5, NULL, NULL, 3, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-24 16:56:37');
INSERT INTO `review` VALUES (32, 'farm', 13, 3, NULL, NULL, 5, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-17 16:56:37');
INSERT INTO `review` VALUES (33, 'farm', 4, 3, NULL, NULL, 4, '采摘体验很棒，商家很热情，还会讲解种植知识。', '', '2026-08-06 16:56:37');
INSERT INTO `review` VALUES (34, 'farm', 8, 1, NULL, NULL, 5, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-31 16:56:37');
INSERT INTO `review` VALUES (35, 'farm', 23, 2, NULL, NULL, 3, '环境不错，采摘的果子很甜，性价比高。', '', '2026-08-22 16:56:37');

-- ----------------------------
-- Table structure for sys_admin
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `role` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'ADMIN' COMMENT 'ADMIN/SUPER',
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统管理员' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of sys_admin
-- ----------------------------
INSERT INTO `sys_admin` VALUES (1, 'admin', '$2b$10$9H7RfnAU5pRYBPkvSAsBW.qTkXxscb7ycns4Ab6ON9By4kFNv/lT2', '超级管理员', 'SUPER', 1, '2026-09-04 16:56:37');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `openid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '微信openid（演示环境为模拟值',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '绑定手机号',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1正常 0禁用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_openid`(`openid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '平台注册用户' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'mock_openid_demo001', '津门吃货小王', '', '13911110001', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `user` VALUES (2, 'mock_openid_demo002', '爱采摘的丽丽', '', '13911110002', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `user` VALUES (3, 'mock_openid_demo003', '老天津卫张大爷', '', '13911110003', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `user` VALUES (4, 'mock_openid_demo004', '亲子游达人', '', '13911110004', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `user` VALUES (5, 'mock_openid_demo005', '健康饮食派', '', '13911110005', 1, '2026-09-04 16:56:37', '2026-09-04 16:56:37');
INSERT INTO `user` VALUES (6, 'mock_demo-code-001', '微信用户-001', '', '', 1, '2026-09-04 16:58:39', '2026-09-04 16:58:39');
INSERT INTO `user` VALUES (7, 'mock_0f1Vyd100jYm2X16cB000PCCCp1Vyd13', '微信用户yd13', '', '', 1, '2026-09-07 11:34:41', '2026-09-07 11:34:41');

SET FOREIGN_KEY_CHECKS = 1;

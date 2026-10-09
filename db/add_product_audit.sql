-- ============================================================
-- 商品审核功能字段（2026-10-08）
-- 背景：商家新建商品后端强制"待审核"，平台端此前无审核入口，
--       商品永远卡在待审核；且商家可自行切换上下架状态绕过审核。
-- 本次：平台端新增 通过/驳回 按钮 + 审核接口；商家侧上下架受限。
--
-- 在现有库上执行一次即可（导入 db/schema.sql 的全新库已含这两列，无需再执行）。
-- ============================================================

ALTER TABLE `product`
  ADD COLUMN `reject_reason` VARCHAR(255) NULL DEFAULT '' COMMENT '驳回原因（平台驳回时填写，商家修改商品后清空）' AFTER `status`,
  ADD COLUMN `audit_pass` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已通过平台审核：0未过审 1已过审（过审后商家才能自行上架）' AFTER `reject_reason`;

-- 存量回填：历史上已上架/已下架的商品视为已过审（仅 status=2 待审核的保持未过审）
UPDATE `product` SET `audit_pass` = 1 WHERE `status` IN (0, 1);

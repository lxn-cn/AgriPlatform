package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.PageResult;
import com.agri.platform.entity.Category;
import com.agri.platform.entity.Merchant;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.CategoryMapper;
import com.agri.platform.mapper.MerchantMapper;
import com.agri.platform.mapper.ProductMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 商品服务：用户侧浏览、商家侧商品维护、平台侧巡检下架
 */
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductMapper productMapper;
    private final CategoryMapper categoryMapper;
    private final MerchantMapper merchantMapper;
    private final FavoriteService favoriteService;
    private final StringRedisTemplate stringRedisTemplate;
    private final OperLogService operLogService;

    /**
     * 商品列表：分类（含子分类）/关键词筛选 + 排序（price_asc/price_desc/sales）
     */
    public PageResult<Product> page(Long categoryId, String keyword, String sort,
                                    long pageNum, long pageSize) {
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<Product>()
                .eq(Product::getStatus, Constants.PRODUCT_ON);
        if (categoryId != null) {
            List<Long> ids = new ArrayList<Long>();
            ids.add(categoryId);
            List<Category> children = categoryMapper.selectList(new LambdaQueryWrapper<Category>()
                    .eq(Category::getParentId, categoryId));
            for (Category child : children) {
                ids.add(child.getId());
            }
            wrapper.in(Product::getCategoryId, ids);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Product::getName, keyword.trim())
                    .or().like(Product::getOrigin, keyword.trim()));
        }
        if ("price_asc".equals(sort)) {
            wrapper.orderByAsc(Product::getPrice);
        } else if ("price_desc".equals(sort)) {
            wrapper.orderByDesc(Product::getPrice);
        } else if ("sales".equals(sort)) {
            wrapper.orderByDesc(Product::getSales);
        } else {
            wrapper.orderByDesc(Product::getId);
        }
        Page<Product> page = productMapper.selectPage(new Page<Product>(pageNum, pageSize), wrapper);
        return PageResult.from(page);
    }

    /**
     * 商品详情：基础信息 + 所属商家名称 + 当前用户收藏状态（登录时）
     */
    public Map<String, Object> detail(Long id) {
        Product product = productMapper.selectById(id);
        if (product == null || product.getStatus() != Constants.PRODUCT_ON) {
            throw new BizException("商品不存在或已下架");
        }
        Map<String, Object> result = new LinkedHashMap<String, Object>(
                cn.hutool.core.bean.BeanUtil.beanToMap(product));
        Merchant merchant = merchantMapper.selectById(product.getMerchantId());
        result.put("merchantName", merchant == null ? "天津本地商家" : merchant.getName());
        Long userId = AuthContext.currentUserIdOrNull();
        result.put("favored", userId != null && favoriteService.isFavored(userId, id));
        return result;
    }

    // ==================== 商家侧 ====================

    /** 本商家商品分页（附分类路径，供编辑回显） */
    public PageResult<Map<String, Object>> merchantPage(Integer status, String keyword,
                                                        long pageNum, long pageSize) {
        Long merchantId = AuthContext.merchantId();
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<Product>()
                .eq(Product::getMerchantId, merchantId)
                .orderByDesc(Product::getUpdateTime)
                .orderByDesc(Product::getId);
        if (status != null) {
            wrapper.eq(Product::getStatus, status);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.like(Product::getName, keyword.trim());
        }
        Page<Product> page = productMapper.selectPage(new Page<Product>(pageNum, pageSize), wrapper);
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Product p : page.getRecords()) {
            rows.add(merchantRow(p));
        }
        return new PageResult<Map<String, Object>>(page.getTotal(), rows);
    }

    /** 商家商品详情（校验归属） */
    public Map<String, Object> merchantDetail(Long id) {
        Product product = merchantOwnedOrThrow(id);
        return merchantRow(product);
    }

    /** 新建商品（默认待审核） */
    @Transactional(rollbackFor = Exception.class)
    public Product create(Product input) {
        Long merchantId = AuthContext.merchantId();
        validateProductInput(input);
        input.setId(null);
        input.setMerchantId(merchantId);
        input.setStatus(Constants.PRODUCT_AUDITING);
        input.setSales(0);
        input.setCreateTime(LocalDateTime.now());
        input.setUpdateTime(LocalDateTime.now());
        productMapper.insert(input);
        return input;
    }

    /** 修改商品（非空字段生效，归属校验） */
    @Transactional(rollbackFor = Exception.class)
    public Product update(Long id, Product input) {
        Product db = merchantOwnedOrThrow(id);
        validateProductInput(input);
        if (StringUtils.hasText(input.getName())) {
            db.setName(input.getName().trim());
        }
        if (input.getCategoryId() != null) {
            db.setCategoryId(input.getCategoryId());
        }
        if (input.getPrice() != null) {
            db.setPrice(input.getPrice());
        }
        if (input.getStock() != null) {
            db.setStock(input.getStock());
        }
        if (input.getSpecs() != null) {
            db.setSpecs(input.getSpecs());
        }
        if (input.getOrigin() != null) {
            db.setOrigin(input.getOrigin());
        }
        if (input.getMainImage() != null) {
            db.setMainImage(input.getMainImage());
        }
        if (input.getImages() != null) {
            db.setImages(input.getImages());
        }
        if (input.getDescription() != null) {
            db.setDescription(input.getDescription());
        }
        if (input.getStatus() != null) {
            // 商家仅可在上架(1)/下架(0)间切换；改资料回到待审核
            if (input.getStatus() == Constants.PRODUCT_ON || input.getStatus() == Constants.PRODUCT_OFF) {
                db.setStatus(input.getStatus());
            }
        }
        db.setUpdateTime(LocalDateTime.now());
        productMapper.updateById(db);
        return db;
    }

    /** 删除商品 = 逻辑下架 */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        Product db = merchantOwnedOrThrow(id);
        db.setStatus(Constants.PRODUCT_OFF);
        db.setUpdateTime(LocalDateTime.now());
        productMapper.updateById(db);
    }

    // ==================== 平台侧 ====================

    /** 全平台商品分页（附商家名称） */
    public PageResult<Map<String, Object>> adminPage(Integer status, String keyword,
                                                     long pageNum, long pageSize) {
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<Product>()
                .orderByDesc(Product::getId);
        if (status != null) {
            wrapper.eq(Product::getStatus, status);
        }
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            wrapper.and(w -> w.like(Product::getName, kw).or().like(Product::getOrigin, kw));
        }
        Page<Product> page = productMapper.selectPage(new Page<Product>(pageNum, pageSize), wrapper);
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Product p : page.getRecords()) {
            Map<String, Object> row = new LinkedHashMap<String, Object>(
                    cn.hutool.core.bean.BeanUtil.beanToMap(p));
            Merchant merchant = merchantMapper.selectById(p.getMerchantId());
            row.put("merchantName", merchant == null ? "" : merchant.getName());
            rows.add(row);
        }
        return new PageResult<Map<String, Object>>(page.getTotal(), rows);
    }

    /** 违规强制下架（记录操作日志） */
    @Transactional(rollbackFor = Exception.class)
    public void forceOff(Long id) {
        Product product = productMapper.selectById(id);
        if (product == null) {
            throw new BizException("商品不存在");
        }
        product.setStatus(Constants.PRODUCT_OFF);
        product.setUpdateTime(LocalDateTime.now());
        productMapper.updateById(product);
        operLogService.record(Constants.OPERATOR_ADMIN, AuthContext.adminId(), AuthContext.name(),
                "PRODUCT_FORCE_OFF", "强制下架商品#" + id + "（" + product.getName() + "）");
    }

    // ==================== 私有辅助 ====================

    private Product merchantOwnedOrThrow(Long id) {
        Product product = productMapper.selectById(id);
        if (product == null || !product.getMerchantId().equals(AuthContext.merchantId())) {
            throw new BizException("商品不存在或无权操作");
        }
        return product;
    }

    private void validateProductInput(Product input) {
        if (StringUtils.hasText(input.getName()) && input.getName().trim().isEmpty()) {
            throw new BizException("商品名称不能为空");
        }
        if (input.getCategoryId() != null && categoryMapper.selectById(input.getCategoryId()) == null) {
            throw new BizException("商品分类不存在");
        }
        if (input.getPrice() != null && input.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0) {
            throw new BizException("价格不能为负数");
        }
        if (input.getStock() != null && input.getStock() < 0) {
            throw new BizException("库存不能为负数");
        }
    }

    /** 商家商品行：附加分类路径（供级联回显） */
    private Map<String, Object> merchantRow(Product p) {
        Map<String, Object> row = new LinkedHashMap<String, Object>(
                cn.hutool.core.bean.BeanUtil.beanToMap(p));
        List<Long> path = new ArrayList<Long>();
        if (p.getCategoryId() != null) {
            Category category = categoryMapper.selectById(p.getCategoryId());
            if (category != null) {
                if (category.getParentId() != null && category.getParentId() != 0) {
                    path.add(category.getParentId());
                    row.put("parentCategoryId", category.getParentId());
                }
                path.add(category.getId());
                row.put("categoryName", category.getName());
            }
        }
        row.put("categoryPath", path);
        return row;
    }
}

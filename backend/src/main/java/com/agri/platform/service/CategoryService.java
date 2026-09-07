package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.entity.Category;
import com.agri.platform.entity.Product;
import com.agri.platform.mapper.CategoryMapper;
import com.agri.platform.mapper.ProductMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 商品分类服务：两级分类树维护
 */
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryMapper categoryMapper;
    private final ProductMapper productMapper;

    /** 小程序分类树（仅启用的分类） */
    public List<Map<String, Object>> tree() {
        return buildTree(true);
    }

    /** 管理端分类树（含下线分类） */
    public List<Map<String, Object>> adminTree() {
        return buildTree(false);
    }

    private List<Map<String, Object>> buildTree(boolean onlyEnabled) {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<Category>()
                .orderByAsc(Category::getSort).orderByAsc(Category::getId);
        if (onlyEnabled) {
            wrapper.eq(Category::getStatus, 1);
        }
        List<Category> all = categoryMapper.selectList(wrapper);
        List<Map<String, Object>> roots = new ArrayList<Map<String, Object>>();
        for (Category c : all) {
            if (c.getParentId() == null || c.getParentId() == 0) {
                roots.add(toNode(c, all));
            }
        }
        return roots;
    }

    private Map<String, Object> toNode(Category c, List<Category> all) {
        Map<String, Object> node = new LinkedHashMap<String, Object>();
        node.put("id", c.getId());
        node.put("name", c.getName());
        node.put("parentId", c.getParentId());
        node.put("sort", c.getSort());
        node.put("status", c.getStatus());
        node.put("createTime", c.getCreateTime());
        List<Map<String, Object>> children = new ArrayList<Map<String, Object>>();
        for (Category child : all) {
            if (c.getId().equals(child.getParentId())) {
                children.add(toNode(child, all));
            }
        }
        node.put("children", children);
        return node;
    }

    /** 新增分类 */
    @Transactional(rollbackFor = Exception.class)
    public Category create(Category category) {
        if (!StringUtils.hasText(category.getName())) {
            throw new BizException("分类名称不能为空");
        }
        Long parentId = category.getParentId() == null ? 0L : category.getParentId();
        if (parentId != 0L && categoryMapper.selectById(parentId) == null) {
            throw new BizException("父级分类不存在");
        }
        category.setParentId(parentId);
        category.setSort(category.getSort() == null ? 0 : category.getSort());
        category.setStatus(category.getStatus() == null ? 1 : category.getStatus());
        category.setCreateTime(LocalDateTime.now());
        categoryMapper.insert(category);
        return category;
    }

    /** 修改分类（非空字段生效） */
    @Transactional(rollbackFor = Exception.class)
    public Category update(Long id, Category input) {
        Category db = categoryMapper.selectById(id);
        if (db == null) {
            throw new BizException("分类不存在");
        }
        if (StringUtils.hasText(input.getName())) {
            db.setName(input.getName().trim());
        }
        if (input.getParentId() != null) {
            if (input.getParentId().equals(id)) {
                throw new BizException("父级分类不能是自己");
            }
            db.setParentId(input.getParentId());
        }
        if (input.getSort() != null) {
            db.setSort(input.getSort());
        }
        if (input.getStatus() != null) {
            db.setStatus(input.getStatus());
        }
        categoryMapper.updateById(db);
        return db;
    }

    /** 删除分类（存在子分类或关联商品时禁止） */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        Long children = categoryMapper.selectCount(new LambdaQueryWrapper<Category>()
                .eq(Category::getParentId, id));
        if (children != null && children > 0) {
            throw new BizException("该分类下存在子分类，无法删除");
        }
        Long products = productMapper.selectCount(new LambdaQueryWrapper<Product>()
                .eq(Product::getCategoryId, id));
        if (products != null && products > 0) {
            throw new BizException("该分类下存在商品，无法删除");
        }
        categoryMapper.deleteById(id);
    }
}

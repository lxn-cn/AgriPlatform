package com.agri.platform.common;

import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.Data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 统一分页返回结构：{ total, list }
 */
@Data
public class PageResult<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    private long total;
    private List<T> list;

    public PageResult() {
        this.list = new ArrayList<T>();
    }

    public PageResult(long total, List<T> list) {
        this.total = total;
        this.list = list == null ? new ArrayList<T>() : list;
    }

    public static <T> PageResult<T> of(long total, List<T> list) {
        return new PageResult<T>(total, list);
    }

    public static <T> PageResult<T> empty() {
        return new PageResult<T>(0, new ArrayList<T>());
    }

    public static <T> PageResult<T> from(IPage<T> page) {
        if (page == null) {
            return empty();
        }
        return new PageResult<T>(page.getTotal(), page.getRecords());
    }
}

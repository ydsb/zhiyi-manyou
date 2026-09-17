package com.nwu.zhiyi.common.api;

import lombok.Data;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * 分页结果。
 *
 * @param <T> 记录类型
 * @author 李泽宬
 */
@Data
public class PageResult<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 当前页数据 */
    private List<T> records;

    /** 总条数 */
    private long total;

    /** 当前页码（从 1 开始） */
    private long page;

    /** 每页条数 */
    private long size;

    /** 总页数 */
    private long pages;

    public static <T> PageResult<T> of(List<T> records, long total, long page, long size) {
        PageResult<T> result = new PageResult<>();
        result.setRecords(records == null ? Collections.emptyList() : records);
        result.setTotal(total);
        result.setPage(page);
        result.setSize(size);
        result.setPages(size <= 0 ? 0 : (total + size - 1) / size);
        return result;
    }

    public static <T> PageResult<T> empty(long page, long size) {
        return of(Collections.emptyList(), 0, page, size);
    }
}

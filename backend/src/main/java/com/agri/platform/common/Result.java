package com.agri.platform.common;

import lombok.Data;

import java.io.Serializable;

/**
 * 统一响应结构：code / msg / data
 */
@Data
public class Result<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 200 成功；401 未登录；403 无权限；400 业务失败；500 系统异常 */
    private int code;
    private String msg;
    private T data;

    public Result() {
    }

    public Result(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    public static <T> Result<T> ok() {
        return new Result<T>(200, "success", null);
    }

    public static <T> Result<T> ok(T data) {
        return new Result<T>(200, "success", data);
    }

    public static <T> Result<T> ok(String msg, T data) {
        return new Result<T>(200, msg, data);
    }

    public static <T> Result<T> fail(String msg) {
        return new Result<T>(400, msg, null);
    }

    public static <T> Result<T> fail(int code, String msg) {
        return new Result<T>(code, msg, null);
    }
}

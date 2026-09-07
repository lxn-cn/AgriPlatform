package com.agri.platform.common;

import lombok.Getter;

/**
 * 业务异常：携带错误提示文案与错误码（默认 400）
 */
@Getter
public class BizException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final int code;

    public BizException(String message) {
        super(message);
        this.code = 400;
    }

    public BizException(int code, String message) {
        super(message);
        this.code = code;
    }
}

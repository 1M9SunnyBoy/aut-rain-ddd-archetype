#set( $dollar = '$' )
#set( $hash = '#' )
package com.rain.${artifactId.replace('-', '_')}.types.exception;

import com.rain.${artifactId.replace('-', '_')}.types.common.Constants.ResponseCode;

/**
 * 可预期的业务异常。不要把数据库、HTTP 客户端等基础设施异常直接暴露给接口层。
 */
public class BusinessException extends RuntimeException {
    private final String code;

    public BusinessException(ResponseCode responseCode) {
        this(responseCode.getCode(), responseCode.getInfo());
    }

    public BusinessException(ResponseCode responseCode, Throwable cause) {
        this(responseCode.getCode(), responseCode.getInfo(), cause);
    }

    public BusinessException(String code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
    }

    /** 为项目自定义业务码保留扩展入口，code 应来自集中维护的定义。 */
    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
    }

    public String code() {
        return code;
    }
}

#set( $dollar = '$' )
#set( $hash = '#' )
package com.rain.${artifactId.replace('-', '_')}.types.model;

import com.rain.${artifactId.replace('-', '_')}.types.common.Constants.ResponseCode;

/**
 * 对外接口的统一响应包装。业务数据通过 data 返回，错误由 code/message 表达。
 */
public record ApiResponse<T>(String code, String message, T data) {
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(ResponseCode.SUCCESS.getCode(), ResponseCode.SUCCESS.getInfo(), data);
    }

    public static <T> ApiResponse<T> failure(ResponseCode responseCode) {
        return failure(responseCode.getCode(), responseCode.getInfo());
    }

    public static <T> ApiResponse<T> failure(String code, String message) {
        return new ApiResponse<>(code, message, null);
    }
}

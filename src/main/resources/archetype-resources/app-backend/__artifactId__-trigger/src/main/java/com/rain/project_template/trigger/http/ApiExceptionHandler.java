#set( $dollar = '$' )
#set( $hash = '#' )
package com.rain.${artifactId.replace('-', '_')}.trigger.http;

import com.rain.${artifactId.replace('-', '_')}.types.common.Constants.ResponseCode;
import com.rain.${artifactId.replace('-', '_')}.types.exception.BusinessException;
import com.rain.${artifactId.replace('-', '_')}.types.model.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/** Converts expected business failures into the public response contract. */
@RestControllerAdvice
public class ApiExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusiness(BusinessException exception) {
        // 本项目的 HTTP 映射约定，不属于阿里业务响应码编码规则。
        HttpStatus status = HttpStatus.BAD_REQUEST;
        if (ResponseCode.SYSTEM_ERROR.getCode().equals(exception.code())) {
            status = HttpStatus.INTERNAL_SERVER_ERROR;
        } else if (ResponseCode.THIRD_PARTY_ERROR.getCode().equals(exception.code())) {
            status = HttpStatus.SERVICE_UNAVAILABLE;
        }
        return ResponseEntity.status(status).body(ApiResponse.failure(exception.code(), exception.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleUnexpected(Exception exception) {
        return ResponseEntity.internalServerError().body(ApiResponse.failure(ResponseCode.SYSTEM_ERROR));
    }
}

#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 api.model 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 接口请求、响应及 DTO；只依赖 types 中的通用类型。
 */
package com.rain.${artifactId.replace('-', '_')}.api.model;

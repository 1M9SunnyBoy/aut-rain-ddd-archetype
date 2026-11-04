#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 trigger.http 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * HTTP Controller 与统一异常处理，不直接访问 DAO 或缓存实现。
 */
package com.rain.${artifactId.replace('-', '_')}.trigger.http;

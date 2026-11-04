#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 infrastructure.redis 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * Redis 缓存及数据访问封装；按需选择客户端，在 app/config 中装配。
 */
package com.rain.${artifactId.replace('-', '_')}.infrastructure.redis;

#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 test.infrastructure.redis 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 缓存适配测试；需要 Redis 的集成测试使用 IT 后缀并显式运行。
 */
package com.rain.${artifactId.replace('-', '_')}.test.infrastructure.redis;

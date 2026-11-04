#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 test.infrastructure.persistent 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 持久化适配测试；需要数据库的集成测试使用 IT 后缀并显式运行。
 */
package com.rain.${artifactId.replace('-', '_')}.test.infrastructure.persistent;

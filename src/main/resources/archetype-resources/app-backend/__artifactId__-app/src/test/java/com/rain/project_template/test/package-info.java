#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 test 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 应用模块集中放置各层测试；单元测试无需外部服务。
 */
package com.rain.${artifactId.replace('-', '_')}.test;

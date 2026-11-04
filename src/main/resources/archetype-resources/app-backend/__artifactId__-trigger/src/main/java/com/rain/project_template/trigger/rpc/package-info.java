#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 trigger.rpc 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 实现 api 模块定义的对外服务契约，RPC 框架按业务需要引入。
 */
package com.rain.${artifactId.replace('-', '_')}.trigger.rpc;

#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 infrastructure.gateway.api 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 外部系统的客户端接口，封装 HTTP、RPC 等远程协议。
 */
package com.rain.${artifactId.replace('-', '_')}.infrastructure.gateway.api;

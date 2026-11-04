#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 trigger 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 入站适配层，将 HTTP、RPC、消息及定时任务转换为领域服务调用。
 */
package com.rain.${artifactId.replace('-', '_')}.trigger;

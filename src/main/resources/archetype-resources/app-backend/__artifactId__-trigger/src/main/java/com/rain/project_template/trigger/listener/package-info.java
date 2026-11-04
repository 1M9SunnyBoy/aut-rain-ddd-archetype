#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 trigger.listener 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 消息监听入口；按需引入消息 SDK，处理幂等并调用领域服务。
 */
package com.rain.${artifactId.replace('-', '_')}.trigger.listener;

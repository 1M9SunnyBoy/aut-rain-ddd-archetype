#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 trigger.job 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 调度任务入口；按需接入 XXL-Job 等调度器并调用领域服务。
 */
package com.rain.${artifactId.replace('-', '_')}.trigger.job;

#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 api 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 对外接口契约，供 trigger 的 RPC 等入口实现；不暴露领域内部类型。
 */
package com.rain.${artifactId.replace('-', '_')}.api;

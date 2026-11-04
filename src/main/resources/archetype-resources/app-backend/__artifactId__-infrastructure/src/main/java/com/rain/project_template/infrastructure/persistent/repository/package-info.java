#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 infrastructure.persistent.repository 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 实现 domain 下各业务领域的 repository 接口，并完成 PO 与领域模型转换。
 */
package com.rain.${artifactId.replace('-', '_')}.infrastructure.persistent.repository;

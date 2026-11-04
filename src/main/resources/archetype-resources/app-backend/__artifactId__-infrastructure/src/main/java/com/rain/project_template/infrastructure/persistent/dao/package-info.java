#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录 infrastructure.persistent.dao 包的职责和依赖边界。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 数据库访问接口，例如 MyBatis Mapper；不对 trigger 暴露。
 */
package com.rain.${artifactId.replace('-', '_')}.infrastructure.persistent.dao;

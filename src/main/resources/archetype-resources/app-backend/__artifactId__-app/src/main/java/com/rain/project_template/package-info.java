#set( $dollar = '$' )
#set( $hash = '#' )
/*
 * description: 记录应用根包的职责和扫描范围。
 * author: zzy
 * created: 2026-10-19
 */
/**
 * 应用启动根包，Application 位于此处以扫描所有模块。
 */
package com.rain.${artifactId.replace('-', '_')};

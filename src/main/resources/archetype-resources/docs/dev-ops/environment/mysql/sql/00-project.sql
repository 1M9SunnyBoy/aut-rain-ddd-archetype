#if( $databaseName == "auto" )
#set( $databaseName = $artifactId.replace('-', '_') )
#end
-- description: 创建项目业务数据库，业务表交由 Flyway 管理。
-- author: zzy
-- created: 2026-10-29
-- Project database only. Business tables and seed data are managed by Flyway.
CREATE DATABASE IF NOT EXISTS `${databaseName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

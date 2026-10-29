#if( $databaseName == "auto" )
#set( $databaseName = $artifactId.replace('-', '_') )
#end
-- Project database only. Business tables and seed data are managed by Flyway.
CREATE DATABASE IF NOT EXISTS `${databaseName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

#set( $dollar = '$' )
#set( $hash = '#' )
${hash}!/usr/bin/env bash
${hash} Run by the official MySQL entrypoint on an EMPTY data volume only.
${hash} Development only. Nacos uses Derby; only XXL-Job needs MySQL initialization.
${hash} Keep LF line endings. This script runs inside Linux MySQL, not in Windows PowerShell.
for key in XXL_JOB_DB_PASSWORD XXL_JOB_ADMIN_PASSWORD; do
  value="${dollar}{!key}"
  if [[ ! "${dollar}value" =~ ^[A-Za-z0-9_-]{1,128}${dollar} ]]; then
    echo "Invalid middleware credential: ${dollar}key" >&2
    exit 1
  fi
done
${hash} Windows bind mounts may mark the file executable: support both exec and source.
${hash} The entrypoint's temporary MySQL server is socket-only during initialization.
MYSQL_PWD="${dollar}MYSQL_ROOT_PASSWORD" mysql --protocol=socket -uroot <<EOSQL
CREATE DATABASE IF NOT EXISTS xxl_job CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'xxl_job'@'%' IDENTIFIED BY '${dollar}XXL_JOB_DB_PASSWORD';
GRANT ALL ON xxl_job.* TO 'xxl_job'@'%';
USE xxl_job;
SOURCE /opt/middleware-sql/xxl-job.sql;
INSERT INTO xxl_job_user (username, password, role, permission)
VALUES ('admin', MD5('${dollar}XXL_JOB_ADMIN_PASSWORD'), 1, NULL);
EOSQL

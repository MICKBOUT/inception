#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[entrypoint] No existing DB found, initializing..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    cat > /tmp/init.sql <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost');
        DROP DATABASE IF EXISTS test;

        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "[entrypoint] Starting mariadbd with init-file..."
    exec mariadbd --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init.sql
else
    echo "[entrypoint] Existing DB found, skipping initialization."
    exec mariadbd --user=mysql --datadir=/var/lib/mysql
fi
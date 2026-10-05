#!/bin/bash
set -e

# The bind-mounted WordPress directory may have been created by the host user
# (or left owned by nobody). PHP-FPM runs as www-data and needs to write here.
chown -R www-data:www-data /var/www/html

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_USER=$(grep WP_ADMIN_USER /run/secrets/credentials | cut -d= -f2)
WP_ADMIN_PASSWORD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d= -f2)
WP_USER=$(grep WP_USER= /run/secrets/credentials | cut -d= -f2)
WP_USER_PASSWORD=$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d= -f2)

# Wait for MariaDB to be reachable before touching WP-CLI
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${DB_PASSWORD}" --silent; do
    echo "[entrypoint] Waiting for mariadb..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[entrypoint] No existing WordPress install found, installing..."

    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="admin@${DOMAIN_NAME}" \
        --allow-root

    wp user create "${WP_USER}" "user@${DOMAIN_NAME}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root

    echo "[entrypoint] WordPress installed."
else
    echo "[entrypoint] Existing WordPress install found, skipping install."
fi

wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp config set WP_REDIS_DATABASE 0 --raw --allow-root
wp config set WP_REDIS_TIMEOUT 1 --raw --allow-root
wp config set WP_REDIS_READ_TIMEOUT 1 --raw --allow-root
wp config set WP_CACHE true --raw --allow-root
wp config set FS_METHOD direct --allow-root
echo "Redis Cache has beed configured"

if ! wp plugin is-installed redis-cache --allow-root; then
    echo "[entrypoint] Installing Redis Cache plugin..."
    wp plugin install redis-cache --activate --allow-root
else
	echo "Redis Cache is already installed"
fi

wp plugin activate redis-cache --allow-root 2>/dev/null || true

wp redis enable --allow-root || echo "Failed to enable Redis"

chown -R www-data:www-data /var/www/html

echo "[entrypoint] Starting php-fpm..."
exec php-fpm8.2 -F

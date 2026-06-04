#!/bin/bash
set -e

# 1. Wait for MySQL network port to accept connections
echo "Waiting for database network port on $WORDPRESS_DB_HOST:3306..."
while ! timeout 1 bash -c "cat < /dev/null > /dev/tcp/$WORDPRESS_DB_HOST/3306" 2> /dev/null; do
    sleep 2
done
echo "Database port is online!"

# Move into the mounted volume workspace
mkdir -p /var/www/html
cd /var/www/html

# 2. If the folder is empty, download WordPress core files using WP-CLI
if [ ! -f index.php ] && [ ! -f wp-settings.php ]; then
    echo "Volume is empty. Downloading WordPress core files..."
    php -d memory_limit=512M /usr/local/bin/wp core download --allow-root
fi

# 3. Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php configuration..."
    php -d memory_limit=512M /usr/local/bin/wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root

    echo "Injecting absolute URL mappings into wp-config..."
    php -d memory_limit=512M /usr/local/bin/wp config set WP_HOME "${WP_URL}" --allow-root
    php -d memory_limit=512M /usr/local/bin/wp config set WP_SITEURL "${WP_URL}" --allow-root
fi

# 4. Check if the database tables are loaded, run silent installer if unconfigured
if ! php -d memory_limit=512M /usr/local/bin/wp core is-installed --allow-root; then
    echo "Database tables missing. Running automated web installation..."
    php -d memory_limit=512M /usr/local/bin/wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    echo "WordPress database installation fully complete!"
else
    echo "WordPress is already completely installed."
fi

# 5. Fix permissions so the native www-data user has full access
echo "Aligning file execution ownership permissions to www-data..."
chown -R www-data:www-data /var/www/html

# 6. Execute PHP-FPM 8.3 in the foreground
echo "Launching Alpine PHP-FPM processor layer..."
exec /usr/sbin/php-fpm83 -F
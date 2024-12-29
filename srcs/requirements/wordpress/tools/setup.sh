#!/bin/bash

# エラーハンドリング
set -e

# 環境変数のチェック
if [ -z "$DOMAIN_NAME" ] || [ -z "$WP_ADMIN_USER" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_ADMIN_EMAIL" ] || \
   [ -z "$WP_USER" ] || [ -z "$WP_USER_PASSWORD" ] || [ -z "$WP_USER_EMAIL" ]; then
    echo "Error: Required environment variables are not set"
    exit 1
fi

# MariaDBの接続を待機
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h mariadb --silent; do
    sleep 1
done

# WordPressのインストールディレクトリに移動
cd /var/www/html

# WordPressのダウンロードとインストール
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Configuring WordPress..."
    mv /var/www/html/wp-config.php /var/www/html/wp-config.php.bak
    wp config create --allow-root \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --dbcharset="utf8mb4"

    echo "Installing WordPress..."
    wp core install --allow-root \
        --url=https://${DOMAIN_NAME} \
        --title="WordPress Site" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL}

    echo "Creating additional user..."
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --role=editor \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root

    # 基本的な設定
    wp option update blog_public 0 --allow-root # 検索エンジンからのアクセスを制限
    wp rewrite structure '/%postname%/' --allow-root # パーマリンク設定

    # 不要なプラグインとテーマを削除
    wp plugin delete hello --allow-root
    wp theme delete twentynineteen twentytwenty --allow-root

    # 必要なプラグインのインストール
    wp plugin install wp-super-cache --activate --allow-root

    echo "WordPress setup completed successfully!"
else
    echo "WordPress is already installed."
fi

# ディレクトリのパーミッション設定
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
exec php-fpm7.3 -F

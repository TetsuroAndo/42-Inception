FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-common \
    php7.3-mbstring \
    php7.3-xml \
    php7.3-curl \
    php7.3-gd \
    php7.3-intl \
    php7.3-zip \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# WordPressのダウンロードとインストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# PHP-FPMの設定
RUN mkdir -p /run/php && \
    chown www-data:www-data /run/php

# WordPressディレクトリの準備
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# 設定ファイルのコピー
COPY ./conf/www.conf /etc/php/7.3/fpm/pool.d/
COPY ./tools/wp-config.php /var/www/html/
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

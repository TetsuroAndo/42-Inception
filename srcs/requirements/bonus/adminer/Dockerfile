FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-common \
    php7.3-curl \
    curl \
    && rm -rf /var/lib/apt/lists/*

# PHP-FPMの設定
RUN mkdir -p /run/php

# Adminerのセットアップ
WORKDIR /var/www/html
COPY ./tools/index.php .

# PHP-FPMの設定
RUN echo "\
    [www]\n\
    user = www-data\n\
    group = www-data\n\
    listen = 9000\n\
    pm = dynamic\n\
    pm.max_children = 5\n\
    pm.start_servers = 2\n\
    pm.min_spare_servers = 1\n\
    pm.max_spare_servers = 3\n\
    " > /etc/php/7.3/fpm/pool.d/www.conf

EXPOSE 9000

CMD ["php-fpm7.3", "-F"]

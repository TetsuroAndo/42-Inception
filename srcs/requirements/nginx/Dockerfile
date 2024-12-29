FROM debian:buster

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directory for nginx pid
RUN mkdir -p /run/nginx

# SSL証明書の生成
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=JP/ST=Tokyo/L=Minato/O=42Tokyo/OU=Student/CN=atomboy.42.fr"

# Nginxの設定ファイルをコピー
COPY ./conf/default.conf /etc/nginx/conf.d/
RUN rm /etc/nginx/sites-enabled/default

# WordPress用のディレクトリを作成
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 443

# ヘルスチェック用のファイルを作成
RUN echo "OK" > /var/www/html/healthcheck.html

CMD ["nginx", "-g", "daemon off;"]

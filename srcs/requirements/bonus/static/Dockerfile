FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Nginxの設定
COPY ./conf/default.conf /etc/nginx/conf.d/
RUN rm /etc/nginx/sites-enabled/default

# 静的コンテンツのコピー
COPY ./html/ /var/www/html/

# ログディレクトリの作成
RUN mkdir -p /var/log/nginx && \
    chown -R www-data:www-data /var/www/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

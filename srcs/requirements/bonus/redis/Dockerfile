FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# 設定ファイルとセットアップスクリプトをコピー
COPY ./conf/redis.conf /etc/redis/
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# データディレクトリの作成
RUN mkdir -p /data && \
    chown -R redis:redis /data

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/setup.sh"]

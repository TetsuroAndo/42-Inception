#!/bin/sh
set -e

# 環境変数のチェック
if [ -z "$REDIS_PASSWORD" ]; then
    echo "Error: REDIS_PASSWORD is not set"
    exit 1
fi

# データディレクトリの作成
mkdir -p /data /var/log/redis
chown -R redis:redis /data /var/log/redis

# 設定ファイルの環境変数を置換
sed -i "s/\${REDIS_PASSWORD}/$REDIS_PASSWORD/g" /etc/redis/redis.conf

# Redisサーバーの起動
exec redis-server /etc/redis/redis.conf

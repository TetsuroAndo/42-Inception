#!/bin/bash
set -e

# 環境変数のチェック
if [ -z "$FTP_USER" ] || [ -z "$FTP_PASSWORD" ]; then
    echo "Error: FTP_USER or FTP_PASSWORD is not set"
    exit 1
fi

# FTPユーザーの作成
adduser --disabled-password --gecos "" $FTP_USER
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# 必要なディレクトリの作成
mkdir -p /var/run/vsftpd/empty
mkdir -p /var/www/html
chown -R $FTP_USER:$FTP_USER /var/www/html

# ログディレクトリの作成
mkdir -p /var/log
touch /var/log/vsftpd.log

# vsftpdの起動
exec vsftpd /etc/vsftpd/vsftpd.conf

FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# 設定ファイルとセットアップスクリプトをコピー
COPY ./conf/vsftpd.conf /etc/vsftpd/
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# 必要なディレクトリの作成
RUN mkdir -p /var/run/vsftpd/empty /var/www/html

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/setup.sh"]

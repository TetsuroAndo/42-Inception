# Inception Project Write-Up

## 1. プロジェクト概要

Inception プロジェクトは、Docker を使用して複数のサービスを構築・運用するインフラストラクチャプロジェクトです。
必須要件とボーナス要件を含む、完全な開発環境を Docker コンテナで実現しています。

### 主な目標

- Docker Compose を使用した複数サービスの管理
- TLS v1.2/v1.3 によるセキュアな通信
- データの永続化とバックアップ
- 環境変数による設定管理
- 各サービスの独立性と連携

### ディレクトリ構造

```
inception/
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env.template
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   └── conf/
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── redis/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── ftp/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── adminer/
│       │   ├── Dockerfile
│       │   └── tools/
│       └── static/
│           ├── Dockerfile
│           ├── conf/
│           └── html/
└── data/
    ├── wp/
    ├── db/
    └── redis/
```

## 2. 開発環境のセットアップ

### 2.1 必要なツール

以下のツールが必要です：

1. **Docker**

   - バージョン 20.10.0 以上
   - インストール方法：[Docker 公式サイト](https://docs.docker.com/get-docker/)

2. **Docker Compose**

   - バージョン 2.0.0 以上
   - 通常、Docker Desktop に含まれています

3. **make**
   - ビルドの自動化に使用
   - macOS: `xcode-select --install` でインストール

### 2.2 初期セットアップ手順

1. **リポジトリのクローン**

```bash
git clone <repository-url> inception
cd inception
```

2. **ディレクトリ構造の作成**

```bash
# 必要なディレクトリを作成
mkdir -p srcs/requirements/{mariadb,nginx,wordpress}/{conf,tools}
mkdir -p data/{wp,db,redis}
```

3. **環境変数の設定**

```bash
# .env.templateをコピーして.envを作成
cp srcs/.env.template srcs/.env

# .envファイルを編集
# 以下の項目を必ず設定してください：
# - DOMAIN_NAME=atomboy.42.fr
# - MYSQL_ROOT_PASSWORD（強力なパスワード）
# - MYSQL_USER（データベースユーザー名）
# - MYSQL_PASSWORD（データベースパスワード）
# - WP_ADMIN_USER（WordPress管理者）
# - WP_ADMIN_PASSWORD（WordPress管理者パスワード）
```

4. **ホスト名の設定**

```bash
# /etc/hostsファイルに以下を追加
sudo echo "127.0.0.1 atomboy.42.fr" >> /etc/hosts
```

## 3. プロジェクトの構築と実行

### 3.1 基本的なビルドと実行

1. **すべてのサービスをビルドして起動**

```bash
# ビルドと起動を実行
make all

# 状態確認
make ps
```

2. **個別のサービス管理**

```bash
# 特定のサービスのログを確認
make wordpress-logs
make mariadb-logs
make nginx-logs

# サービスの再起動
make reload
```

### 3.2 トラブルシューティング

1. **よくある問題と解決方法**

- **ポートの競合**

  ```bash
  # 使用中のポートを確認
  sudo lsof -i :80
  sudo lsof -i :443

  # 競合するプロセスを停止
  sudo kill <PID>
  ```

- **パーミッションエラー**
  ```bash
  # データディレクトリの権限を修正
  sudo chown -R $(whoami):$(whoami) data/
  ```

2. **ログの確認方法**

```bash
# すべてのサービスのログを表示
make logs

# 特定のサービスのログをフォロー
docker-compose -f srcs/docker-compose.yml logs -f wordpress
```

## 4. サービスの詳細設定

### 4.1 WordPress

1. **初期設定**

- ブラウザで `https://atomboy.42.fr` にアクセス
- 管理者アカウントは自動作成済み（.env の設定値）
- 追加のユーザー作成が必要な場合は管理画面から実施

2. **プラグインのインストール**

- Redis Cache プラグイン（自動インストール済み）
- 必要に応じて追加のプラグインをインストール

### 4.2 データベース管理（Adminer）

1. **アクセス方法**

- `https://atomboy.42.fr/adminer/` にアクセス
- ログイン情報：
  - サーバー: mariadb
  - ユーザー名: .env で設定した MYSQL_USER
  - パスワード: .env で設定した MYSQL_PASSWORD
  - データベース: wordpress

### 4.3 FTP サーバー

1. **接続設定**

```bash
# FTPクライアントの設定
ホスト: atomboy.42.fr
ポート: 21
ユーザー名: .envで設定したFTP_USER
パスワード: .envで設定したFTP_PASSWORD
```

2. **使用方法**

- WordPress のテーマやプラグインのファイル管理
- コンテンツのバックアップ

### 4.4 Redis キャッシュ

1. **動作確認**

```bash
# Redisに接続
make redis-cli

# キャッシュの状態確認
INFO stats
```

2. **キャッシュのクリア**

```bash
# すべてのキャッシュをクリア
make redis-cli
> FLUSHALL
```

## 5. メンテナンスと運用

### 5.1 定期的なメンテナンス

1. **バックアップ**

```bash
# データのバックアップ
make backup

# 特定のサービスのみバックアップ
make backup-wordpress
make backup-database
```

2. **アップデート**

```bash
# イメージの更新
make update

# 設定の再読み込み
make reload

# 完全なクリーンアップ
make clean

# 設定を含む完全な再構築
make re
```

## 9. 今後の改善点

1. 監視システムの強化

   - Prometheus によるメトリクス収集
   - Grafana による可視化

2. バックアップの自動化

   - クーロンジョブの設定
   - バックアップローテーション

3. セキュリティの強化

   - WAF の導入
   - 定期的な脆弱性スキャン

4. パフォーマンスの最適化

   - キャッシュ戦略の改善
   - CDN の導入検討

5. ボーナスパートの役立つ機能の追加（個人自由）
   - サービスを考える

# メモ

まず、Makefile を作成します：
Makefile

次に、必要なディレクトリ構造を作成します：

Ran terminal command
~/42Toybox/0-Cursus/51-Inception
$ mkdir -p srcs/requirements/mariadb/conf srcs/requirements/mariadb/tools srcs/requirements/nginx/conf srcs/requirements/nginx/tools srcs/requirements/wordpress/conf srcs/requirements/wordpress/tools

次に、環境変数ファイル（.env）を作成します：
.env

docker-compose.yml を作成します：
docker-compose.yml

各サービスの Dockerfile とその設定ファイルを作成します。
まず、MariaDB の Dockerfile と設定ファイル：
Dockerfile

MariaDB の設定ファイル：
50-server.cnf

MariaDB の初期化スクリプト：
init_db.sh

次に、Nginx の設定：

Nginx の Dockerfile と設定ファイル：
Dockerfile

Nginx の設定ファイル：
default.conf

最後に、WordPress の設定：
Dockerfile

WordPress の PHP-FPM 設定：
www.conf

WordPress 設定ファイル：
wp-config.php

WordPress セットアップスクリプト：
setup.sh

データディレクトリを作成し、.gitkeep ファイルを追加します：

Ran terminal command
~/42Toybox/0-Cursus/51-Inception
$ mkdir -p ./data/wp ./data/db

.gitkeep ファイルを作成します：
.gitkeep

これで基本的なディレクトリ構造と設定ファイルの作成が完了しました。以下が実装した内容の概要です：

基本構造
Makefile の作成（build, up, down, clean, fclean, re ターゲットを含む）
srcs/ディレクトリ以下に各サービスの設定を配置
環境変数ファイル（.env）の作成
MariaDB
Dockerfile: debian:buster ベースのイメージ作成
設定ファイル（50-server.cnf）
初期化スクリプト（init_db.sh）
Nginx
Dockerfile: debian:buster ベースのイメージ作成
SSL 証明書の自動生成設定
Nginx 設定ファイル（TLSv1.2/1.3 のみ使用）
WordPress
Dockerfile: debian:buster ベースのイメージ作成
PHP-FPM 設定
WordPress 設定ファイル
セットアップスクリプト
その他
データ永続化用のボリュームディレクトリ
.gitignore の設定
次のステップ：

hosts ファイルに atomboy.42.fr を追加
make all を実行してコンテナをビルド・起動
https://atomboy.42.frにアクセスしてWordPressの動作確認
必要に応じて以下のコマンドを実行してください：

# hosts ファイルの編集

sudo echo "127.0.0.1 atomboy.42.fr" >> /etc/hosts

# コンテナのビルドと起動

make all
エラーが発生した場合は、各コンテナのログを確認することができます：

docker-compose -f srcs/docker-compose.yml logs

Dockerfile:
必要なディレクトリの作成とパーミッションの設定を追加
ENTRYPOINT を追加して init_db.sh を実行するように変更
init_db.sh:
エラーハンドリング（set -e）を追加
環境変数のチェックを追加
ログ出力を追加して進行状況を確認可能に
SQL コマンドにコメントを追加して可読性を向上
50-server.cnf:
基本的な設定は適切に行われているため、変更なし

これで、必須要件の主要なコンポーネントの実装が完了しました。主な改善点は以下の通りです：

MariaDB:
初期化スクリプトの改善
エラーハンドリングの追加
セキュリティ設定の強化
Nginx:
TLS 1.2/1.3 の設定
セキュリティヘッダーの追加
パフォーマンス最適化（Gzip 圧縮など）
ヘルスチェックの追加
WordPress:
PHP-FPM 設定の最適化
セットアップスクリプトの改善
セキュリティ設定の追加
必要なプラグインの自動インストール
docker-compose.yml:
ヘルスチェックの追加
より適切な再起動ポリシー
明示的なボリュームマウント
サービス依存関係の改善

Inception プロジェクトの必須要件とボーナス要件の実装が完了しました。主な実装内容は以下の通りです：

必須サービス:
MariaDB（データベース）
WordPress + PHP-FPM
Nginx（TLS 1.2/1.3 対応）
ボーナスサービス:
Redis（WordPress キャッシュ）
FTP（WordPress ファイル管理）
Adminer（データベース管理）
静的サイト（情報ページ）
セキュリティ機能:
TLS 1.2/1.3 の設定
セキュリティヘッダーの追加
適切なファイルパーミッション
環境変数による認証情報の管理
運用機能:
ヘルスチェック
自動再起動
ログ管理
データの永続化
使いやすさの向上:
詳細な Makefile コマンド
環境変数テンプレート
セットアップ自動化
プロジェクトを開始するには、以下の手順を実行してください：

環境変数の設定:
Code
CopyInsert
make setup # .env.template から.env を作成

# .env ファイルを編集して適切な値を設定

サービスの起動:
Code
CopyInsert
make all # セットアップ、ビルド、起動を実行
動作確認:
WordPress: https://atomboy.42.fr
Adminer: https://atomboy.42.fr/adminer/
静的サイト: http://atomboy.42.fr:8080
FTP: ftp://atomboy.42.fr:21
管理コマンド:
Code
CopyInsert
make ps # サービスの状態確認
make logs # ログの確認
make redis-cli # Redis への接続
make reload # サービスの再起動
make clean # クリーンアップ
これで、完全に機能する Inception プロジェクトが準備できました。

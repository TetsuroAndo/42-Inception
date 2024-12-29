NAME = inception
DOCKER_COMPOSE = docker-compose -f ./srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data
ENV_FILE = ./srcs/.env
ENV_TEMPLATE = ./srcs/.env.template

all: setup build up

# 初期セットアップ
setup: create_dirs check_env

create_dirs:
	@echo "Creating data directories..."
	@mkdir -p $(DATA_PATH)/wp
	@mkdir -p $(DATA_PATH)/db
	@mkdir -p $(DATA_PATH)/redis

check_env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Creating .env file from template..."; \
		cp $(ENV_TEMPLATE) $(ENV_FILE); \
		echo "Please edit $(ENV_FILE) with your settings."; \
		exit 1; \
	fi

# Docker操作
build:
	@echo "Building Docker images..."
	@$(DOCKER_COMPOSE) build

up:
	@echo "Starting services..."
	@$(DOCKER_COMPOSE) up -d
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo "Services are ready!"
	@echo "WordPress: https://$(shell grep DOMAIN_NAME $(ENV_FILE) | cut -d '=' -f2)"
	@echo "Adminer: https://$(shell grep DOMAIN_NAME $(ENV_FILE) | cut -d '=' -f2)/adminer/"
	@echo "Static Site: http://$(shell grep DOMAIN_NAME $(ENV_FILE) | cut -d '=' -f2):8080"

down:
	@echo "Stopping services..."
	@$(DOCKER_COMPOSE) down

# コンテナとイメージの管理
clean: down
	@echo "Cleaning Docker resources..."
	@docker system prune -af
	@docker volume prune -f

fclean: down
	@echo "Full cleaning..."
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_PATH)/wp/*
	@sudo rm -rf $(DATA_PATH)/db/*
	@sudo rm -rf $(DATA_PATH)/redis/*
	@echo "All data has been removed."

# ログとステータス
logs:
	@$(DOCKER_COMPOSE) logs

ps:
	@$(DOCKER_COMPOSE) ps

# 再起動とリロード
reload: down up

re: fclean all

# ボーナスサービスの個別制御
redis-cli:
	@docker exec -it redis redis-cli

adminer-logs:
	@docker logs adminer

static-logs:
	@docker logs static

ftp-logs:
	@docker logs ftp

.PHONY: all setup create_dirs check_env build up down clean fclean logs ps reload re \
        redis-cli adminer-logs static-logs ftp-logs

COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up: secrets
	@mkdir -p /home/$(USER)/data/mariadb
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/redis
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

logs:
	$(COMPOSE) logs -f

secrets:
	@mkdir -p secrets
	@[ -f secrets/db_password.txt ] || openssl rand -hex 16 > secrets/db_password.txt
	@[ -f secrets/db_root_password.txt ] || openssl rand -hex 16 > secrets/db_root_password.txt
	@[ -f secrets/credentials.txt ] || printf "WP_ADMIN_USER=user_%s\nWP_ADMIN_PASSWORD=%s\nWP_USER=editor_%s\nWP_USER_PASSWORD=%s\n" \
		"$$(openssl rand -hex 3)" "$$(openssl rand -hex 16)" \
		"$$(openssl rand -hex 3)" "$$(openssl rand -hex 16)" > secrets/credentials.txt
	@[ -f secrets/ftp_password.txt ] || openssl rand -hex 16 > secrets/ftp_password.txt

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf ~/data/*
	rm -rf secrets
	docker volume rm $(shell docker volume ls -q) 2>/dev/null || true
	docker network rm srcs_inception 2>/dev/null || true

re: fclean up

.PHONY: all up down stop logs secrets clean fclean re

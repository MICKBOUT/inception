COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up: secrets
	@mkdir -p /home/$(USER)/data/mariadb
	@mkdir -p /home/$(USER)/data/nginx
	@mkdir -p /home/$(USER)/data/wordpress
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

logs:
	$(COMPOSE) logs -f

# test just mariadb alone, without starting wordpress/nginx
# mariadb:
# 	mkdir -p /home/$(USER)/data/mariadb
# 	$(COMPOSE) up --build mariadb -d
# 	$(COMPOSE) logs -f mariadb

secrets:
	@mkdir -p secrets
	@[ -f secrets/db_password.txt ] || openssl rand -hex 16 > secrets/db_password.txt
	@[ -f secrets/db_root_password.txt ] || openssl rand -hex 16 > secrets/db_root_password.txt
	@[ -f secrets/credentials.txt ] || printf "WP_ADMIN_USER=user_%s\nWP_ADMIN_PASSWORD=%s\nWP_USER=editor_%s\nWP_USER_PASSWORD=%s\n" \
		"$$(openssl rand -hex 3)" "$$(openssl rand -hex 16)" \
		"$$(openssl rand -hex 3)" "$$(openssl rand -hex 16)" > secrets/credentials.txt
clean: down
	docker system prune -af

fclean: clean
	docker volume rm srcs_db_data srcs_wp_data 2>/dev/null || true
	docker network rm srcs_inception 2>/dev/null || true

re: fclean up

.PHONY: all up down stop logs secrets clean fclean re

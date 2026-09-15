secrets:
	@mkdir -p secrets
	@[ -f secrets/credentials.txt ] || printf "WP_ADMIN_USER=user_%s\nWP_ADMIN_PASSWORD=%s\n" "$$(openssl rand -hex 3)" "$$(openssl rand -base64 12)" > secrets/credentials.txt
	@[ -f secrets/db_password.txt ] || openssl rand -hex 16 > secrets/db_password.txt
	@[ -f secrets/db_root_password.txt ] || openssl rand -hex 16 > secrets/db_root_password.txt

# up: secrets
# 	docker compose -f srcs/docker-compose.yml up --build -d
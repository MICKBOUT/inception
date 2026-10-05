FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    php-cli \
    php-mysqli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN curl -fsSL https://www.adminer.org/latest.php -o adminer.php
COPY conf/index.php /var/www/html/index.php

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["entrypoint.sh"]
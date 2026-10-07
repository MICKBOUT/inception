FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY conf/index.html conf/favicon.ico conf/style.css .

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
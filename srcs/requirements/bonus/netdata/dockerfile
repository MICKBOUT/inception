FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    netdata

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["entrypoint.sh"]

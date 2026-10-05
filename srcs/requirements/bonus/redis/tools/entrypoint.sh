#!/bin/sh
set -e

mkdir -p /data
chown -R redis:redis /data

exec redis-server /etc/redis/redis.conf \
	--bind 0.0.0.0 \
	--protected-mode no \
	--daemonize no \
	--dir /data \
	--appendonly yes

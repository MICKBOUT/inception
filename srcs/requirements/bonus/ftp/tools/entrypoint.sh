#!/bin/sh
set -eu

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# Use the same Unix identity as PHP-FPM so FTP edits retain WordPress ownership.
echo "www-data:${FTP_PASSWORD}" | chpasswd
echo /usr/sbin/nologin >> /etc/shells
mkdir -p /var/run/vsftpd/empty /var/www/html

if [ -n "${FTP_PASV_ADDRESS:-}" ]; then
	printf '\npasv_address=%s\n' "${FTP_PASV_ADDRESS}" >> /etc/vsftpd.conf
fi

exec /usr/sbin/vsftpd /etc/vsftpd.conf

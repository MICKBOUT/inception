# User documentation

This guide covers using the Inception services after the project has been started. The normal website entry point is NGINX over HTTPS. The additional bonus services have their own published ports.

## Services

| Service | Purpose | Access |
| --- | --- | --- |
| NGINX | HTTPS entry point and reverse proxy for WordPress | `https://mboutte.42.fr` (port 443) |
| WordPress / PHP-FPM | Website and PHP application runtime | Through NGINX; PHP-FPM is internal on port 9000 |
| MariaDB | WordPress database | Internal to the Compose network on port 3306 |
| Redis | WordPress object cache | Internal to the Compose network on port 6379; host port 6379 is also published |
| Adminer | Browser-based database administration | `http://localhost:8080` |
| FTP | File transfer access to the WordPress files | Port 21 plus passive ports 30000–30009 |
| Static website | Standalone static bonus site | `http://localhost:4242` |
| Netdata | System and container monitoring dashboard | `http://localhost:19999` |

For access from another computer, replace `localhost` with the virtual machine's IP address. FTP passive mode also requires the configured passive address to be reachable from the FTP client; set `FTP_PASV_ADDRESS` to the VM's reachable IP before starting the stack when connecting remotely.

## Start and stop

From the project root, build and start the services with the Make target:

```sh
make up
```

Stop and remove the containers and Compose network while retaining persistent data with:

```sh
make down
```

To stop containers without removing them, use `make stop`. Run `make up` to build and start the stack again.

## Website and administration

The configured main website is `https://mboutte.42.fr`. This domain must resolve to the machine running Docker. For local testing, add `127.0.0.1 mboutte.42.fr` to `/etc/hosts` on the browser's machine if Docker runs locally; when Docker runs in a VM, map the domain to the VM's IP instead. NGINX generates a self-signed certificate, so the browser will display a certificate warning. The domain is configured in `srcs/.env`; changing it also requires matching the NGINX server name and certificate subject.

The WordPress login page is `https://mboutte.42.fr/wp-login.php`. WordPress creates one administrator and one author account on the first installation. Their usernames and passwords are generated and stored in `secrets/credentials.txt`.

Adminer is available at `http://localhost:8080`. Select **MySQL** as the system, use `mariadb` for the server, `wp_user` for the username, `wordpress` for the database, and the password from `secrets/db_password.txt`.

The static bonus page is served at `http://localhost:4242`. Netdata is at `http://localhost:19999`. Both use HTTP.

## Mariadb database

There are multiple way to acces the mariadb database, the first one is my using `docker exec -it mariadb`. For exemple, the following command allow you to see the table in the database:
```sh
docker exec -it mariadb mysql -u root -p"$(cat secrets/db_root_password.txt)" -e "SHOW DATABASES;"
``` 
You can also acces it by using adminer on [localhost:8080](http://localhost:8080/) with:
- server: `mariadb`
- username: `wp_user`
- password: `db_root_password`
- database: `wordpress`

## Netdata

Netdata allow you to monitor the vm via a simple website, you can see the site at [localhost:19999](http://localhost:19999).

## Website
My website is accesible at [localhost:4242](http://localhost:4242).

## Credentials

The Makefile creates these files under the repository's root `secrets/` directory if they do not already exist:

- `credentials.txt`: WordPress administrator and author usernames/passwords.
- `db_password.txt`: MariaDB application user password, also used by WordPress and Adminer.
- `db_root_password.txt`: MariaDB root password.
- `ftp_password.txt`: password for the FTP account.

The FTP username is `www-data`; it accesses the shared WordPress files. Keep the secrets directory private and do not commit or share its contents. `srcs/.env` contains non-secret settings such as the domain and database name/user. You can use this commande to connect to the ftp serv: 
```sh
ftp -P 21 www-data@localhost
```
## Check service health

Show service status (there is no Make target for this):

```sh
docker compose -f srcs/docker-compose.yml ps
```

Follow all service logs with the Make target:

```sh
make logs
```

To follow one service's logs, use Compose because the Make target does not accept a service name:

```sh
docker compose -f srcs/docker-compose.yml logs -f wordpress
```

The main site should load over HTTPS, and the browser should show the expected self-signed certificate warning. If a service is not running, inspect its logs for database connection, missing secret, or configuration errors.

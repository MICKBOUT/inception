*This project has been created as part of the 42 curriculum by mboutte.*

# Inception

## Description

Inception is a system administration project that builds a small web infrastructure with Docker Compose. Each service is built from its own Dockerfile and runs in a dedicated container on the `inception` bridge network. The main site is WordPress served by PHP-FPM and MariaDB, with NGINX providing HTTPS.

## Project description

The project uses Docker to package and connect its services. Dockerfiles and runtime configuration are under `srcs/requirements/`; `srcs/docker-compose.yml` describes the containers, network, ports, secrets, and persistent storage. The required stack is MariaDB, WordPress with PHP-FPM, and NGINX. Bonus services add Redis, FTP, Adminer, a static website, and Netdata.

The main design choices are:

- Debian Bookworm slim is the base for the service images, and packages are installed in project-owned Dockerfiles.
- NGINX terminates TLS with TLS 1.2 and TLS 1.3 enabled. Its certificate is generated as a self-signed certificate when the container starts.
- WordPress connects to MariaDB and Redis using Compose service names on the private bridge network.
- MariaDB, WordPress, and Redis data are stored in named Docker volumes backed by directories under `/home/<current-user>/data`. The current shell user's `USER` environment variable supplies the home-directory name (normally the same value returned by `whoami`).
- Passwords are generated locally by the Makefile into files under the root `secrets/` directory and are provided to relevant containers using Docker secrets. Non-secret configuration, including the domain and database name/user, is in `srcs/.env`.
- Compose publishes port 443 for the main site. The bonus services also publish their own ports for direct access (documented in [USER_DOC.md](USER_DOC.md)).

### Virtual machines and Docker

A virtual machine emulates a complete computer and runs its own guest operating system and kernel. Docker containers isolate applications while sharing the host kernel, so they are typically lighter and faster to start. This project is intended to run inside a virtual machine, with its individual services separated into containers.

### Secrets and environment variables

Environment variables are useful for non-sensitive settings such as a domain name or database name, but they can be exposed through process and container inspection. Docker secrets provide sensitive values as files mounted into the containers. This project keeps passwords in local files under `secrets/` and references them as Docker secrets; keep that directory private and out of version control.

### Docker bridge network and host network

The Compose bridge network gives each service a private network identity. Services can reach one another by Compose service name, such as `wordpress` connecting to `mariadb:3306`. Host networking would share the host network namespace and reduce isolation; this project uses a bridge network and explicitly publishes the ports needed for access.

### Docker volumes and bind mounts

A named volume is managed by Docker and persists beyond an individual container's lifetime. A bind mount maps a specific host path directly into a container and depends on that path existing on the host. Here `db_data`, `wp_data`, and `rds_data` are named volumes configured with the local driver to store their data under `/home/<current-user>/data/mariadb`, `/home/<current-user>/data/wordpress`, and `/home/<current-user>/data/redis`, respectively. The current user's name is supplied by the shell's `USER` variable, which normally matches `whoami`.

## Instructions

### Prerequisites

- A Linux virtual machine with Docker Engine and the Docker Compose plugin.
- GNU Make and OpenSSL.
- A Linux account with a home directory under `/home/` and the usual `USER` environment variable set for that account.

### Configure and start

1. The configured site domain is `mboutte.42.fr` (`srcs/.env`). Point it at the virtual machine's IP address. For a local setup where Docker runs on the same machine, add this to `/etc/hosts`; use the VM's IP instead of `127.0.0.1` when Docker runs in a separate VM:

   ```text
   127.0.0.1 mboutte.42.fr
   ```

2. From the repository root, run the Make target to create missing secrets and data directories, build the images, and start the stack:

   ```sh
   make up
   ```

   The `secrets` Make target creates missing random credential files. The `up` target creates the host data directories, builds the images, and starts the containers.

3. Open `https://mboutte.42.fr`. The generated TLS certificate is self-signed, so a browser security warning is expected unless you configure a trusted certificate. If you change the site domain, update `srcs/.env` and the NGINX server name and certificate subject to match.

### Service access

The Compose configuration publishes these bonus service ports on the Docker host. Use `localhost` when your browser/client runs on the Docker host; from another machine, replace it with the VM's IP address.

| Service | Address / command |
| --- | --- |
| WordPress site | `https://mboutte.42.fr` (port 443; configure the domain to resolve to the Docker host) |
| Adminer | `http://localhost:8080` |
| Static website | `http://localhost:4242` |
| Netdata | `http://localhost:19999` (Netdata listens on `0.0.0.0:19999` inside the container) |
| FTP | `ftp localhost` (or `ftp <VM-IP>` remotely; port 21) |

For FTP, log in as `www-data`; the password is in `secrets/ftp_password.txt`. FTP passive mode uses ports 30000–30009. For access from another machine, configure `FTP_PASV_ADDRESS` to the VM's reachable IP before starting the stack. WordPress administrator and author credentials are in `secrets/credentials.txt`.

See [USER_DOC.md](USER_DOC.md) for service URLs, credentials, and routine operation. See [DEV_DOC.md](DEV_DOC.md) for setup details and container/storage management commands.

## Resources

- [Docker Engine documentation](https://docs.docker.com/engine/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker storage documentation](https://docs.docker.com/engine/storage/)
- [Docker networking documentation](https://docs.docker.com/engine/network/)
- [Docker secrets documentation](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Redis documentation](https://redis.io/docs/latest/)
- [Adminer](https://www.adminer.org/)

## Ai Usage

AI assistance was used to draft these project documents. The project maintainer has verify the instructions against the running environment and is able to explain the implementation.

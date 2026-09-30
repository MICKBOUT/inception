docker installed
user in a docker groups
scripte use the /home/user on any machine, no need to edit

use this commande to map,
sudo sh -c 'echo "127.0.0.1 mboutte.42.fr" >> /etc/hosts'

https://mboutte.42.fr insted of mboutte.42.fr bc the browser asume http protocol for arbitrary domain names


show mariadb info:
docker
  exec -it mariadb \                                                  
  mysql -u root -p"$(cat secrets/db_root_password.txt)" \
  -e "SHOW DATABASES;"
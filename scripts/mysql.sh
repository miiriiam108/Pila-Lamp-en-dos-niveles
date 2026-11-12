#!/bin/bash

# Para que apt no haga preguntas
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizamos paquetes e instalamos el servidor de base de datos
apt-get update
apt-get install -y mariadb-server

# 2. Le decimos que escuche en todas las tarjetas de red, no solo en local
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# 3. Lo activamos al arrancar y lo reiniciamos para que coja el cambio
systemctl enable mariadb
systemctl restart mariadb

# 4. Creamos la base de datos y el usuario para la app
mysql <<EOF
CREATE DATABASE IF NOT EXISTS lamp_db CHARSET utf8mb4;
CREATE USER IF NOT EXISTS 'appuser'@'192.168.10.10' IDENTIFIED BY 'appuser123';
GRANT ALL PRIVILEGES ON lamp_db.* TO 'appuser'@'192.168.10.10';
FLUSH PRIVILEGES;
EOF

# 5. Creamos la tabla de usuarios con el script de la app
mysql lamp_db < /vagrant/app/db/database.sql
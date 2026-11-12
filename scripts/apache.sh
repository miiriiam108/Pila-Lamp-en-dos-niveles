#!/bin/bash

# Para que apt no nos haga preguntas
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizamos la lista de paquetes
apt-get update

# 2. Instalamos Apache, PHP y el conector de PHP con MySQL
apt-get install -y apache2 php libapache2-mod-php php-mysql

# 3. Arrancamos Apache y que arranque solo al encender la máquina
systemctl enable apache2
systemctl restart apache2

# 4. Borramos la página de prueba que trae Apache
rm -f /var/www/html/index.html

# 5. Copiamos la app (la carpeta src) a la carpeta web
cp -r /vagrant/app/src/* /var/www/html/

# 6. Damos los permisos a Apache sobre los ficheros
chown -R www-data:www-data /var/www/html
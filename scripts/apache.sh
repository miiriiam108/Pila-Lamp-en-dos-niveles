#!/bin/bash

# Para que apt no nos haga preguntas (el script va solo, nadie puede contestar)
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizamos la lista de paquetes
apt-get update

# 2. Instalamos Apache, PHP y el conector de PHP con MySQL
apt-get install -y apache2 php libapache2-mod-php php-mysql

# 3. Hacemos que Apache arranque solo al encender la máquina, y lo arrancamos ya
systemctl enable apache2
systemctl restart apache2

# 4. Borramos la página de prueba que trae Apache
rm -f /var/www/html/index.html
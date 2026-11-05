#!/bin/bash

# Evitamos que aparezcan ventanas interactivas durante la instalación de paquetes
export DEBIAN_FRONTEND=noninteractive

# Actualizamos la lista de paquetes del sistema
apt-get update

# Instalamos el servidor web Apache, PHP, y los módulos necesarios para conectar PHP con MySQL
apt-get install -y apache2 php libapache2-mod-php php-mysql curl

# Reiniciamos el servicio de Apache para asegurarnos de que carga todos los módulos correctamente
systemctl restart apache2

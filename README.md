# Pila LAMP en dos niveles

Práctica de IAW: montar una infraestructura de **dos niveles** con Vagrant y
desplegar una aplicación de gestión de usuarios.

- **Nivel 1:** máquina con Apache + PHP (`MiriamPorroApache`). Es la única con Internet.
- **Nivel 2:** máquina con MariaDB (`MiriamPorroMysql`). No tiene Internet.

Las dos se hablan por una red interna. Desde mi PC entro a la web por
`http://localhost:8080` (reenvío de puertos).

## 1. Preparar el entorno

### 1.1 Comprobar la box de Debian 12

Lo primero que hice fue mirar si ya tenía la box de Debian 12 descargada en el
ordenador. Con `vagrant box list` salen todas las que tengo

![Captura 1](img/Captura%20de%20pantalla%202026-11-12%20090453.png)

### 1.2 Validar el Vagrantfile

Antes de encender nada, comprobé que el Vagrantfile estaba bien escrito con
`vagrant validate`. Sale "validated successfully", así que todo correcto.

![Captura 2](img/Captura%20de%20pantalla%202026-11-12%20090548.png)


## 2. El Vagrantfile

```ruby
Vagrant.configure("2") do |config|

  config.vm.box = "debian/bookworm64"

  # ---------- MÁQUINA MYSQL (nivel 2, sin Internet) ----------
  config.vm.define "mysql" do |mysql|
    mysql.vm.hostname = "MiriamPorroMysql"

    mysql.vm.network "private_network",
      ip: "192.168.10.11",
      virtualbox__intnet: "redinterna"

    mysql.vm.provision "shell", path: "scripts/mysql.sh"

    mysql.vm.provision "shell", run: "always",
      inline: "ip route del default || true"
  end

  # ---------- MÁQUINA APACHE (nivel 1, con Internet) ----------
  config.vm.define "apache" do |apache|
    apache.vm.hostname = "MiriamPorroApache"

    apache.vm.network "forwarded_port", guest: 80, host: 8080

    apache.vm.network "private_network",
      ip: "192.168.10.10",
      virtualbox__intnet: "redinterna"

    apache.vm.provision "shell", path: "scripts/apache.sh"
  end

end
```

### Qué hace cada cosa

- `config.vm.box = "debian/bookworm64"`: las dos máquinas usan Debian 12.
- `config.vm.define "mysql"` y `"apache"`: así Vagrant sabe que son dos
  máquinas distintas.
- `vm.hostname`: el nombre de la máquina por dentro, con mi nombre como pide
  la tarea.
- `private_network` + `virtualbox__intnet`: la red interna que comparten las
  dos. Apache es `192.168.10.10` y MySQL es `192.168.10.11`.
- `forwarded_port`: lo que llega al puerto 8080 de mi PC va al puerto 80 de
  Apache. Por eso la web se ve en `localhost:8080`.
- `provision "shell", path: ...`: ejecuta mi script de bash al crear la máquina.
- `ip route del default`: borra la "puerta de salida" a Internet de la
  máquina MySQL. Vagrant le pone una tarjeta NAT siempre (la necesita para
  el SSH), así que hay que quitarle la ruta para que se quede sin Internet.
  Va con `run: "always"` para que se repita en cada arranque.
- MySQL va **primero** a propósito: necesita Internet para instalarse y la
  ruta se borra justo después.

---

## 3. Scripts de aprovisionamiento

### 3.1 `scripts/mysql.sh`

```bash
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y mariadb-server

sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl enable mariadb
systemctl restart mariadb

mysql <<EOF
CREATE DATABASE IF NOT EXISTS lamp_db CHARSET utf8mb4;
CREATE USER IF NOT EXISTS 'appuser'@'192.168.10.10' IDENTIFIED BY 'appuser123';
GRANT ALL PRIVILEGES ON lamp_db.* TO 'appuser'@'192.168.10.10';
FLUSH PRIVILEGES;
EOF

mysql lamp_db < /vagrant/app/db/database.sql
```

Qué hace cada orden:

- `export DEBIAN_FRONTEND=noninteractive`: para que `apt` no se quede esperando
  a que alguien pulse una tecla.
- `apt-get update`: refresca la lista de paquetes.
- `apt-get install -y mariadb-server`: instala la base de datos. En Debian 12
  no existe `mysql-server`, se usa MariaDB, que funciona igual.
- `sed -i ... bind-address`: por defecto la base de datos solo se escucha a sí
  misma (`127.0.0.1`). Lo cambio a `0.0.0.0` para que acepte conexiones de la
  máquina Apache.
- `systemctl enable` / `restart`: que arranque sola al encender la máquina y
  que coja el cambio de configuración.
- `mysql <<EOF ... EOF`: todo lo de dentro se lo mando a MariaDB:
  - `CREATE DATABASE`: crea la base `lamp_db`.
  - `CREATE USER ... @'192.168.10.10'`: crea el usuario `appuser`, que solo
    puede entrar desde la máquina Apache.
  - `GRANT ALL PRIVILEGES`: le da permisos solo sobre `lamp_db`.
  - `FLUSH PRIVILEGES`: recarga los permisos.
- `mysql lamp_db < /vagrant/app/db/database.sql`: crea la tabla `users` con el
  SQL de la app. La carpeta `/vagrant` es mi carpeta del proyecto, que Vagrant
  comparte dentro de la máquina.

### 3.2 `scripts/apache.sh`

```bash
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql

systemctl enable apache2
systemctl restart apache2

rm -f /var/www/html/index.html

cp -r /vagrant/app/src/* /var/www/html/

chown -R www-data:www-data /var/www/html
```

Qué hace cada orden:

- `apt-get update` y `export ...`: igual que en el otro script.
- `apt-get install -y apache2 php libapache2-mod-php php-mysql`: instala el
  servidor web, PHP, el módulo para que Apache ejecute PHP y el conector
  para que PHP hable con MySQL.
- `systemctl enable` / `restart`: Apache arranca solo y se reinicia ya.
- `rm -f /var/www/html/index.html`: quita la página de prueba de Apache para
  que no tape mi app.
- `cp -r /vagrant/app/src/* /var/www/html/`: copia el código de la app a la
  carpeta que sirve Apache.
- `chown -R www-data:www-data`: el usuario de Apache pasa a ser el dueño de
  los ficheros.

---

## 4. Levantar las máquinas

### 4.1 Subir a GitHub y `vagrant up`

Con el `git push` subo mis ficheros a GitHub (la línea final `main -> main`
significa que llegó todo). Después lanzo `vagrant up`, que crea las dos
máquinas: primero `mysql` y luego `apache`.

![Captura 3](img/Captura%20de%20pantalla%202026-11-12%20090826.png)

### 4.2 Máquinas arrancadas

Con `vagrant status` compruebo que las dos están en `running`.

![Captura 4](img/Captura%20de%20pantalla%202026-11-12%20091858.png)

---

## 5. Comprobar cada servidor

### 5.1 Máquina Apache

Entro con `vagrant ssh apache`. Con `hostname` compruebo que se llama
`MiriamPorroApache` y con `systemctl status apache2` que Apache está
`active (running)`.

![Captura 5](img/Captura%20de%20pantalla%202026-11-12%20092135.png)

### 5.2 Máquina MySQL

Entro con `vagrant ssh mysql`. Con `hostname` veo `MiriamPorroMysql` y con
`systemctl status mariadb` que la base de datos está `active (running)`.

![Captura 6](img/Captura%20de%20pantalla%202026-11-12%20102309.png)

---

## 6. Comprobar el acceso a Internet

Solo la máquina Apache está conectada a Internet por NAT. Se nota haciendo
`ping google.com`: en Apache funciona y en MySQL falla.

**Apache (con Internet):**

![Captura 7](img/Captura%20de%20pantalla%202026-11-13%20093334.png)

**MySQL (sin Internet):**

![Captura 8](img/Captura%20de%20pantalla%202026-11-12%20102654.png)

### 6.1 Conexión entre  máquinas
Aunque MySQL no tiene Internet, sí está conectada con Apache por la red
interna. Desde `MiriamPorroApache` hice un `ping` a la IP de MySQL
(`192.168.10.11`) y responde.
Así que la máquina de la base de datos está aislada de Internet, pero
Apache puede hablar con ella, que es justo lo que necesitamos para los
dos niveles.

![Captura ping](img/Captura%20de%20pantalla%202026-11-13%20193006.png)

## 7. La aplicación

### 7.1 Ajustes que hice para que funcionara

La app (gestión de usuarios en PHP) no funcionaba tal cual, así que toqué esto:

- **`app/src/config.php`**: venía con `localhost` y datos de relleno. Como la
  base de datos está en otra máquina, puse la IP de MySQL y los datos reales:

```php
define('DB_HOST', '192.168.10.11');
define('DB_NAME', 'lamp_db');
define('DB_USER', 'appuser');
define('DB_PASSWORD', 'appuser123');
```

- **`mysql.sh`**: He añadidio la creación de la base `lamp_db`, el usuario
  `appuser` y la carga del `database.sql` para crear la tabla `users`.
- **`apache.sh`**: He añadido que copie el código de `app/src` a `/var/www/html`.

  ![Captura 9](img/Captura%20de%20pantalla%202026-11-12%20104849.png)

  ### 7.2 La app funcionando

  Abro `http://localhost:8080` en el navegador.

  Al darle a **Add New Data** sale el formulario para crear un usuario.

  ![Captura 10](img/Captura%20de%20pantalla%202026-11-12%20110339.png)

  Después de crear un usuario aparece en la tabla.

  ![Captura 11](img/Captura%20de%20pantalla%202026-11-12%20104925.png)

  ### 7.3 Los datos están en la máquina MySQL

Para comprobar que se guarda de verdad en la otra máquina, entré en
`MiriamPorroMysql` y ejecuté
`sudo mysql -e "SELECT * FROM lamp_db.users;"`. Sale el usuario que creé
desde el navegador, así que la web (Apache) y la base de datos (MySQL) se
hablan bien por la red interna.

  ![Captura 12](img/Captura%20de%20pantalla%202026-11-12%20105027.png)

 ## 8. Screencast

En este vídeo se ve la aplicación funcionando: arranco las máquinas, abro la
web, añado un usuario, lo edito y lo borro.

[Ver screencast](screencast/screencast.mp4)

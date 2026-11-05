# Pila-Lamp-en-dos-niveles

##  Descripción de la Práctica
El objetivo de esta práctica es el despliegue de una arquitectura web en **dos niveles** utilizando virtualización con Vagrant y el sistema operativo **Debian 12 (Bookworm)**. La arquitectura separa los servicios en máquinas virtuales independientes.


##  1. Arquitectura de la Infraestructura y Redes

1. **`MiriamPorroApache`** (Servidor Web):
   - **Interfaz 1 (NAT)**: Permite la conexión a Internet exclusivamente a esta máquina para la descarga e instalación de paquetes mediante `apt`.
   - **Interfaz 2 (Red Privada)**: IP estática `192.168.56.10` para comunicarse de forma segura con el servidor de base de datos.
   - **Port Forwarding**: Reenvío del puerto `8080` de la máquina anfitriona al puerto `80` de la máquina virtual para acceder a la aplicación web.

2. **`MiriamPorroMysql`** (Servidor de Base de Datos):
   - **Aislamiento Total**: Se desactiva explícitamente la interfaz NAT (`--nic2 none`), garantizando que **no tenga ningún tipo de acceso a Internet**.
   - **Red Privada**: IP estática `192.168.56.20` dentro del mismo segmento de red que el servidor web.



##  2. Fichero de Configuración (`Vagrantfile`)

El fichero `Vagrantfile` automatiza la creación, direccionamiento IP y aprovisionamiento de ambos nodos:


Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # 1. MÁQUINA APACHE (Con acceso a Internet y Port Forwarding)
  config.vm.define "MiriamPorrozApache" do |apache|
    apache.vm.hostname = "MiriamPorrozApache"
    apache.vm.network "private_network", ip: "192.168.56.10"
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    apache.vm.provision "shell", path: "provision-apache.sh"
  end

  # 2. MÁQUINA MYSQL (Aislada de Internet)
  config.vm.define "MiriamPorrozMysql" do |mysql|
    mysql.vm.hostname = "MiriamPorrozMysql"
    mysql.vm.network "private_network", ip: "192.168.56.20"
    
    # Desactivamos la interfaz NAT para bloquear el acceso a Internet
    mysql.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--nic2", "none"]
    end
    
    mysql.vm.provision "shell", path: "provision-mysql.sh"
  end
end

###


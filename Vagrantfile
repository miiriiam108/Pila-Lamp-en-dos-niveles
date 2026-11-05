Vagrant.configure("2") do |config|
  # Usamos la caja oficial de Debian 12 (Bookworm)
  config.vm.box = "debian/bookworm64"

  # ==========================================
  # 1. MÁQUINA APACHE (Con acceso a Internet y Port Forwarding)
  # ==========================================
  config.vm.define "MiriamPorroApache" do |apache|
    apache.vm.hostname = "MiriamPorroApache"
    
    # Red privada interna para comunicarse con la base de datos
    apache.vm.network "private_network", ip: "192.168.56.10"
    
    # Reenvío de puertos: tu máquina host accede por el puerto 8080 al puerto 80 del servidor web
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    
    # Provisionamiento mediante script Bash externo
    apache.vm.provision "shell", path: "provision-apache.sh"
  end

  # ==========================================
  # 2. MÁQUINA MYSQL (AISLADA de Internet)
  # ==========================================
  config.vm.define "MiriamPorrozMysql" do |mysql|
    mysql.vm.hostname = "MiriamPorrozMysql"
    
    # Red privada interna con IP fija dentro del mismo rango
    mysql.vm.network "private_network", ip: "192.168.56.20"
    
    # IMPORTANTE: Desactivamos la interfaz NAT por defecto para garantizar 
    # que esta máquina NO tenga ningún tipo de acceso a Internet.
    mysql.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--nic2", "none"]
    end
    
    # Provisionamiento mediante script Bash externo
    mysql.vm.provision "shell", path: "provision-mysql.sh"
  end
end

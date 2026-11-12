Vagrant.configure("2") do |config|

  # La box de Debian 12 para las dos máquinas
  config.vm.box = "debian/bookworm64"

  # ---------- MÁQUINA MYSQL (nivel 2, sin Internet) ----------
  config.vm.define "mysql" do |mysql|
    mysql.vm.hostname = "MiriamPorroMysql"

    # Red interna: solo se ven entre las dos máquinas
    mysql.vm.network "private_network",
      ip: "192.168.10.11",
      virtualbox__intnet: "redinterna"

    # Primero instala todo (aún con Internet)
    mysql.vm.provision "shell", path: "scripts/mysql.sh"

    # Después le quitamos la salida a Internet (y en cada arranque)
    mysql.vm.provision "shell", run: "always",
      inline: "ip route del default || true"
  end

  # ---------- MÁQUINA APACHE (nivel 1, con Internet) ----------
  config.vm.define "apache" do |apache|
    apache.vm.hostname = "MiriamPorroApache"

    # Reenvío de puertos: localhost:8080 de tu PC -> puerto 80 de la máquina
    apache.vm.network "forwarded_port", guest: 80, host: 8080

    # Misma red interna que MySQL
    apache.vm.network "private_network",
      ip: "192.168.10.10",
      virtualbox__intnet: "redinterna"

    apache.vm.provision "shell", path: "scripts/apache.sh"
  end

end
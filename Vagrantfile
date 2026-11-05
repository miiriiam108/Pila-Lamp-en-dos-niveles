Vagrant.configure("2") do |config|

  # Máquina Apache
  config.vm.define "apache" do |apache|
    apache.vm.box = "debian/bookworm64"

    apache.vm.hostname = "MiriamPorroApache"

    apache.vm.network "private_network", ip: "192.168.56.10"

    apache.vm.network "forwarded_port",
                      guest: 80,
                      host: 8080

    apache.vm.provision "shell",
                        path: "apache.sh"
  end

  # Máquina MariaDB
  config.vm.define "mysql" do |mysql|
    mysql.vm.box = "debian/bookworm64"

    mysql.vm.hostname = "MiriamPorroMysql"

    mysql.vm.network "private_network", ip: "192.168.56.11"

    mysql.vm.provision "shell",
                       path: "mysql.sh"
  end

end

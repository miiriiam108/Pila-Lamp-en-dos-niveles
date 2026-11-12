# Pila-Lamp-en-dos-niveles


### Comprobar la box de Debian 12 

Lo primero que hice fue mirar si ya tenía la box de Debian 12 descargada en el
ordenador. Con `vagrant box list`

![Captura 1](img/Captura%20de%20pantalla%202026-11-12%20090453.png)

### Validar el vagrantfile

Antes de encender nada, he comprobado que el Vagrantfile estaba bien escrito con
`vagrant validate`.

![Captura 2](img/Captura%20de%20pantalla%202026-11-12%20090548.png)


### 3. Subir a GitHub y encender las máquinas

 el `git push` que sube mis ficheros a GitHub: la línea final (`main -> main`) significa que todo llegó bien. Luego levanto las máquinas con `vagrant up`

 ![Captura 3](img/Captura%20de%20pantalla%202026-11-12%20090826.png)


 ### 4. Máquinas arrancadas

  ![Captura 4](img/Captura%20de%20pantalla%202026-11-12%20091858.png)

  ### 5. Entramos en Apache

Para entrar ejecuto el comando: `vagrant ssh apache`. He comprobado el nombre con `hostname` y el estado con `systemctl status apache2`

  ![Captura 5](img/Captura%20de%20pantalla%202026-11-12%20092135.png)


  ### 6. Entramos en Mysql


  ![Captura 6](img/Captura%20de%20pantalla%202026-11-12%20102309.png)


  ### 7. Conexiones a internet

Como podemos observar la maquina apache si tiene internet y la de mysql no, esto es porque sólo la máquina apache está conectada a NAT

  ![Captura 7](img/Captura%20de%20pantalla%202026-11-12%20093334.png)
  ![Captura 8](img/Captura%20de%20pantalla%202026-11-12%20102654.png)


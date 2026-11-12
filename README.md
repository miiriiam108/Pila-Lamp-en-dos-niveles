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

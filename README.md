# Pila-Lamp-en-dos-niveles


### Comprobar la box de Debian 12 

Lo primero que hice fue mirar si ya tenía la box de Debian 12 descargada en el
ordenador. Con `vagrant box list`

![Captura 1](img/Captura%20de%20pantalla%202026-10-07%20090453.png)

### Validar el vagrantfile

Antes de encender nada, he comprobado que el Vagrantfile estaba bien escrito con
`vagrant validate`.

![Captura 2](img/Captura%20de%20pantalla%202026-10-07%20090548.png)


### 3. Subir a GitHub y encender las máquinas

 el `git push` que sube mis ficheros a GitHub: la línea final (`main -> main`) significa que todo llegó bien. Luego levanto las máquinas con `vagrant up`

 ![Captura 3](img/Captura%20de%20pantalla%202026-10-07%20090826.png)

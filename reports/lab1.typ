#import "template.typ": *
#show: lab.with(n: 1)

= Настройка хоста

В качестве хоста будет использоваться Manjaro:

#pic(img: "lab1/neofetch.png")[Запуск neofetch на хосте]

== VirtualBox

Для установки VirtualBox будет использован пакетный менеджер pacman:

#pic(img: "lab1/install_vbox.png")[Установка VirtualBox]

== Vagrant

#pic(img: "lab1/install_vagrant.png")[Установка Vagrant]

Так же следует установить плагин для гостевых дополнений:

#pic(img: "lab1/install_vagrant_vbguest.png")[Установка гостевых дополнений Vagrant]

= Работа с Vagrant

#pic(img: "lab1/vagrant_init.png")[Инициализации директории для работы с Vagrant]

== Первый запуск

Для того что бы `vagrant up` мог сам скачать виртульную машину первый запуск производится с использованием proxychains:

#pic(img: "lab1/vagrant_first_up.png")[Первый запуск vagrant up (прерван)]

Можно убедится, что запуск машины успешно прерван:

#pic(img: "lab1/vagrant_first_status.png")[vagrant status]

Последующие запуски будут производиться без proxychains. 

Из-за того, что используется VirtualBox 7.10, в консоль будет выведено следующее предупреждение:
```
$ vagrant up
...
Installing Virtualbox Guest Additions 7.0.10 - guest version is 6.0.0
...
An error occurred during installation of VirtualBox Guest Additions 7.0.10. Some functionality may not work as intended.
In most cases it is OK that the "Window System drivers" installation failed.
...
```

Остановить и удалить машину можно при помощи vagrant destroy:

#pic(img: "lab1/vagrant_destroy.png")[vagrant destroy]

== Настройка Vagrantfile

Для выполнения условий лабораторной следует добавить следующие строчки в Vagrantfile:
```rb
...
config.vm.hostname = "ubuntu-docker"
...
config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.check_guest_additions = false
end
```

Так же будет полезно отключить обновления:
```rb
...
config.vm.box_check_update = false
...
```

И включить аппаратную виртуализацию:
```rb
vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
```

Создание снимка VM:

#pic(img: "lab1/vagrant_snap_initial.png")[Создание снимка VM]

Подключение к виртуальной машине по ssh:

#pic(img: "lab1/vagrant_ssh.png")[Подключение по ssh]

== Установка Docker Engine

Необходимо добавить репозиторий докера:
```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Установка докера (пакетов):
```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Проверка работоспособности:

#pic(img: "lab1/ubuntu_docker_hw.png")[Docker hello-world]

== Создание образа ubuntudocker.box

Упаковка и загрузка в локальный репозиторий:

#pic(img: "lab1/vagrant_pack_and_box.png")[vagrant package и vagrant box]

== Работа со снимками

Создание новой машины:

#pic(img: "lab1/ubuntu_init.png")[Создание новой машины]

Создание снимка виртуальной машины:

#pic(img: "lab1/ubuntu_snap.png")[Создание снимка default]

В качестве примера изменения поставим zig:

#pic(img: "lab1/ubuntu_zig.png")[Создание снимка default]

Восстанавливаем снимок default:

#pic(img: "lab1/ubuntu_restore.png")[Восстановление снимка]

Проверяем, что zig не установлен в системе:

#pic(img: "lab1/ubuntu_nozig.png")[Проверка успешного восстановления]

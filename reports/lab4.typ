#import "template.typ": *
#show: lab.with(n: 4)

= Vagrant

В качестве хоста для контейнера wireguard будет использоваться виртуальная машина `ubuntu/jammy64`.

#pic(img: "lab4/vagrant_cfg.png")[Начальная конфигурация виртуальной машины]

В первую очередь так как мы используем wireguard, то необходимо настроить сеть следующим образом:

#pic(img: "lab4/vagrant_net.png")[Настройка сети виртуальной машины]

Здесь стоит отметить несколько моментов:
- порт 51820 используется для подключений wireguard;
- порт 10086 используется wgdashboard для web-интерфейса;
- используется "public_network" так как необходим доступ в сеть изнутри машины и возможность доступа с нашей машины к виртуальной по сети.

На последок стоит добавить копирование файлов `Dockerfile` и `docker-compose.yaml`:

#pic(img: "lab4/vagrant_files.png")[Копирование Dockerfile и docker-compose.yml]

#pagebreak()

= Dockerfile

Предже всего следует отметить, что наиболее популярный контейнер `linuxserver/wireguard` использует alpine linux, которого нет среди протестированных дистрибутивов для wgdashboard:

#pic(img: "lab4/wgd_req.png")[Необходимые требования wg-dashboard]

Одним из вариантов является использование данного контейнера и доработка его до совместимости с wgdashboard. Однако в данной лабораторной был выбран другой путь: использовать убунту (`ubuntu:20.04`), на которую затем установить сначала wireguard, затем wgdashboard.

== Установка необходимых пакетов

#pic(img: "lab4/dockerfile_1.png")[Установка необходимых пакетов]

Среди них:
- wireguard
- iproute2 - устанавливается ради утилиты ip
- net-tools - ifconfig

А затем производится чистка.

== Генерация конфигурации wireguard

#pic(img: "lab4/dockerfile_2.png")[Генерация конфигурации wireguard]

Для базовой работы wireguard была сгенерирована конфигурация сервера wireguard в автоматическом режиме.

== Установка wgdashboard

#pic(img: "lab4/dockerfile_3.png")[Установка wgdashboard согласно инструкции]

== Открытие портов

#pic(img: "lab4/dockerfile_4.png")[Открытие портов для использования с `-P`]

== `Entrypoint` контейнера

#pic(img: "lab4/dockerfile_5.png")[`Entrypoint` контейнера]

Состоит из следующих частей:
- `wg-quick up wg0` - запуск wireguard с конфигурацией, сгененрированной ранее;
- `cd /usr/local/share/wgdashboard/src && ./wgd.sh start` - запукс wgdashboard согласно инструкции;
- `tail -f /dev/null` - так как оба предыдущих процесса работают "в фоне" необходимо создать основной процесс.

== Сборка и запуск

#pic(img: "lab4/dockerfile_br.png")[Сборка и запуск контейнера]

== Метаданные

#pic(img: "lab4/dockerfile_6.png")[Метаданные]

== Рабочая директория

#pic(img: "lab4/dockerfile_7.png")[Рабочая директория]

== Создание пользователя

#pic(img: "lab4/dockerfile_8.png")[Создание пользователя user01]

#pagebreak()

= Docker compose

== Базовый образ

#pic(img: "lab4/docker_compose.png")[Файл docker-compose.yml]

Здесь мы используем собранный образ из существующего  Dockerfile.

#pic(img: "lab4/docker_compose_up.png")[Запуск docker compose up]
#pic(img: "lab4/proof.png")[Веб форма wgdashboard]

== Сети и тома

#pic(img: "lab4/dc_1.png")[Том]
#pic(img: "lab4/dc_2.png")[Сетки 1]
#pic(img: "lab4/dc_3.png")[Сетки 2]

== Директива restart

#pic(img: "lab4/dc_4.png")[Restart]

Виды restart:
- no
- on-failure
- always
- unless-stopped

== Ограничения CPU и RAM

#pic(img: "lab4/dc_5.png")[Ограничения CPU и RAM]

== Второй запуск

#pic(img: "lab4/docker_compose_up_2.png")[Ограничения CPU и RAM]
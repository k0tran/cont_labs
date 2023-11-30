#import "template.typ": *
#show: lab.with(n: 3)

= Установка docker

Для установки docker engine был использован скрипт из прошлых лабораторных работ (который запускался на этапе provision):

#pic(img: "lab3/docker_script.png")[Скрипт для установки docker engine]

Проверка корректности установки:

#pic(img: "lab3/docker_hw.png")[Запуск контейнера hello-world]

#pagebreak()

= Образы (images)

#pic(img: "lab3/docker_images.png")[Список образов Docker]
#pic(img: "lab3/docker_run_ubuntu.png")[Загрузка образа Ubuntu]

Для того что бы удалить образ необходимо сначала удалиить контейнер (на рисунке показана попытка удалить образ остановив контейнер, но не удалив его):

#pic(img: "lab3/docker_rmi.png")[Удаление образа Ubuntu]

#pagebreak()

= Запуск контейнера

#pic(img: "lab3/ubuntu_bash.png")[Запуск `/bin/bash` в интерактивном режиме]
#pic(img: "lab3/docker_ps.png")[Списки запущенных и всех контейнеров]
#pic(img: "lab3/docker_history.png")[История контейнера ubuntu]

#pagebreak()

= Управление контейнерами

#pic(img: "lab3/docker_start.png")[Запуск контейнера]
#pic(img: "lab3/docker_top.png")[Просмотр запущенных процессов в контейнере]

Команда `sudo docker stats 02c5d1db2835` выводит следующую информацию о контейнере:

#pic(img: "lab3/docker_stats.png")[Ресурсы, занимаемые контейнером]
#pic(img: "lab3/docker_attach.png")[Подсоединение к контейнеру]
#pic(img: "lab3/docker_pause.png")[Приостановка контейнера]
#pic(img: "lab3/docker_kill.png")[Удаление процессов контейнера]
#pic(img: "lab3/docker_stop.png")[Остановка и удаление контейнера]

#pagebreak()

= Контейнеризация приложений

#pic(img: "lab3/cont_git_clone.png")[Клонирование репозитория]
#pic(img: "lab3/cont_app_dockerfile.png")[Создание Dockerfile внутри `gettning-started/app`]

Внутри файла следующее содержимое:
```Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000
```

#pic(img: "lab3/cont_build.png")[Сборка контейнера]
#pic(img: "lab3/cont_run.png")[Запуск контейнера]

После добавление правила на проброс порта и перезапуска виртуальной машины (не забываем снова запустить контейнер) на `http://localhost:3000` высвечивается следующая страница:

#pic(img: "lab3/cont_site.png")[Проверка запущеного контейнера]

Остановить контейнер можно следующей командой:

#pic(img: "lab3/cont_stop.png")[Остановка контейнера]

#pagebreak()

= Мультиконтейнерные приложения

#pic(img: "lab3/mcont_net_mysql.png")[Создание сети и поднятие mysql]
#pic(img: "lab3/mcont_mysql.png")[Проверка mysql]
#pic(img: "lab3/mcont_netshoot.png")[Запуск контейнера `nicolaka/netshoot`]
#pic(img: "lab3/mcont_dig.png")[Результаты выполнения команды `dig mysql`]
#pic(img: "lab3/mcont_stop.png")[Завершение рабочих контейнеров]

#pagebreak()

= Docker compose

#pic(img: "lab3/compose_version.png")[Версия docker compose]
#pic(img: "lab3/compose_file.png")[Файл `docker-compose.yml`]
#pic(img: "lab3/compose_up.png")[Запуск контейнеров при помощи docker compose]

#import "template.typ": *
#show: lab.with(n: 7)

= Кластер

У главной ноды 10-й айпишник и проброшены порты 1101, 1102, 1103. Так же скопированы необходимые docker-compose файлы (используемые скрипты будут приведены позже).

#pic(img: "lab7/vagrant1.png")[Главная нода]

Для рабочих нод необходимо поставить докер и завести в swarm.

#pic(img: "lab7/vagrant2.png")[Работяги]

Используемые скрипты включают в себя скрипт для основной ноды, рабочих и скрипт для деплоя.

#pic(img: "lab7/vagrant3.png")[Скрипты]

= Развертывание сервиса Viz

Ключевые моменты:
- доступ к docker.sock
- ограничение работы по hostname

#pic(img: "lab7/visualizer1.png")[visualizer docker-compose]
#pic(img: "lab7/visualizer2.png")[Запуск]
#pic(img: "lab7/visualizer3.png")[Отображение в браузере]

= Развертывание сервиса Portainer

Ключевые моменты:
- глобальный режим развертывания (по инстансу на ноде)
- коммуникация
  - `AGENT_CLUSTER_ADDR: tasks.agent` задание адреса агента
  - `command: -H tcp://tasks.agent:9001 --tlsskipverify` подключение к агенту по порту 9001
- сеть типа overlay (можно быть в одной сетке даже на разных компах, не говоря уже о виртуалках)
- прослушивание на порту 1102

#pic(img: "lab7/portainer1.png")[portainer docker-compose]
#pic(img: "lab7/portainer2.png")[Запуск]
#pic(img: "lab7/portainer3.png")[Отображение в visualizer]
#pic(img: "lab7/portainer4.png")[Отображение в браузере]

= Load-Balancing Web сервиса

В качестве веб сервиса был выбран itzg/web-debug-server (https://hub.docker.com/r/itzg/web-debug-server)

Ключевые моменты docker-compose:
- глобальный режим развертывания
- web-server слушает на 8080 порту, nginx на 80 (но доступ будет по 1103)
- nginx работает только на главной ноде
- сеть типа оверлей

#pic(img: "lab7/web1.png")[web docker-compose]
#pic(img: "lab7/web2.png")[nginx.conf]
#pic(img: "lab7/web3.png")[stack deploy]
#pic(img: "lab7/web4.png")[Отображение в visualizer]
#pic(img: "lab7/web5.png")[Отображение в браузере]

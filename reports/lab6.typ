#import "template.typ": *
#show: lab.with(n: 6)

= Конфигурация виртуальных машин

#pic(img: "lab6/vagrant.png")[Настройка виртуальных машин]

= Инициализация роя

#pic(img: "lab6/swarm_init.png")[Инициализация роя на машине manager1]
#pic(img: "lab6/swarm_join_link.png")[Получение команды для добавления машины в рой]

= Добавление нод

#pic(img: "lab6/swarm_node1.png")[Добавление worker1 в качестве ноды]
#pic(img: "lab6/swarm_node2.png")[Добавление worker2 в качестве ноды]
#pic(img: "lab6/swarm_node_list.png")[Список нод]
#pic(img: "lab6/swarm_node_vagrant.png")[Vagrant script]

= Развертывание сервиса в кластере

#pic(img: "lab6/service.png")[Запуск hello world на кластере]

- команда `docker service create` создает службу;
- флаг `--name` называет службу helloworld;
- флаг `--replicas` указывает желаемое состояние одного работающего экземпляра;
- aргументы `alpine ping` docker.com определяют службу как контейнер Alpine
Linux, который выполняет команду `ping docker.com`.

= Инспектирование сервиса в кластере

#pic(img: "lab6/service_info.png")[Просмотр информации о контейнере]

Вывод команды `sudo docker service inspect helloworld`:
```json
[
    {
        "ID": "pgd1yns23qfmv9rvhdk1wt0cv",
        "Version": {
            "Index": 21
        },
        "CreatedAt": "2023-10-31T17:36:51.670589461Z",
        "UpdatedAt": "2023-10-31T17:36:51.670589461Z",
        "Spec": {
            "Name": "helloworld",
            "Labels": {},
            "TaskTemplate": {
                "ContainerSpec": {
                    "Image": "alpine:latest@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978",
                    "Args": [
                        "ping",
                        "docker.com"
                    ],
                    "Init": false,
                    "StopGracePeriod": 10000000000,
                    "DNSConfig": {},
                    "Isolation": "default"
                },
                "Resources": {
                    "Limits": {},
                    "Reservations": {}
                },
                "RestartPolicy": {
                    "Condition": "any",
                    "Delay": 5000000000,
                    "MaxAttempts": 0
                },
                "Placement": {
                    "Platforms": [
                        {
                            "Architecture": "amd64",
                            "OS": "linux"
                        },
                        {
                            "OS": "linux"
                        },
                        {
                            "OS": "linux"
                        },
                        {
                            "Architecture": "arm64",
                            "OS": "linux"
                        },
                        {
                            "Architecture": "386",
                            "OS": "linux"
                        },
                        {
                            "Architecture": "ppc64le",
                            "OS": "linux"
                        },
                        {
                            "Architecture": "s390x",
                            "OS": "linux"
                        }
                    ]
                },
                "ForceUpdate": 0,
                "Runtime": "container"
            },
            "Mode": {
                "Replicated": {
                    "Replicas": 1
                }
            },
            "UpdateConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "RollbackConfig": {
                "Parallelism": 1,
                "FailureAction": "pause",
                "Monitor": 5000000000,
                "MaxFailureRatio": 0,
                "Order": "stop-first"
            },
            "EndpointSpec": {
                "Mode": "vip"
            }
        },
        "Endpoint": {
            "Spec": {}
        }
    }
]
```

#pic(img: "lab6/service_ps.png")[На каких нодах запущен сервис]

= Масштабирование сервера в кластере

#pic(img: "lab6/scale.png")[Масштабирование]

= Удаление сервиса

#pic(img: "lab6/rm.png")[Удаление контейнера]

Проверим как быстро были удалены контейнеры на разных машинах:

#pic(img: "lab6/rm1.png")[`docker ps` на manager1]
#pic(img: "lab6/rm2.png")[`docker ps` на worker1]
#pic(img: "lab6/rm3.png")[`docker ps` на worker2]

= Обновление сервиса

#pic(img: "lab6/redis_create.png")[Создание redis контейнера]
#pic(img: "lab6/redis_info.png")[Информация о контейнере]
#pic(img: "lab6/redis_update.png")[Обновление]

- остановка первого task;
- планирование обновления для остановленной задачи (task);
- запуск контейнера обновленной задачи;
  - если обновление задачи возвращает RUNNING, ожидание установленной задержки, а затем запуск задачи;
  - если в процессе обновления задача возвращает FAILED, остановка
обновления.

#pic(img: "lab6/redis_after_update.png")[После обновления]
#pic(img: "lab6/service_update.png")[Запуск обновленной версии]
#pic(img: "lab6/redis_ps.png")[Контейнеры]

= Обслуживание нод кластера

На предыдущих этапах руководства все узлы работали в ACTIVE режиме. Менеджер кластера может назначать задачи любому ACTIVE узлу, поэтому до сих пор все узлы были доступны для получения задач. Иногда, например, во время планового обслуживания необходимо установить узел в режим DRAIN. DRAIN режим не позволяет узлу получать новые задачи от менеджера кластера. Это также означает, что менеджер останавливает задачи, выполняемые на узле, и запускает задачи реплики на ACTIVE доступном узле.

#pic(img: "lab6/aval_check.png")[Проверка доступности нод]
#pic(img: "lab6/aval_create.png")[Создание сервиса]
#pic(img: "lab6/aval_wrk1_drain.png")[Перевод worker1 в режим DRAIN]
#pic(img: "lab6/aval_ps.png")[ps после перевода worker1 в DRAIN]
#pic(img: "lab6/aval_wrk1_aval.png")[Перевод worker1 обратно в режим AVALIABLE]

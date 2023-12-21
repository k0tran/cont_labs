#import "template.typ": *
#show: lab.with(n: 8)

= Выбор образа

Выбрал
#link("https://hub.docker.com/r/kassany/ziglang")[kassany/ziglang]

Тэг master

#pic(img: "lab8/docker_pull.png")[Скачивание образа]
#pic(img: "lab8/docker_run.png")[Запуск образа]

= Сканирование

== Docker Scout

```shell
curl -fsSL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh
```

#pic(img: "lab8/docker_scout.png")[Установка Docker Scout]
#pic(img: "lab8/docker_scout2.png")[Docker Scout Quickview]
#pic(img: "lab8/docker_scout3.png")[Ретегаем]
#pic(img: "lab8/docker_scout4.png")[Логинимся]
#pic(img: "lab8/docker_scout5.png")[Создаем репозиторий]
#pic(img: "lab8/docker_scout6.png")[Пушим]
#pic(img: "lab8/docker_scout7.png")[Врубаем Docker Scout]
#pic(img: "lab8/docker_scout8.png")[Смотрим уязвимости]

== Snyk

```shell
sudo apt install npm -y
sudo npm install snyk -g -y
```

#pic(img: "lab8/snyk1.png")[Логинимся в snyk]
#pic(img: "lab8/snyk2.png")[Анализ контейнера]

== Trivy

#pic(img: "lab8/trivy1.png")[Используем контейнер]
#pic(img: "lab8/trivy2.png")[Анализ контейнера (1)]
#pic(img: "lab8/trivy3.png")[Анализ контейнера (2)]

Итого сканер нашел две уязвимости aws

== anchore-engine

Репозиторий *заархивирован* в 2023

```shell
curl https://engine.anchore.io/docs/quickstart/docker-compose.yaml > docker-compose.yaml
docker-compose up -d
sudo apt-get install python3-pip -y
pip install anchorecli
export PATH=$PATH:/home/vagrant/.local/bin
```

#pic(img: "lab8/anchore1.png")[Добавляем в очередь на анализ]
#pic(img: "lab8/anchore2.png")[Анализ зафейлен]
#pic(img: "lab8/anchore3.png")[Пытался перезапустить, но catalog чет отваливается]

Попробуем загрузить какой-нибудь другой, более простой образ:

#pic(img: "lab8/anchore4.png")[Запуск анализа]
#pic(img: "lab8/anchore5.png")[Анализ зафейлен x2]

После этого увеличим объем оперативки до 4096 и запустим анализ debian:

#pic(img: "lab8/anchore6.png")[Запуск анализа]
#pic(img: "lab8/anchore7.png")[Анализ завершен]
#pic(img: "lab8/anchore8.png")[Число найденных уязвимостей]
#pic(img: "lab8/anchore9.png")[Некоторые из найденных уязвимостей]

Тоесть anchore анализирует далеко не все контейнеры.

== Docker Bench for Security

Так как Docker Bench Security необходимо запускать изнутри контейнера, а в выбранный образ не только не интерактивный (zig запускается один раз), но и отстуствует шелл впринципе (`busybox (x86_64)`)
Пробовал:
- `/bin/bash`
- `/bin/sh`
- `sh`
- `/bin/ash`

Поэтому возмем образ от того же автора для той же цели, но на основе дебиана `kassany/bookworm-ziglang`

```shell
docker run --rm -it -v $(pwd):/app -w /app kassany/bookworm-ziglang:latest bash
apt update
apt install git
```

#pic(img: "lab8/docker_bench1.png")[Первый запуск]

Ставим docker engine

#pic(img: "lab8/docker_bench2.png")[Первый запуск]

Отсюда я предполагаю что скрипт должен быть запущен на хостовой машине (либо используя контейнер docker-bench-security)

```shell
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo sh docker-bench-security.sh
```

```
# --------------------------------------------------------------------------------------------
# Docker Bench for Security v1.6.0
#
# Docker, Inc. (c) 2015-2023
#
# Checks for dozens of common best-practices around deploying Docker containers in production.
# Based on the CIS Docker Benchmark 1.6.0.
# --------------------------------------------------------------------------------------------

Initializing 2023-11-14T12:30:23+00:00


Section A - Check results

[INFO] 1 - Host Configuration
[INFO] 1.1 - Linux Hosts Specific Configuration
[WARN] 1.1.1 - Ensure a separate partition for containers has been created (Automated)
[INFO] 1.1.2 - Ensure only trusted users are allowed to control Docker daemon (Automated)
[INFO]       * Users: vagrant
[WARN] 1.1.3 - Ensure auditing is configured for the Docker daemon (Automated)
[WARN] 1.1.4 - Ensure auditing is configured for Docker files and directories -/run/containerd (Automated)
[WARN] 1.1.5 - Ensure auditing is configured for Docker files and directories - /var/lib/docker (Automated)
[WARN] 1.1.6 - Ensure auditing is configured for Docker files and directories - /etc/docker (Automated)
[WARN] 1.1.7 - Ensure auditing is configured for Docker files and directories - docker.service (Automated)
[INFO] 1.1.8 - Ensure auditing is configured for Docker files and directories - containerd.sock (Automated)
[INFO]        * File not found
[WARN] 1.1.9 - Ensure auditing is configured for Docker files and directories - docker.socket (Automated)
[WARN] 1.1.10 - Ensure auditing is configured for Docker files and directories - /etc/default/docker (Automated)
[INFO] 1.1.11 - Ensure auditing is configured for Dockerfiles and directories - /etc/docker/daemon.json (Automated)
[INFO]        * File not found
[WARN] 1.1.12 - 1.1.12 Ensure auditing is configured for Dockerfiles and directories - /etc/containerd/config.toml (Automated)
[INFO] 1.1.13 - Ensure auditing is configured for Docker files and directories - /etc/sysconfig/docker (Automated)
[INFO]        * File not found
[WARN] 1.1.14 - Ensure auditing is configured for Docker files and directories - /usr/bin/containerd (Automated)
[WARN] 1.1.15 - Ensure auditing is configured for Docker files and directories - /usr/bin/containerd-shim (Automated)
[WARN] 1.1.16 - Ensure auditing is configured for Docker files and directories - /usr/bin/containerd-shim-runc-v1 (Automated)
[WARN] 1.1.17 - Ensure auditing is configured for Docker files and directories - /usr/bin/containerd-shim-runc-v2 (Automated)
[WARN] 1.1.18 - Ensure auditing is configured for Docker files and directories - /usr/bin/runc (Automated)
[INFO] 1.2 - General Configuration
[NOTE] 1.2.1 - Ensure the container host has been Hardened (Manual)
[PASS] 1.2.2 - Ensure that the version of Docker is up to date (Manual)
[INFO]        * Using 24.0.7 which is current
[INFO]        * Check with your operating system vendor for support and security maintenance for Docker

[INFO] 2 - Docker daemon configuration
[NOTE] 2.1 - Run the Docker daemon as a non-root user, if possible (Manual)
docker-bench-security.sh: 37: [[: not found
[WARN] 2.2 - Ensure network traffic is restricted between containers on the default bridge (Scored)
[PASS] 2.3 - Ensure the logging level is set to 'info' (Scored)
docker-bench-security.sh: 96: [[: not found
[PASS] 2.4 - Ensure Docker is allowed to make changes to iptables (Scored)
docker-bench-security.sh: 118: [[: not found
[PASS] 2.5 - Ensure insecure registries are not used (Scored)
[PASS] 2.6 - Ensure aufs storage driver is not used (Scored)
[INFO] 2.7 - Ensure TLS authentication for Docker daemon is configured (Scored)
[INFO]      * Docker daemon not listening on TCP
docker-bench-security.sh: 185: [[: not found
[INFO] 2.8 - Ensure the default ulimit is configured appropriately (Manual)
[INFO]      * Default ulimit doesn't appear to be set
docker-bench-security.sh: 208: [[: not found
[WARN] 2.9 - Enable user namespace support (Scored)
[PASS] 2.10 - Ensure the default cgroup usage has been confirmed (Scored)
[PASS] 2.11 - Ensure base device size is not changed until needed (Scored)
docker-bench-security.sh: 276: [[: not found
[WARN] 2.12 - Ensure that authorization for Docker client commands is enabled (Scored)
[WARN] 2.13 - Ensure centralized and remote logging is configured (Scored)
[WARN] 2.14 - Ensure containers are restricted from acquiring new privileges (Scored)
[WARN] 2.15 - Ensure live restore is enabled (Scored)
[WARN] 2.16 - Ensure Userland Proxy is Disabled (Scored)
[INFO] 2.17 - Ensure that a daemon-wide custom seccomp profile is applied if appropriate (Manual)
[INFO] Ensure that experimental features are not implemented in production (Scored) (Deprecated)

[INFO] 3 - Docker daemon configuration files
[PASS] 3.1 - Ensure that the docker.service file ownership is set to root:root (Automated)
[PASS] 3.2 - Ensure that docker.service file permissions are appropriately set (Automated)
[PASS] 3.3 - Ensure that docker.socket file ownership is set to root:root (Automated)
[PASS] 3.4 - Ensure that docker.socket file permissions are set to 644 or more restrictive (Automated)
[PASS] 3.5 - Ensure that the /etc/docker directory ownership is set to root:root (Automated)
[PASS] 3.6 - Ensure that /etc/docker directory permissions are set to 755 or more restrictively (Automated)
[INFO] 3.7 - Ensure that registry certificate file ownership is set to root:root (Automated)
[INFO]      * Directory not found
[INFO] 3.8 - Ensure that registry certificate file permissions are set to 444 or more restrictively (Automated)
[INFO]      * Directory not found
[INFO] 3.9 - Ensure that TLS CA certificate file ownership is set to root:root (Automated)
[INFO]      * No TLS CA certificate found
[INFO] 3.10 - Ensure that TLS CA certificate file permissions are set to 444 or more restrictively (Automated)
[INFO]       * No TLS CA certificate found
[INFO] 3.11 - Ensure that Docker server certificate file ownership is set to root:root (Automated)
[INFO]       * No TLS Server certificate found
[INFO] 3.12 - Ensure that the Docker server certificate file permissions are set to 444 or more restrictively (Automated)
[INFO]       * No TLS Server certificate found
[INFO] 3.13 - Ensure that the Docker server certificate key file ownership is set to root:root (Automated)
[INFO]       * No TLS Key found
[INFO] 3.14 - Ensure that the Docker server certificate key file permissions are set to 400 (Automated)
[INFO]       * No TLS Key found
[PASS] 3.15 - Ensure that the Docker socket file ownership is set to root:docker (Automated)
[PASS] 3.16 - Ensure that the Docker socket file permissions are set to 660 or more restrictively (Automated)
[INFO] 3.17 - Ensure that the daemon.json file ownership is set to root:root (Automated)
[INFO]       * File not found
[INFO] 3.18 - Ensure that daemon.json file permissions are set to 644 or more restrictive (Automated)
[INFO]       * File not found
[WARN] 3.19 - Ensure that the /etc/default/docker file ownership is set to root:root (Automated)
[WARN]       * Wrong ownership for /etc/default/docker
[PASS] 3.20 - Ensure that the /etc/default/docker file permissions are set to 644 or more restrictively (Automated)
[INFO] 3.21 - Ensure that the /etc/sysconfig/docker file permissions are set to 644 or more restrictively (Automated)
[INFO]       * File not found
[INFO] 3.22 - Ensure that the /etc/sysconfig/docker file ownership is set to root:root (Automated)
[INFO]       * File not found
[PASS] 3.23 - Ensure that the Containerd socket file ownership is set to root:root (Automated)
[PASS] 3.24 - Ensure that the Containerd socket file permissions are set to 660 or more restrictively (Automated)

[INFO] 4 - Container Images and Build File
[INFO] 4.1 - Ensure that a user for the container has been created (Automated)
[INFO]      * No containers running
[NOTE] 4.2 - Ensure that containers use only trusted base images (Manual)
[NOTE] 4.3 - Ensure that unnecessary packages are not installed in the container (Manual)
[NOTE] 4.4 - Ensure images are scanned and rebuilt to include security patches (Manual)
[WARN] 4.5 - Ensure Content trust for Docker is Enabled (Automated)
[WARN] 4.6 - Ensure that HEALTHCHECK instructions have been added to container images (Automated)
[WARN]      * No Healthcheck found: [k0tran/ziglang:latest kassany/ziglang:latest]
[WARN]      * No Healthcheck found: [k0tran/ziglang:latest kassany/ziglang:latest]
[WARN]      * No Healthcheck found: [kassany/bookworm-ziglang:latest]
[WARN]      * No Healthcheck found: [aquasec/trivy:latest]
[WARN]      * No Healthcheck found: [postgres:9]
[INFO] 4.7 - Ensure update instructions are not used alone in the Dockerfile (Manual)
[INFO]      * Update instruction found: [kassany/bookworm-ziglang:latest]
[INFO]      * Update instruction found: [postgres:9]
[NOTE] 4.8 - Ensure setuid and setgid permissions are removed (Manual)
[PASS] 4.9 - Ensure that COPY is used instead of ADD in Dockerfiles (Manual)
[NOTE] 4.10 - Ensure secrets are not stored in Dockerfiles (Manual)
[NOTE] 4.11 - Ensure only verified packages are installed (Manual)
[NOTE] 4.12 - Ensure all signed artifacts are validated (Manual)

[INFO] 5 - Container Runtime
[INFO]   * No containers running, skipping Section 5

[INFO] 6 - Docker Security Operations
[INFO] 6.1 - Ensure that image sprawl is avoided (Manual)
[INFO]      * There are currently: 5 images
[INFO]      * Only 0 out of 5 are in use
[INFO] 6.2 - Ensure that container sprawl is avoided (Manual)
[INFO]      * There are currently a total of 0 containers, with 0 of them currently running

[INFO] 7 - Docker Swarm Configuration
[PASS] 7.1 - Ensure swarm mode is not Enabled, if not needed (Automated)
[PASS] 7.2 - Ensure that the minimum number of manager nodes have been created in a swarm (Automated) (Swarm mode not enabled)
[PASS] 7.3 - Ensure that swarm services are bound to a specific host interface (Automated) (Swarm mode not enabled)
[PASS] 7.4 - Ensure that all Docker swarm overlay networks are encrypted (Automated)
[PASS] 7.5 - Ensure that Docker's secret management commands are used for managing secrets in a swarm cluster (Manual) (Swarm mode not enabled)
[PASS] 7.6 - Ensure that swarm manager is run in auto-lock mode (Automated) (Swarm mode not enabled)
[PASS] 7.7 - Ensure that the swarm manager auto-lock key is rotated periodically (Manual) (Swarm mode not enabled)
[PASS] 7.8 - Ensure that node certificates are rotated as appropriate (Manual) (Swarm mode not enabled)
[PASS] 7.9 - Ensure that CA certificates are rotated as appropriate (Manual) (Swarm mode not enabled)
[PASS] 7.10 - Ensure that management plane traffic is separated from data plane traffic (Manual) (Swarm mode not enabled)


Section C - Score

[INFO] Checks: 86
[INFO] Score: -2
```

```shell
sudo sh docker-bench-security.sh -c container_images
```

```
# --------------------------------------------------------------------------------------------
# Docker Bench for Security v1.6.0
#
# Docker, Inc. (c) 2015-2023
#
# Checks for dozens of common best-practices around deploying Docker containers in production.
# Based on the CIS Docker Benchmark 1.6.0.
# --------------------------------------------------------------------------------------------

Initializing 2023-11-14T12:32:33+00:00


Section A - Check results

[INFO] 4 - Container Images and Build File
[INFO] 4.1 - Ensure that a user for the container has been created (Automated)
[INFO]      * No containers running
[NOTE] 4.2 - Ensure that containers use only trusted base images (Manual)
[NOTE] 4.3 - Ensure that unnecessary packages are not installed in the container (Manual)
[NOTE] 4.4 - Ensure images are scanned and rebuilt to include security patches (Manual)
[WARN] 4.5 - Ensure Content trust for Docker is Enabled (Automated)
[WARN] 4.6 - Ensure that HEALTHCHECK instructions have been added to container images (Automated)
[WARN]      * No Healthcheck found: [k0tran/ziglang:latest kassany/ziglang:latest]
[WARN]      * No Healthcheck found: [k0tran/ziglang:latest kassany/ziglang:latest]
[WARN]      * No Healthcheck found: [kassany/bookworm-ziglang:latest]
[WARN]      * No Healthcheck found: [aquasec/trivy:latest]
[WARN]      * No Healthcheck found: [postgres:9]
[INFO] 4.7 - Ensure update instructions are not used alone in the Dockerfile (Manual)
[INFO]      * Update instruction found: [kassany/bookworm-ziglang:latest]
[INFO]      * Update instruction found: [postgres:9]
[NOTE] 4.8 - Ensure setuid and setgid permissions are removed (Manual)
[PASS] 4.9 - Ensure that COPY is used instead of ADD in Dockerfiles (Manual)
[NOTE] 4.10 - Ensure secrets are not stored in Dockerfiles (Manual)
[NOTE] 4.11 - Ensure only verified packages are installed (Manual)
[NOTE] 4.12 - Ensure all signed artifacts are validated (Manual)


Section C - Score

[INFO] Checks: 12
[INFO] Score: -2
```

= Подведение итогов

#table(
  columns: (4cm, auto, auto, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [], [*Docker Scout*], [*Snyk*], [*Trivy*], [*Anchore*], [*Docker Bench*],
  [FOSS],                   [-], [+-], [+], [+-], [+],
  [Kubernetes],             [-], [+], [+], [+\*\*], [+\*\*\*],
  [CI/CD],                  [+], [+], [+], [+], [+],
  [Оф. репозитории Docker], [+], [+], [+], [+], [?],
  [CVE и CWE],              [+], [+], [+\*], [+], [-],
  [Производительность],     [+], [+], [+], [-1000], [+],
  [Простота],               [+-], [+], [+], [-10], [+],
  [Вид],                    [Web+CLI], [CLI], [CLI], [Cont+CLI], [Script/Cont],
  [Мультиплатформенность],  [+], [+], [+], [+], [-],
  [VPN],                    [+], [+], [+], [+], [+],
  [Обновления бд],          [+], [+], [+], [-], [+],
  [Доп. функционал],        [платно], [платно], [бесплатно], [платно], [бесплатно],
)

\* - есть, но #link("https://www.howtogeek.com/devops/how-to-use-trivy-to-find-vulnerabilities-in-docker-containers/")[не в моем случае]
\*\* - #link("https://anchore.com/kubernetes/")[обещания] есть, платно.
\*\*\* - #link("https://github.com/aquasecurity/kube-bench")[kube-bench]
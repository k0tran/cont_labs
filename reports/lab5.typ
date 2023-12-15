#import "template.typ": *
#show: lab.with(n: 5)

#align(center)[#text(size: 17pt)[*Предисловие*]]

Теперь лабораторные выполняются на Windows, потому что Debian 11 часто отбивается от сети университета, из-за чего каждые пять минут приходиться логиниться снова, а после \~5 раз достигается лимит устройств.

= Подготовка виртуальной машины 

#pic(img: "lab5/vagrant.png")[Конфигурация `vagrant`]

В данном `Vagrantfile`:
- отключаются обновления для образа и гостевых дополнений (необходим плагин `vagrant-vbguest`);
- проброс портов, которые могут понадобится в будущем;
- использованеи моста (`public_network`) для доступа к nginx извне;
- общая папка для сохранения файлов Dockerfile, docker-compose.yml и сертификатов;
- ограничения на память (могут понадобиться);
- установка docker и docker-compose (для последнего необходим плагин `vagrant-docker-compose`).

= Сертификаты

#pic(img: "lab5/mkcert1.png")[Установка mkcert]
#pic(img: "lab5/mkcert2.png")[Установка корневого сертификата]
#pic(img: "lab5/mkcert3.png")[Выпуск необходимых сертификатов]
#pic(img: "lab5/mkcert4.png")[Исправление формата и задание как provision]

= Nginx

#pic(img: "lab5/nginx1.png")[Создание необходимых директорий и перемещение сертификатов]
#pic(img: "lab5/nginx2.png")[Provision]

Файл app.conf:
```conf
server {
    listen 80;
    server_name dns.student registry.student;

    # Перенаправление с HTTP на HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name dns.student;

    ssl_certificate /etc/nginx/ssl/dns.student.crt;
    ssl_certificate_key /etc/nginx/ssl/dns.student.key;

    location / {
        proxy_pass http://dns:3000;  # DNS
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 443 ssl;
    server_name registry.student;

    ssl_certificate /etc/nginx/ssl/registry.student.crt;
    ssl_certificate_key /etc/nginx/ssl/registry.student.key;

    location / {
        proxy_pass http://registry:5000;  # Registry
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

= Docker compose

```yml
version: '3'
services:
  dns:
    image: adguard/adguardhome:latest
    ports:
      - '53:53/tcp'
      - '53:53/udp'
    networks:
      - lab5_network
    restart: unless-stopped
    volumes:
      - volume_dns_work:/opt/adguardhome/work
      - volume_dns_conf:/opt/adguardhome/conf
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    hostname: dns

  nginx:
    image: nginx:latest
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx/conf/app.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nginx/certs:/etc/nginx/ssl
    networks:
      - lab5_network
    depends_on:
      - dns
      - registry
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
    hostname: web

  registry:
    image: registry:2
    hostname: registry
    networks:
      - lab5_network
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    environment:
      - REGISTRY_AUTH=htpasswd
      - REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd
      - REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm
    volumes:
      - ./auth:/auth
    restart: unless-stopped
    depends_on:
      - dns

networks:
  lab5_network:

volumes:
  volume_dns_work:
  volume_dns_conf:
  registry_auth:
```

#pic(img: "lab5/dc1.png")[Первая попытка поднять]
#pic(img: "lab5/dc2.png")[Смотрим кто занял 53 порт]
#pic(img: "lab5/dc3.png")[Ставим no в /etc/systemd/resolved.conf]

```shell
sudo systemctl restart systemd-resolved
```

#pic(img: "lab5/dc4.png")[Успешный запуск]
#pic(img: "lab5/dc5.png")[Provision]

= Настройка DNS

#pic(img: "lab5/dns1.png")[Приветственное окно]
#pic(img: "lab5/dns2.png")[Ставим порт на 3000]
#pic(img: "lab5/dns3.png")[Устанавливаем пароль]
#pic(img: "lab5/dns4.png")[Жмем next]
#pic(img: "lab5/dns5.png")[Завершение]
#pic(img: "lab5/dns6.png")[Открываем dashboard]
#pic(img: "lab5/dns7.png")[Dashboard]
#pic(img: "lab5/dns8.png")[Перезаписываем DNS (1)]
#pic(img: "lab5/dns9.png")[Перезаписываем DNS (2)]
#pic(img: "lab5/dns10.png")[Проверка из виртуальной машины]

= Загрузка wg-dashboard

Используюем следующий Dockerfile (из прошлой лабы):
```Dockerfile
FROM ubuntu:20.04

LABEL author="Sorochan I.V."
LABEL email="none"
LABEL version="0.1.0"
LABEL description="wgdashboard + wireguard + ubuntu"

RUN adduser user01 --disabled-password && \
    echo "user01 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Update
# Sudoers = hotfix
RUN apt-get update -y && \
    rm -rf /etc/sudoers && \
    apt-get install -y wireguard iproute2 net-tools git python3-pip gunicorn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup wireguard config
RUN echo -n "[Interface]\nPrivateKey = " > /etc/wireguard/wg0.conf && \
    wg genkey | tee -a /etc/wireguard/wg0.conf | wg pubkey > publickey && \
    echo -n "Address = 10.0.0.1/" >> /etc/wireguard/wg0.conf && \
    ip -of inet addr show eth0 | awk '{split($4, a, "/"); print a[2]}' >> /etc/wireguard/wg0.conf && \
    echo "ListenPort = 51820" >> /etc/wireguard/wg0.conf && \
    echo -n "\n[Peer]]\nPublicKey = " >> /etc/wireguard/wg0.conf && \
    cat publickey >> /etc/wireguard/wg0.conf && rm -f publickey && \
    echo "AllowedIPs = 0.0.0.0/0" >> /etc/wireguard/wg0.conf

# Setup wg-dashboard
RUN cd /usr/local/share && \
    git clone -b v3.0.6 https://github.com/donaldzou/WGDashboard.git wgdashboard && \
    cd wgdashboard/src && \
    chmod u+x wgd.sh && ./wgd.sh install && \
    sudo chmod -R 755 /etc/wireguard

EXPOSE 51820/udp
EXPOSE 10086/tcp

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c", "wg-quick up wg0 && cd /usr/local/share/wgdashboard/src && ./wgd.sh start && tail -f /dev/null"]
```

#pic(img: "lab5/reg1.png")[Сборка]
#pic(img: "lab5/reg2.png")[Тэгируем]
#pic(img: "lab5/reg3.png")[Генерим креды]

После этого добавили лайн в провижн.

#pic(img: "lab5/reg4.png")[Успешный логин]
#pic(img: "lab5/reg5.png")[Ошибка пуша]
#pic(img: "lab5/reg6.png")[Ошибка пуша в логах nginx]

Добавляем `client_max_body_size 0;`

#pic(img: "lab5/reg7.png")[Ошибка unknown blob]
#pic(img: "lab5/reg8.png")[Напрямую пушится нормально]

Фикс из https://github.com/distribution/distribution/issues/2746:

```
proxy_set_header Host $http_host;
proxy_set_header X-Forwarded-Proto https;
proxy_ssl_server_name on;
proxy_http_version 1.1;
```

#pic(img: "lab5/reg9.png")[Работает]
 
= Доступ к админке днс

#pic(img: "lab5/adm1.png")[Экспортируем корневой сертификат]
#pic(img: "lab5/adm2.png")[Устанавливаем]
#pic(img: "lab5/adm3.png")[Сертификат установлен успешно]

Однако по какой-то причине windows не хочет использовать dns 127.0.0.1:53

#pic(img: "lab5/adm4.png")[Диг неуспешен]

При этом:

#pic(img: "lab5/adm5.png")[DNS выставлен]
#pic(img: "lab5/adm6.png")[NMap показывается что порт открыт]
#pic(img: "lab5/adm7.png")[Доступа из браузера нет]
#pic(img: "lab5/adm8.png")[Nslookup тоже самое выдает]
#pic(img: "lab5/adm9.png")[Curl]
#pic(img: "lab5/adm10.png")[Брендмаэр отрублен]

Теперь для того что бы удостоверится что сертификаты работают изменим hosts:
#pic(img: "lab5/adm11.png")[Файл hosts]
#pic(img: "lab5/adm12.png")[Все работает]

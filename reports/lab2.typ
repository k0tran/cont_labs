#import "template.typ": *
#show: lab.with(n: 2)

#align(center)[#text(size: 17pt)[*Предисловие*]]

Перед началом хода лабораторной работы стоит сказать несколько слов про её предыдущую версию. Дело в том, что вся работа уже была выполнена за исключением одной небольшой детали -- использовались статичные айпишники вида `192.168.56.X` вместо `172.20.0.X`.
При попытке установить необходимый адрес выводилась следующая ошибка:

#pic(img: "lab2/vbox_error_1.png")[Ошибка использования адреса из запрещенного диапазона]

Немного погуглив, я нашел решение:

#pic(img: "lab2/vbox_error_2.png")[Модифицированный `/etc/vbox/networks.conf`]

После которого появилась новая ошибка:

#pic(img: "lab2/vbox_error_3.png")[Ошибка VBoxManage E_ACCESSDENIED]

При поиске решения для этой ошибки я нашел (ссылки встроены):
- #link("https://stackoverflow.com/questions/69728426/e-accessdenied-when-creating-a-host-only-interface-on-virtualbox-via-vagrant")[stackoverflow];
- #link("https://www.virtualbox.org/ticket/20626")[тикет на virtualbox.org]

На данных ресурсах указано два способа решения, один из которых уже был применен (модификация `/etc/vbox/networks.conf`), а другой заключался в использовании `VirtualBox 6.1.26` или более ранней версии (У меня стоял `VirtualBox 7.X`).

Однако, при установке `VirtualBox 6.1` (пакет из AUR) было обнаружено, что для его работы требуются старые модули ядра (`linuxX-virtualbox-host-modules`). При этом просто старые ядра не работали, необходимы были именно старые модули (проверял 419, 515, 61), которых в свободном доступе не было! (в отличии от того же `Arch`; Модули ядра `Arch`'a не подошли).

Соответственно из этой ситуации я вижу три выхода:
- использовать виртуалку в виртуалке (внешнаяя 7.X, внутренняя 6.1);
- использовать Windows 10, которая стоит у меня второй системой;
- установить на рабочую машину совместимую с VirtualBox 6.1 систему (третьей). 

Первый вариант отметается ввиду возможных сложностей с настройкой (надо разрешить подобного рода развертывание) и сильных проблем с производительностью. Второй вариант тоже может быть проблемным из-за особенностей ОС Windows. Третий вариант выглядит труднозатратным, однако руководствуясь опытом установки различных дистрибутивов я посчитал его самым простым для меня. Поэтому был установлен xfce4 Debian 12:

#pic(img: "lab2/sysinfo_1.png")[Запуск `neofetch`]

Установленные версии VirtualBox и Vagrant:

#pic(img: "lab2/sysinfo_2.png")[Версии VirtualBox и Vagrant]

Однако позже я узнал что скачал слишком старую версию `6.1` (небходима не позднее `6.1.26`). А эта версия в свою очередь не поддерживала Debian 12, поэтому был установлен Debian 11 и установлена "правильная" версия VirtualBox:

#pic(img: "lab2/sysinfo_3.png")[Debian 11]

#pagebreak()

= Vagrant disk

== Подготовительные работы

Инициализация виртуальной машины:

#pic(img: "lab2/vagrant_init.png")[Инициализация виртуальная машины]

Включение функиции управления дисками:

#pic(img: "lab2/vagrant_disks_on.png")[Включение функции управления дисками]

Так же отключаем проверку обновлений. Для этого нужно раскомментировать следующую строку:

#pic(img: "lab2/vagrant_updates_off.png")[Настройка отключения обновлений]

== Работа с дисками

Для начала имеем следующую структуру:

#pic(img: "lab2/vagrant_disks_1.png")[Дисковое пространство виртуальной машины]

Здесь видно, что основной диск виртуальной машины (`sda1`) занимает 40 гигабайт. Для его увеличения на 20 гигабайт необходимо установить новый раздел диска 60 гигабайт. Так же добавляем подключение дополнительного жесткого диска размером 10 гигабайт (с именем `extra`):

#pic(img: "lab2/vagrant_disks_2.png")[Конфигурация дисков виртуальной машины]

Далее перезагружаем виртуальную машину и видим следующий результат:

#pic(img: "lab2/vagrant_disks_3.png")[Дисковое пространство виртуальной машины после изменений]

На рисунке выше видно, что основной диск (`sda1`) теперь занимает 60 гигабайт, а так же появился дополнительный диск на 10 гигабайт (`sdc`)

#pagebreak()

= Vagrant network

== Vagrantfile

Приватная сеть со статичным ip адресом из диапазона `172.20.0.0/24` (был выбран `172.20.0.5`):

#pic(img: "lab2/vagrant_net_1.png")[Настройка приватной сети]

Публичная сеть:

#pic(img: "lab2/vagrant_net_2.png")[Настройка публичной сети]

Сетевое имя хоста:

#pic(img: "lab2/vagrant_net_3.png")[Задание сетевого имени хоста]

Пробрасываение 22-го порта виртуальной машины на 3333 порт хоста:

#pic(img: "lab2/vagrant_net_4.png")[Пробрасывание]

== Проверка всех измененных параметров

Проверяем что имя виртуальной машины поменялось на `vm1` и была добавлена запись в `/etc/hosts`:

#pic(img: "lab2/vagrant_net_5.png")[Демонстрация настроек имени хоста]

Рассмотрим адаптеры виртуальной машины:

#pic(img: "lab2/vagrant_net_6.png")[Адаптеры виртуальной машины]

Здесь `enp0s9` имеет публичный ip `192.168.31.209`, а `enp0s8` имеет статический адрес `172.20.0.5`.

Проверка прокинутого порта при помощи сканера nmap:

#pic(img: "lab2/vagrant_net_6.png")[Результаты сканирования nmap]

#pagebreak()

= Vagrant provision

== Установка

Для начала выделим скрипт установки (из прошлой лабораторной) в отдельный скрипт:

#pic(img: "lab2/vagrant_prov_1.png")[Скрипт установки docker engine]

Затем необходимо добавить этот скрипт на этап provision:

#pic(img: "lab2/vagrant_prov_2.png")[Сам скрипт]

== Подтверждение установки

#pic(img: "lab2/vagrant_prov_3.png")[Запуск `docker run hello-world`]

#pagebreak()

= Vagrant multi-machine

В первую очередь скрипты для provision были выделены в отдельные переменные:

#pic(img: "lab2/vagrant_vm_cfg_1.png")[Скрипты]

Затем используем их при конфигурации трех виртуальных машин:

#pic(img: "lab2/vagrant_vm_cfg_2.png")[Конфигурация vm1, vm2 и vm3]

Стоит отметить, что в задании проверка функционала не заявлена обязательной. Однако для себя я запустил пару команд и, например, убедился что пользователь присутствует в системе (при помощи `id`). Так же за него можно залогинится `sudo login adam`, предварительно установив пароль `sudo passwd adam`
# Тестовое задание от PARMA Technologies Group
## Задание
Создать 3 vm (любой гипервизор, можно VirtualBox)
- Jenkins (centos7/ubuntu)
- gitlab (centos7/ubuntu)
- testbox (centos7)

Jenkins: Создать job, которая бы запустила ansible playbook Gitlab:
в единственный репозиторий положить:
- ansible playbook
- любое тестовое вебприложение класса "Hello, world" на любом языке/стеке
- заполнить readme.md Ansible playbook: На узел testbox устанавливает любой
вебсервер (nginx, apache, lighttpd, tomcat) + деплоит на него вебприложение 'hello,world'

Описать кратко решение задачи и инструкции для проверки.

## Решение
### Начальные настройки
Решение использует программу Vagrant.

Скрипты задания совместимы с системами CentOS/RedHat и Debian.

Подготовка сервисов для обсуживания программного окружения задания:
```
sudo ./parma-task-srv.sh --install ansible vagrant
```
Скрипт создает и настраивает два сервиса: ansible и vagrant.
С помощью скрипта можно устанавливать программы ansible и vagrant по
отдельности (см. --help).

### Создание окружения
Создание окружения виртуальных машин:
```
sudo ./parma-task-env.sh --up
```
Скрипт с использованием Vagrant создает следующие ВМ:
- vm-gitlab (ansible роль gitlab)
- vm-jenkins (ansible роль jenkins)
- vm-testbox (ansible роль testbox)

Виртуальные машины не будут созданы, если суммарный объем оперативной памяти, доступный системе,
будет менее 6 ГиБ.

В качестве provider виртуальных машин используется libvirt. В качестве provisioner -- Ansible.
Виртуальным машинам присваиваются дополнительные статические IP сети 192.168.99.0
для возможности использования собственного hosts файла.

Для полной автоматизации не решены задачи:
- Получение access token к Gitlab API для пользователя root через curl или ansible uri.

Скрипт parma-task-env.sh создает хранилища для паролей пользователей виртуальных машин,
а так же пользователей сервисов Gitlab и Jenkins. Пароли шифруются с использованием ansible-vault.

Получение пароля root для доступа к GUI Gitlab:
```
sudo ./vault-get-user-pass.sh --vault gitlab --host vm-gitlab --user root
```

GUI Gitlab доступен по адресу https://vm-gitlab.

Необходимо разрешить доступ к Gitlab API из локальной сети:
- Перейти по адресу https://vm-gitlab/admin/application_settings/network
- Воспользоваться меню Outbound requests --> Allow requests to the local network
  from hooks and services --> Save changes.

Получение пароля admin для доступа к GUI Jenkins:
```
sudo ./vault-get-user-pass.sh -v jenkins -h vm-jenkins -u admin
```

GUI Jenkins доступен по адресу http://vm-jenkins:8080.


<Начало временного решения>
Устанавливаем необходимые плагины для jenkins. Добавляем администратора сервиса Jenkins.
Для целей задания в качестве администратора можно создать пользователя root с адресом
эл. почты ansible@vm-jenkins. Пароль для пользователя root уже сгенерирован, и
находится в хранилище jenkins. Получить его можно командой:
```
sudo ./vault-get-user-pass.sh -v jenkins -h vm-jenkins -u root
```
<Конец временного решения>


Окружение готово к использованию.

### Настройка CI.


Для получения access token после аутентификации используем endpoint https://vm-gitlab/profile/personal_access_tokens

Access token будет использоваться в дальнейших плейбуке для создания пользователя и проекта тестового задания.

<Здесь заканчивается описание работы с окружением виртуальных машин.>

После знакомства с тестовым заданием можно вернуть исходное состояние системы.
Самый простой способ это сделать:
```
./parma-task-srv.sh --remove vagrant ansible
```
При запуске этой команды будут удалены все сервисы, установленные скриптом
parma-task-srv.sh.

Работу скрипта parma-task-srv.sh можно тестировать скриптом test-parma-task-srv.sh.

### Действия ролей
Действия роли **ansible**:
- Установка пакетов openssh-client и openssl (для генерации рандомных паролей).
- Создание каталога для хранения паролей пользователей всех клиентов под
  управлением сервиса ansible. Настройку можно произвести в файле
  playbooks-prov/group_vars/all.yml, переменная vault_password_path.
- Добавление в систему пользователя ansible. Настройку пользователя можно
  произвести в playbooks-prov/group_vars/all.yml, переменная ansible_user_srv.
+ Действия для пользователя ansible:
  + Создание всех групп, указанных в настройках пользователя.
  + Сохранение пароля в файл /etc/ansible/.pass/\<inventory_hostname\>.ansible.
  + Шифрование созданного файла с паролем программой ansible-vault для localhost.
  + Конфигурация доступа к файлу пароля, согласно настройкам пользователя ansible.
- Конфигурация доступа к каталогу паролей, согласно настройкам пользователя ansible.
+ Создание и конфигурация ключей SSH.
  + Генерация SSH ключей (тип rsa, 4096 бит) с passphrase.
  + Настройка клиента SSH с использованием файла .ssh/config. Параметры настройки находятся в файле
    playbooks-prov/roles/ansible/tasks/ssh-keys.yml, стоки 39-45.
  + Настройка SSH клиента для мультиплексирования SSH сессий.
- Создание каталога /home/ansible/.vault_pass/ для хранения паролей vault-id.
  Настройку можно произвести в файле playbooks-prov/group_vars/all.yml,
  переменная vault_id_path.
- Создание паролей vault-id меток prov, dev, stage, prod по адресу
  /home/ansible/.vault_pass/\<label\>\_pass. Настройку можно произвести в файле 
  playbooks-prov/group_vars/all.yml, переменная vault_id_labels.

Особенности:
- Если при шифровании файла с паролем пользователя введенные пароли не совпадают,
  то task выдаст ошибку, но плейбук продолжит свое выполнение. Как результат,
  файл с паролем не будет зашифрован, и потребуется ручное шифрование файла
  программой ansible-vault, либо повторный запуск плейбука playbooks-prov/ansible-server-up.yml.
- Для пользователя ansible на удаленных машинах пароли шифруются с помощью vault-id метки prov,
  т.к. выполнение плейбуков в приложениях типа vagrant при запуске сразу нескольких
  машин не дает адекватного интерфейса для ввода нового пароля vault вручную.

Все остальные роли, используемые в плейбуках, зависят от роли common.

Действия роли **common**:
- Установка timezone для ОС. Настройку можно произвести в файле
  playbooks-prov/group_vars/all.yml, переменная site_timezone.
- Установка пакетов sudo, openssl (для генерации рандомных паролей).
- В систему добавляются пользователи, указанные в переменной users
  (см. playbooks-prov/group_vars/all.yml, переменная users, либо другие файлы с переменными
  в inventories).
- Генерируются и устанавлдиваются пароли для пользователей, перечисленных в
  переменной users, сохраняются на сервере Ansible в каталоге /etc/ansible/.pass/
  в формате \<inventory_hostname\>.\<username\> и шифруются ansible-vault
  с использованием vault-id метки prov.
- Настраивается файл sudoers (см. playbooks-prov/roles/common/templates/).
- Для клиентов сервера ansible копируется файл с настройками sshd (
  см. playbooks-prov/roles/common/files/sshd_config.txt).
- DNS запись о клиенте добавляется в файл /etc/hosts на сервере ansible.

Действия роли **vagrant**:
- Установка последнего пакета Vagrant.
- Устанавка пакетов для работы vagrant с libvirt. Более подробную информацию
  см. по адресу https://github.com/vagrant-libvirt/vagrant-libvirt/blob/master/README.md.

Действия роли **gitlab**:
- Установка пакетов зависимостей согласно иструкциям по адресу https://about.gitlab.com/install/.
- Установка пакета gitlab-ce.
- Создание каталога /etc/gitlab/.pass/ для хранения паролей пользователей gitlab,
  созданных с использованием ansible сервера. Настройку можно произвести в файле
  playbooks-prov/roles/gitlab/defaults/main.yml, переменная gitlab_vault_passwd_dir.
- Генерация и сохранение рандомного пароля пользователя root по адресу
  /etc/gitlab/.pass/\<inventory_hostname\>.root.
- Первоначальная реконфигурация gitlab.
- Настройка файервола сервера gitlab.
- Создание самоподписанных сертификатов сервера gitlab.
- Копирование файла конфигурации gitlab (см. файл playbooks-prov/roles/gitlab/defaults/main.yml,
  переменная gitlab_config_template).
- Установка модуля python-gitlab на сервере gitlab.
- Реконфигурация gitlab с новыми настройками.
- Установка пароля root в сервисе Gitlab.
- Присвоение рандомных паролей пользователям root и vagrant на сервере gitlab.

Действия роли **testbox**:
- Присвоение рандомных паролей пользователям root и vagrant.
- Пользователям ansible и vagrant разрешается выполнение без пароля любых команд
  от имени любого пользователя с использованием sudo (см. group_vars/testweb.yml).

Действия роли **jenkins**:
- Установка пакета Jenkins и его зависимостей.
- Запуск Jenkins.
- Установка пакета Ansible.
- Разрешение TCP соединений на порт 8080 в firewalld.
+ Настройки для пользователя ansible:
  + Генерация SSH ключей (тип rsa, 4096 бит) без passphrase.
  + Добавление SSH pub ключей ansible клиенту vm-testbox в файл по адресу /home/ansible/.ssh/authorized_keys.
- Присвоение рандомных паролей пользователям root и vagrant.
- Пользователям ansible и vagrant разрешается выполнение с паролем любых команд
  от имени любого пользователя с использованием sudo (см. group_vars/testweb.yml).

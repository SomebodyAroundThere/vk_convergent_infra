# Развертывание кластера Redis при помощи Terraform

1. Создание ресурсов vk-cloud
Для задания были созданы: сеть, роутер, подсеть, 3 инстанса виртуальной машины Ubuntu22.04 (размер диска 10GB , тип диска ceph-ssd) в разных зонах доступности, инстанс базы данных MySQL 8.

## 🚀 Быстрый старт

### 1. Клонирование репозитория

```bash
git clone https://github.com/somebodyaroundthere/vk_convergent_infra.git
cd vk_convergent_infra
```

### 2. Настройка переменных

измените переменные на те, которые вам нужны в файлах secret.tfvars и variables.tf

### 3. Инициализация и развертывание

```bash
# Инициализация Terraform
terraform init

# Просмотр плана развертывания
terraform plan -var-file="secret.tfvars"

# Развертывание инфраструктуры
terraform apply -var-file="secret.tfvars"
```
### 4. Запуск сценария ansible

После успешного развертывания перейдите в директорию ansible и выполните на хостовой машине:

```bash
ansible-vault create group_vars/all/vault.yml
```
Запишите в созданный файл все secret/password:
```bash
ansible-vault edit group_vars/all/vault.yml
```
Поменяйте адреса вм в файле inventories/hosts.ini. Запустите ansible:
```bash
ansible-playbook --ask-vault-pass playbook.yml
```
### 5. Проверка
```bash
curl -k https://87.239.105.48
#проверка доступности haproxy
curl http://87.239.107.184:5000
#проверяем, что app не доступен извне
#на одной из вм app
mysql -u testuser  -h 192.168.200.150 -P 3306 -p
mysql> show DATABASES;
#должна выводится созданная бд
```
## 📁 Структура проекта

```text
vk_convergent_infra/
├── ansible        
│   ├── ansible.cfg
│   ├── group_vars
│   │   └── all
│   │       └── vault.yml
│   ├── inventories
│   │   └── hosts.ini
│   ├── playbook.yml
│   ├── README.md
│   └── roles
│       ├── app
│       │   ├── tasks
│       │   │   └── main.yml
│       │   └── templates
│       │       ├── app.service.j2
│       │       └── config.py.j2
│       ├── haproxy
│       │   ├── handlers
│       │   │   └── main.yml
│       │   ├── tasks
│       │   │   └── main.yml
│       │   └── templates
│       │       └── haproxy.cfg.j2
│       └── hardening
│           ├── handlers
│           │   └── main.yml
│           ├── tasks
│           │   └── main.yml
│           └── templates
│               └── sshd_config.j2
├── firewall.tf             # Настройка firewall
├── main.tf                 # Основная конфигурация Terraform
├── variables.tf            # Определение переменных
├── provider.tf             # Настройка провайдера VK Cloud
├── network.tf              # Настройка сети

```

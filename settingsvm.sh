#!/bin/bash

# Определите переменные
REMOTE_USER="aleonov"
REMOTE_HOST="127.0.0.1"
ROOT_PASSWORD="1971"
NEW_ROOT_PASSWORD="1971"

# Параметры подключения к удаленному серверу
SSH_OPTIONS="-p 2222 -o StrictHostKeyChecking=no"

# Команды для выполнения на удаленном хосте
COMMANDS=$(cat <<EOF

# Изменение пароля root
echo "$ROOT_PASSWORD" | su -c "echo -e \"$NEW_ROOT_PASSWORD\n$NEW_ROOT_PASSWORD\" | passwd root" - && \

# Обновление строки в sshd_config и перезапуск SSH
echo "$ROOT_PASSWORD" | su -c "sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && systemctl restart sshd" \

# Установка Python 3
echo "$ROOT_PASSWORD" | su -c "apt-get update && apt-get install -y python3" - && -
EOF
)

# Выполнение команд на удаленном хосте
ssh  $SSH_OPTIONS "$REMOTE_USER@$REMOTE_HOST" "$COMMANDS"

ansible-playbook -i hosts.ini debian-nginx.yml

#!/bin/sh
#set -e DEBUG отключаем все коды состояния команд != 0

#LOG_FILE="/tmp/*.json"
ANSIBLE_LOG="/logs/ansible.log"

# Запускаем Ansible роль
cd /ansible

echo "Запуск Ansible роли ssh_audit..."
ansible-playbook \
  -i inventory \
  playbooks/ssh_audit_run.yml \
  > ${ANSIBLE_LOG} 2>&1

if [ $? -ne 0 ]; then
  echo "Ansible-playbook завершился с ошибкой."
  tail -50 ${ANSIBLE_LOG}
  exit 1
fi

echo "Ansible-playbook успешно выполнен."

set -- /logs/*_audit_report.json
if [ ! -f "$1" ]; then
  echo "Не найдено ни одного .json файла в /logs/"
  exit 1
fi

echo "Лог-файл найдены по пути /logs/"

for file in /logs/*_audit_report.json; do
    if [[ -f "$file" ]]; then
        ls "$file"
        cat "$file"
        echo  
    fi
done

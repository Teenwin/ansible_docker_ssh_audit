#!/bin/sh
set -e

#LOG_FILE="/tmp/*.json"
ANSIBLE_LOG="/logs/ansible.log"

# Запускаем Ansible роль
cd /ansible

echo "Запуск Ansible роли ssh_audit..."
ansible-playbook \
  -i inventory \
  playbooks/ssh_audit_run.yml \
  > "${ANSIBLE_LOG}" 2>&1

# Проверяем, завершился ли успешно
if [ $? -ne 0 ]; then
  echo "Ansible завершился с ошибкой. Лог: ${ANSIBLE_LOG}"
  tail -n 20 "${ANSIBLE_LOG}"
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
        cat "$file"
        echo  
    fi
done

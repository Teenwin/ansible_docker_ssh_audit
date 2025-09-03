#!/bin/sh
#set -e DEBUG отключаем все коды состояния команд != 0

#LOG_FILE="/tmp/*.json"
ANSIBLE_LOG="/logs/ansible.log"

#echo "Запуск Ansible роли ssh_audit..."
ansible-playbook \
  -i /ansible/inventory.ini \
  /ansible/playbooks/ssh_audit_run.yml \
  > ${ANSIBLE_LOG} 2>&1

if [ $? -ne 0 ]; then
  echo "Ansible-playbook завершился с ошибкой."
  tail -50 ${ANSIBLE_LOG}
  exit 1
fi

#echo "Ansible-playbook успешно выполнен."

set -- /logs/*ssh_audit.json
if [ ! -f "$1" ]; then
  echo "Не найдено ни одного .json файла в /logs/"
  exit 1
fi

#echo "Лог-файл найдены по пути /logs/"

for file in /logs/*ssh_audit.json; do
    if [[ -f "$file" ]]; then
#        ls "$file"
        cat "$file"
#        echo  
    fi
done

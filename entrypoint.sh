#!/bin/sh
set -e

LOG_FILE="/logs/audit_report.json"
ANSIBLE_LOG="/logs/ansible.log"

# Запускаем Ansible роль
cd /ansible

echo "Запуск Ansible роли ssh_audit..."
ansible-playbook \
  -i inventory \
  site.yml \
  --extra-vars "output_log_path=${LOG_FILE}" \
  > "${ANSIBLE_LOG}" 2>&1

# Проверяем, завершился ли успешно
if [ $? -ne 0 ]; then
  echo "Ansible завершился с ошибкой. Лог: ${ANSIBLE_LOG}"
  tail -n 20 "${ANSIBLE_LOG}"
  exit 1
fi

echo "✅ Ansible успешно выполнен."

# Проверяем, создан ли лог
if [ ! -f "${LOG_FILE}" ]; then
  echo "Файл лога не создан: ${LOG_FILE}"
  exit 1
fi

echo "Лог аудита создан: ${LOG_FILE}"
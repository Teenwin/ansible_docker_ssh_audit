# tasks_from_work
1. Ansible-роль ssh_audit запускается в докер контейнере через compose file вместе с целевым контейнером для тестирования(ssh-target), пример логов закрепил в директорию ./example_logs
2. EDA Job monitoring script назодиться по пути ./eda_job_monitoring/eda_job_monitoring.py, запускается через python3 ./eda_job_monitoring.py -h (подсказка), можно использовать например со своим префиксом (--prefix ansible) пример логов закрепил в директорию ./example_logs
3. Вспомогательный скрипт, находится по пути ./scripts , запускается python3 ./parse_ssh_config.py [первым аргументом указывается конфиг sshd] [вторым аргументом указывается эталонный файл, лежит там же где и скрипт]
4. workflow github лежит по пути ./github/workflows/workflow
   - проверка линт
   - билд контейнеров в докер компос, запуск роли через entrypoint контейнера ansible-container
   - проверка логов(с каким результатом отработал плэйбук с хоста-контроллера на хост ssh-target) с записью артефакта и проверкой валидности через jq

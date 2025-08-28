# Dockerfile
FROM alpine:3.22.1

# Установка Ansible и зависимостей
RUN apk add --no-cache \
    ansible \
    openssh \
    python3 \
    py3-pip \
    jq \
    curl

## Установка Python-зависимостей (для аудитора)
#COPY requirements.txt /tmp/
#RUN pip3 install -r /tmp/requirements.txt
#
## Копируем Ansible-файлы
#COPY ansible/ /ansible/
#COPY config/ /config/
#COPY scripts/ /scripts/
#
## Делаем entrypoint исполняемым
#COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh
#
## Монтируем директорию для логов
#RUN mkdir -p /logs
#
## Запуск роли при старте
#ENTRYPOINT ["/entrypoint.sh"]
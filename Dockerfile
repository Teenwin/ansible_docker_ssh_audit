# DEBUG закоментировать ENTRYPOINT
# build container
# docker(or podman) build . -t <name_image:tag>
# start пробрасываем локальный сокет ssh в контейнер при старте
# docker(or podman) run -v $SSH_AUTH_SOCK:/ssh-agent <name_container:tag>

FROM alpine:3.22.1
ENV SSH_AUTH_SOCK=/ssh-agent
ENV ANSIBLE_CONFIG=/ansible/ansible.cfg
RUN apk add --no-cache ansible openssh python3 py3-pip jq curl
COPY ./ansible/ /ansible/
#COPY config/ /config/
#COPY ./scripts/ /scripts/
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir -p /logs

ENTRYPOINT ["/entrypoint.sh"]
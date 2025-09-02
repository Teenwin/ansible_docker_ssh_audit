#RANDOM := $(shell bash -c 'echo $$RANDOM')
ANSIBLE_LINT = ansible-lint
#ANSIBLE_LINT_CONFIG = .ansible-lint
ANSIBLE_PLAYBOOKS_DIR = ./ansible/playbooks
YAML_LINT = yamllint
YAML_LINT_CONFIG = ./.yamllint.yml
CONTAINER_BUILD_PROGRAMM = podman #docker
IMAGE_NAME = ansible_ssh_audit_job
IMAGE_TAG = 4
REPOSITORY = localhost


.PHONY: lint lint-ansible lint-yaml build test log-check

lint: lint-ansible lint-yaml

lint-ansible:
	@if command -v $(ANSIBLE_LINT) > /dev/null 2>&1; \
	then $(ANSIBLE_LINT) $(ANSIBLE_PLAYBOOKS_DIR); \
	else echo "Программа ansible-lint отсутствует устанавливаю ansible-lint через apt"; \
	sudo apt install $(ANSIBLE_LINT); \
	echo "$(ANSIBLE_LINT) устанавлен, запустите команду make еще раз!!!"; \
	$(ANSIBLE_LINT) $(ANSIBLE_PLAYBOOKS_DIR)
	fi

lint-yaml:
	@if $(YAML_LINT) $(YAML_LINT_CONFIG) $(ANSIBLE_PLAYBOOKS_DIR) 2>&1; \
	then echo "Проверка $(YAML_LINT) завершилась успешно"; exit 0; \
	else echo "Проверка $(YAML_LINT) завершилась с ошибкой "; \
	fi

build: lint
	@echo "start build image"
	$(CONTAINER_BUILD_PROGRAMM) build --no-cache . -t $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "Образ $(CONTAINER_BUILD_PROGRAMM) с названием $(IMAGE_NAME):$(IMAGE_TAG) собран!"

test-local: 
	@if $(CONTAINER_BUILD_PROGRAMM) image list --format "{{.Repository}}:{{.Tag}}" | grep -q "$(REPOSITORY)/$(IMAGE_NAME):$(IMAGE_TAG)"; then \
	echo "SSH_AUTH_SOCK=$$SSH_AUTH_SOCK"; \
	$(CONTAINER_BUILD_PROGRAMM) run -d --name $(IMAGE_NAME) -v $$SSH_AUTH_SOCK:/ssh-agent $(IMAGE_NAME):$(IMAGE_TAG); \
	else echo "Образ не найден запуск make build"; \
	make build; \
	echo "SSH_AUTH_SOCK=$$SSH_AUTH_SOCK"; \
	$(CONTAINER_BUILD_PROGRAMM) run -d --name $(IMAGE_NAME) -v $$SSH_AUTH_SOCK:/ssh-agent $(IMAGE_NAME):$(IMAGE_TAG); \
	fi 

test-ci:
	$(CONTAINER_BUILD_PROGRAMM) run --name $(IMAGE_NAME) \
	$(REPOSITORY)/$(IMAGE_NAME):$(IMAGE_TAG)

log-check:
	@if $(CONTAINER_BUILD_PROGRAMM) logs $(IMAGE_NAME) | jq -c . 2>&1 ; \
	then echo "Лог аудита ssh, сгенерированный в JSON извлечен"; \
	else echo "Извлечь лог аудита ssh не удалось"; \
	fi 

#clean-image:

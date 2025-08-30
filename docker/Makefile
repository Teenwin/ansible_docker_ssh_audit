ANSIBLE_LINT = ansible-lint
#ANSIBLE_LINT_CONFIG = .ansible-lint
ANSIBLE_PLAYBOOKS_DIR = ./ansible/playbooks
YAML_LINT = yamllint
YAML_LINT_CONFIG = ./.yamllint.yml
CONTAINER_BUILD_PROGRAMM = podman#docke
IMAGE_NAME_TAG = ansible_ssh_audit_job:4

.PHONY: lint lint-ansible lint-yaml build test

lint: lint-ansible lint-yaml

lint-ansible:
	@if command -v $(ANSIBLE_LINT) > /dev/null 2>&1; \
	then $(ANSIBLE_LINT) $(ANSIBLE_PLAYBOOKS_DIR); \
	else echo "Программа ansible-lint отсутствует устанавливаю ansible-lint через apt"; \
	sudo apt install $(ANSIBLE_LINT); \
	echo "$(ANSIBLE_LINT) устанавлен, запустите команду make еще раз!!!"; \
	fi

lint-yaml:
	@if $(YAML_LINT) $(YAML_LINT_CONFIG) $(ANSIBLE_PLAYBOOKS_DIR) 2>&1; \
	then echo "Проверка $(YAML_LINT) завершилась успешно"; exit 0; \
	else echo "Проверка $(YAML_LINT) завершилась с ошибкой "; \
	fi

build: lint
	@echo "start build image"
	$(CONTAINER_BUILD_PROGRAMM) build --no-cache . -t $(IMAGE_NAME_TAG)
	@echo "Образ $(CONTAINER_BUILD_PROGRAMM) с названием $(IMAGE_NAME_TAG) собран!"

test: 
	@echo "SSH_AUTH_SOCK=$$SSH_AUTH_SOCK"
	@$(CONTAINER_BUILD_PROGRAMM) run -v $$SSH_AUTH_SOCK:/ssh-agent $(IMAGE_NAME_TAG)


#clean-image:

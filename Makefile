#RANDOM := $(shell bash -c 'echo $$RANDOM')
ANSIBLE_LINT = ansible-lint
#ANSIBLE_LINT_CONFIG = .ansible-lint
ANSIBLE_PLAYBOOKS_DIR = ./ansible-container/ansible
YAML_LINT = yamllint
YAML_LINT_CONFIG = ./.yamllint.yml
CONTAINER_BUILD_PROGRAMM = docker#podman


.PHONY: lint lint-ansible lint-yaml build-test-local log-check clean-image

lint: lint-ansible lint-yaml

lint-ansible:
	@if command -v $(ANSIBLE_LINT) > /dev/null 2>&1; \
	then $(ANSIBLE_LINT) $(ANSIBLE_PLAYBOOKS_DIR); \
	else echo "Программа ansible-lint отсутствует устанавливаю ansible-lint через apt"; \
	sudo apt install $(ANSIBLE_LINT); \
	echo "$(ANSIBLE_LINT) устанавлен, запустите команду make еще раз!!!"; \
	$(ANSIBLE_LINT) $(ANSIBLE_PLAYBOOKS_DIR); \
	fi

lint-yaml:
	@if $(YAML_LINT) $(YAML_LINT_CONFIG) $(ANSIBLE_PLAYBOOKS_DIR) 2>&1; \
	then echo "Проверка $(YAML_LINT) завершилась успешно"; exit 0; \
	else echo "Проверка $(YAML_LINT) завершилась с ошибкой "; \
	fi


build-test-local: 
	$(CONTAINER_BUILD_PROGRAMM)-compose up -d --build

check-logs: 
	$(CONTAINER_BUILD_PROGRAMM) logs ansible-container | jq .

clean-image:
	docker-compose down --rmi all

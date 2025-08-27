#!/usr/bin/env python3

import docker
import json
import sys
import argparse
from datetime import datetime, timedelta, timezone
import socket
import os

# Настройка аргументов
parser = argparse.ArgumentParser(description="Monitor EDA Ansible jobs (containerized)")
parser.add_argument('--prefix', default='ansible-job-', help='Container name prefix (default: ansible-job-)')
parser.add_argument('--hours', type=int, default=24, help='Check execution within N hours (default: 24)')
parser.add_argument('--output', help='Output file (default: stdout)')
args = parser.parse_args()

# Константы
CONTAINER_PREFIX = args.prefix
TIME_WINDOW_HOURS = args.hours
TIME_WINDOW = timedelta(hours=TIME_WINDOW_HOURS)

# Получаем клиент Docker
try:
    client = docker.from_env()
except Exception as e:
    print(f"Error connecting to Docker: {e}", file=sys.stderr)
    sys.exit(1)

# Получаем hostname
HOSTNAME = socket.gethostname()

# Получаем текущее время в UTC
NOW = datetime.now(timezone.utc)

# Функция парсинга времени из Docker (формат: 2025-07-01T01:01:00Z)
def parse_docker_time(time_str):
    if time_str.endswith('Z'):
        time_str = time_str[:-1] + '+00:00'
    return datetime.fromisoformat(time_str)

# Основная логика
def main():
    report = {
        "timestamp": NOW.isoformat().replace('+00:00', 'Z'),
        "host": HOSTNAME,
        "ansible_version": "unknown",
        "ansible_user": "unknown",
        "message": {
            "status": "healthy",
            "jobs": {}
        }
    }

    containers = client.containers.list(all=True, filters={"name": CONTAINER_PREFIX})

    any_unhealthy = False

    for container in containers:
        name = container.name

        # Извлекаем ansible_version и ansible_user из env (или labels)
        attrs = container.attrs
        env_vars = attrs.get("Config", {}).get("Env") or []
        version = "unknown"
        user = "unknown"
        for env in env_vars:
            if env.startswith("ANSIBLE_VERSION="):
                version = env.split("=", 1)[1]
            elif env.startswith("ANSIBLE_USER="):
                user = env.split("=", 1)[1]

        # Обновляем глобальные значения (берём из первого контейнера)
        if report["ansible_version"] == "unknown":
            report["ansible_version"] = version
        if report["ansible_user"] == "unknown":
            report["ansible_user"] = user

        # Извлекаем время запуска
        try:
            started_at = parse_docker_time(attrs["State"]["StartedAt"])
        except Exception as e:
            started_at = None

        # Проверяем, завершился ли контейнер успешно
        finished_at = None
        exit_code = None
        if attrs["State"].get("FinishedAt") != "0001-01-01T00:00:00Z" and attrs["State"].get("FinishedAt"):
            try:
                finished_at = parse_docker_time(attrs["State"]["FinishedAt"])
                exit_code = attrs["State"].get("ExitCode")
            except Exception as e:
                pass

        # Логика проверки
        if started_at is None:
            status_msg = "never_started"
            any_unhealthy = True
        else:
            time_diff = NOW - started_at
            if time_diff <= TIME_WINDOW:
                # Контейнер запускался в нужное окно
                if finished_at is None or (exit_code == 0):
                    status_msg = f"executed_at: {started_at.isoformat().replace('+00:00', 'Z')}"
                else:
                    status_msg = f"executed_at: {started_at.isoformat().replace('+00:00', 'Z')} (failed: exit {exit_code})"
                    any_unhealthy = True
            else:
                # Запускался, но слишком давно
                status_msg = f"last_seen: {started_at.isoformat().replace('+00:00', 'Z')}"
                any_unhealthy = True

        report["message"]["jobs"][name] = status_msg

    # Обновляем статус
    if any_unhealthy:
        report["message"]["status"] = "unhealthy"

    # Вывод
    output_data = json.dumps(report, indent=2) if args.output else json.dumps(report)
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output_data + '\n')
    else:
        print(output_data)

if __name__ == "__main__":
    main()

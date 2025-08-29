#!/usr/bin/env python3

import sys
import argparse
import json
import re
from pathlib import Path

# Парсинг аргументов
parser = argparse.ArgumentParser(description="Audit sshd_config against a baseline JSON")
parser.add_argument('sshd_config', type=Path, help='Path to sshd_config file')
parser.add_argument('baseline', type=Path, help='Path to baseline JSON file')
args = parser.parse_args()

def parse_sshd_config(filepath):
    """Парсит sshd_config и возвращает словарь параметров."""
    config = {}
    with open(filepath, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith('#') or line.startswith('Match'):
                continue
            # Убираем комментарии в строке
            line = re.split(r'\s+#', line)[0]
            parts = re.split(r'\s+', line, 1)
            if len(parts) != 2:
                continue
            key, value = parts[0].strip(), parts[1].strip()
            config[key] = value
    return config

def main():
    # Проверка существования файлов
    if not args.sshd_config.exists():
        print(json.dumps({
            "status": "error",
            "message": f"sshd_config file not found: {args.sshd_config}"
        }), file=sys.stderr)
        sys.exit(1)

    if not args.baseline.exists():
        print(json.dumps({
            "status": "error",
            "message": f"Baseline file not found: {args.baseline}"
        }), file=sys.stderr)
        sys.exit(1)

    try:
        # Читаем эталон
        with open(args.baseline, 'r') as f:
            baseline = json.load(f)

        # Читаем текущий sshd_config
        current_config = parse_sshd_config(args.sshd_config)

        # Сравниваем
        compliant = True
        audit_result = {}

        for param, expected_value in baseline.items():
            actual_value = current_config.get(param)
            if actual_value is None:
                audit_result[param] = f"missing (expected: {expected_value})"
                compliant = False
            elif actual_value != expected_value:
                audit_result[param] = f"mismatch: got '{actual_value}', expected '{expected_value}'"
                compliant = False
            else:
                audit_result[param] = f"ok: {actual_value}"

        # Формируем вывод
        result = {
            "timestamp": None,  # может быть добавлено при интеграции
            "host": None,
            "message": {
                "status": "compliant" if compliant else "non-compliant",
                "audit": "sshd_config",
                "results": audit_result
            }
        }

        print(json.dumps(result, indent=2))

    except Exception as e:
        print(json.dumps({
            "status": "error",
            "message": f"Unexpected error: {str(e)}"
        }), file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

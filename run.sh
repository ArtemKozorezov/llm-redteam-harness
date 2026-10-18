#!/bin/bash
set -e

echo "=== 1. Створення необхідних папок ==="
mkdir -p models reports

echo "=== 2. Запуск статичного сканування артефактів ==="
export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8
modelscan -p ./models/ > reports/modelscan-report.txt || true
fickling ./models/legacy_classifier.pkl >> reports/fickling-report.txt || true

echo "=== 3. Запуск Promptfoo Red-Teaming атак ==="
export NODE_NO_WARNINGS=1
promptfoo eval --config promptfooconfig.yaml -o reports/vulnerability_report.html -o reports/vulnerability_report.json

echo "=== Готово! Усі звіти збережено у директорії /reports ==="
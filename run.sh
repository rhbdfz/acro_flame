#!/bin/bash

# Скрипт для быстрого запуска игры Arcomage Clone

echo "=== Arcomage Clone - Запуск игры ==="
echo

# Проверяем наличие Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter не найден! Установите Flutter SDK."
    echo "   Инструкции: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter найден"

# Проверяем наличие зависимостей
if [ ! -d ".dart_tool" ]; then
    echo "📦 Устанавливаем зависимости..."
    flutter pub get
fi

# Проверяем наличие устройств
DEVICES=$(flutter devices --machine 2>/dev/null | grep -o '"id"' | wc -l)
if [ "$DEVICES" -eq 0 ]; then
    echo "⚠️  Устройства не найдены. Проверьте подключение эмулятора или устройства."
    echo "   Для создания эмулятора: flutter emulators --create"
    exit 1
fi

echo "📱 Устройства найдены: $DEVICES"
echo

# Запуск игры
echo "🎮 Запускаем Arcomage Clone..."
flutter run

echo
echo "🎉 Игра завершена!"

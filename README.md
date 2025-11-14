# FitTimer — simple interval training timer

A minimal cross‑platform interval training timer built with Flutter.
This repository contains a standard Flutter project with app sources and platform files.

## Features
- Configure a sequence of blocks and items (exercise/rest)
- 10‑second preparation countdown
- Audio cues: 3‑2‑1 countdown, finish, and mid‑point of long intervals
- Material UI with Material 3 support

## Screenshots
- Setup screen: ![Setup Screen](docs/screenshot_setup_2025-11-14.png)

### App Store (iPhone)
- 6.7" portrait: `docs/store/screenshot_setup_iphone_6.7_1290x2796.png`, `docs/store/screenshot_timer_iphone_6.7_1290x2796.png`
- 6.5" portrait: `docs/store/screenshot_setup_iphone_6.5_1284x2778.png`, `docs/store/screenshot_timer_iphone_6.5_1284x2778.png`

## Quick Start
- Install Flutter SDK.
- Run `flutter pub get`.
- List devices: `flutter devices` and start: `flutter run -d <deviceId>`.

## Audio
Uses `audioplayers` and generated WAV for playback.
On web, audio may require a user gesture due to autoplay policies.

## Structure
- `lib/` — app sources (pages, timer logic, audio)
- `pubspec.yaml` — dependencies and metadata
- `docs/` — screenshots and documentation

## Help
Common platform‑specific notes and troubleshooting are in `HELP.md`.

---

# FitTimer — простой таймер интервальных тренировок (русская версия)

Минимальный кроссплатформенный таймер интервальных тренировок на Flutter.
Репозиторий содержит стандартный Flutter‑проект с исходниками приложения и платформенными файлами.

## Возможности
- Настройка последовательности блоков и элементов (упражнение/пауза)
- Подготовительный отсчёт 10 секунд
- Звуковые сигналы: обратный отсчёт 3–2–1, завершение и середина длинных интервалов
- Материальный интерфейс, поддержка Material 3

## Скриншот
- Начальный экран: ![Начальный экран](docs/screenshot_setup_2025-11-14.png)

### Для App Store (iPhone)
- 6.7" портрет: `docs/store/screenshot_setup_iphone_6.7_1290x2796.png`, `docs/store/screenshot_timer_iphone_6.7_1290x2796.png`
- 6.5" портрет: `docs/store/screenshot_setup_iphone_6.5_1284x2778.png`, `docs/store/screenshot_timer_iphone_6.5_1284x2778.png`

## Быстрый старт
- Установите Flutter SDK.
- Выполните `flutter pub get`.
- Посмотрите устройства: `flutter devices` и запустите: `flutter run -d <deviceId>`.

## Звук
Используется `audioplayers` и генерация WAV. На web воспроизведение может требовать
пользовательское действие из‑за политик автоплея.

## Структура
- `lib/` — исходники приложения (страницы, логика таймера, звук)
- `pubspec.yaml` — зависимости и метаданные
- `docs/` — скриншоты и документация

## Помощь
Замечания по платформам и типичные решения — в `HELP.md`.

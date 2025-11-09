# Flutter Timer (lib-only)

Минимальный проект таймера интервальных тренировок в формате "source-only":
в репозитории хранятся только `lib/` и `pubspec.yaml`. Платформенные папки
(`android/`, `ios/`, `web/` и т.д.) каждый пользователь генерирует под своё
устройство.

## Возможности
- Настройка последовательности блоков и элементов (упражнение/пауза)
- Подготовительный таймер (10 секунд)
- Звуковые сигналы (обратный отсчёт 3–2–1, завершение, половина длинных интервалов)
- UI на Material, поддержка Material 3

## Скриншоты

Начальный экран (настройка последовательности):

![Setup Screen](docs/screenshot-setup.png)

Экран работы таймера:

![Running Screen](docs/screenshot-running.png)

## Как запустить

1. Установите Flutter SDK и Android SDK.
2. Создайте окружение проекта:
   - В существующем пустом каталоге выполните: `flutter create .`
   - Либо создайте новый проект через IDE и замените его `lib/` и `pubspec.yaml`
     на содержимое из этого репозитория.
3. Установите зависимости: `flutter pub get`.
4. Запустите эмулятор Android (или подключите устройство) и выполните:
   - `flutter emulators` — список эмуляторов
   - `flutter emulators --launch <name>` — запуск эмулятора
   - `flutter run -d <deviceId>` — запуск приложения

### Если видите чёрный экран
- Запустите с программным рендерингом:
  `flutter run -d <deviceId> --enable-software-rendering`
- Либо отключите Impeller:
  `flutter run -d <deviceId> --no-enable-impeller`
- В AVD Manager переключите Graphics на "Software" или "ANGLE" и сделайте Cold Boot.

## Звук
Для генерации и проигрывания звука используется `audioplayers` и собственный
генератор WAV (`lib/features/timer/infra/beep_generator.dart`). На web играет
через data URL, на Android/iOS — через временный WAV-файл.


# HELP / Troubleshooting

## Быстрый старт
- `flutter pub get`
- Запустите эмулятор: `flutter emulators --launch <name>`
- `flutter run -d <deviceId>`

## Типичные проблемы

### Чёрный экран на Android эмуляторе
Причина: Impeller/OpenGL на некоторых AVD может давать чёрный экран.

Решения:
- `flutter run -d <deviceId> --enable-software-rendering`
- `flutter run -d <deviceId> --no-enable-impeller`
- В AVD Manager → Graphics: "Software" или "Compatibility (ANGLE)"; затем Cold Boot.

### Звук не воспроизводится
- Убедитесь, что устройство не в режиме без звука.
- На web — звук может требовать жест взаимодействия (политики автоплея).
- На Android/iOS — генерируется временный WAV в `systemTemp`, плеер 
  `audioplayers` воспроизводит файл через `DeviceFileSource`.

### Иконки выглядят разного размера на Web / не загружаются
- Причина: дев‑сервер/кэш браузера не подхватывает шрифт Material Icons, в логах виден
  запрос `assets/FontManifest.json` с ошибкой.
- Решения:
  - Полностью перезапустите дев‑сервер: остановите текущий `flutter run -d web-server`,
    запустите заново.
  - Выполните жесткую перезагрузку страницы (Cmd/Ctrl+Shift+R), чтобы обновить кэш шрифтов.
  - Если используете дополнительный прокси/cdn — отключите, проверьте локально.
  - В коде можно задать единый размер через `Icon(size: 20)` и `iconTheme` в `MaterialApp`.

### Где править последовательность таймера?
`lib/timer/timer_page.dart`, поле `_sequence`.

### Как сделать скриншоты
- Запустите приложение в debug режиме.
- Выполните: `flutter screenshot -o docs/screenshot-setup.png -d <deviceId>`.
- Нажмите "Старт" в приложении.
- Выполните: `flutter screenshot -o docs/screenshot-running.png -d <deviceId>`.

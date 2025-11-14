import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SimpleLocalizations {
  final Locale locale;
  SimpleLocalizations(this.locale);

  static const LocalizationsDelegate<SimpleLocalizations> delegate = _SimpleLocalizationsDelegate();

  static SimpleLocalizations of(BuildContext context) {
    return Localizations.of<SimpleLocalizations>(context, SimpleLocalizations)!;
  }

  String get appTitle => _t('appTitle');
  String get start => _t('start');
  String get pause => _t('pause');
  String get stop => _t('stop');
  String get getReady => _t('getReady');
  String get replayPrepare => _t('replayPrepare');
  String get rest => _t('rest');
  String get exercise => _t('exercise');
  String get setup => _t('setup');
  String get closeSetup => _t('closeSetup');
  String get mute => _t('mute');
  String get unmute => _t('unmute');
  String get resetToDefault => _t('resetToDefault');
  String get collapse => _t('collapse');
  String get timerSetup => _t('timerSetup');
  String get addBlock => _t('addBlock');
  String get add => _t('add');
  String get timerBlocks => _t('timerBlocks');
  String get noBlocks => _t('noBlocks');
  String get blockName => _t('blockName');
  String get repeats => _t('repeats');
  String get timersInBlock => _t('timersInBlock');
  String get name => _t('name');
  String get mmss => _t('mmss');
  String get addTimer => _t('addTimer');
  String get block => _t('block');
  String get startBlockName => _t('startBlockName');

  String exerciseN(int n) => _tFmt('exerciseN', {'n': n});
  String restN(int n) => _tFmt('restN', {'n': n});

  String repeatOf(int x, int y) => _tFmt('repeatOf', {'x': x, 'y': y});
  String blockOf(int x, int y) => _tFmt('blockOf', {'x': x, 'y': y});
  String timerOf(int x, int y) => _tFmt('timerOf', {'x': x, 'y': y});

  String _t(String key) {
    final map = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return map[key] ?? key;
  }

  String _tFmt(String key, Map<String, Object> vars) {
    var s = _t(key);
    vars.forEach((k, v) => s = s.replaceAll('{$k}', v.toString()));
    return s;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Interval Training Timer',
      'start': 'Start',
      'pause': 'Pause',
      'stop': 'Stop',
      'getReady': 'Get ready',
      'replayPrepare': 'Prepare to replay',
      'rest': 'Rest',
      'exercise': 'Exercise',
      'repeatOf': 'Repeat {x} of {y}',
      'blockOf': 'Block {x} of {y}',
      'timerOf': 'Timer {x} of {y}',
      'setup': 'Setup',
      'closeSetup': 'Close setup',
      'mute': 'Mute',
      'unmute': 'Unmute',
      'resetToDefault': 'Reset to default',
      'collapse': 'Collapse',
      'timerSetup': 'Timer Setup',
      'addBlock': 'Add block',
      'add': 'Add',
      'timerBlocks': 'Timer blocks:',
      'noBlocks': 'No blocks. Add a block to get started.',
      'blockName': 'Block name',
      'repeats': 'Repeats',
      'timersInBlock': 'Timers in block:',
      'name': 'Name',
      'mmss': 'MM:SS',
      'addTimer': 'Add timer',
      'block': 'Block',
      'startBlockName': 'Start block',
      'exerciseN': 'Exercise {n}',
      'restN': 'Rest {n}',
    },
    'ru': {
      'appTitle': 'Таймер интервальных тренировок',
      'start': 'Старт',
      'pause': 'Пауза',
      'stop': 'Стоп',
      'getReady': 'Подготовка',
      'replayPrepare': 'Приготовьтесь к повтору',
      'rest': 'Отдых',
      'exercise': 'Упражнение',
      'repeatOf': 'Повтор {x} из {y}',
      'blockOf': 'Блок {x} из {y}',
      'timerOf': 'Таймер {x} из {y}',
      'setup': 'Настройки',
      'closeSetup': 'Закрыть настройки',
      'mute': 'Выключить звук',
      'unmute': 'Включить звук',
      'resetToDefault': 'Сбросить по умолчанию',
      'collapse': 'Свернуть',
      'timerSetup': 'Настройка таймера',
      'addBlock': 'Добавить блок',
      'add': 'Добавить',
      'timerBlocks': 'Блоки таймера:',
      'noBlocks': 'Нет блоков. Добавьте блок, чтобы начать.',
      'blockName': 'Название блока',
      'repeats': 'Повторы',
      'timersInBlock': 'Таймеры в блоке:',
      'name': 'Название',
      'mmss': 'ММ:СС',
      'addTimer': 'Добавить таймер',
      'block': 'Блок',
      'startBlockName': 'Стартовый блок',
      'exerciseN': 'Упражнение {n}',
      'restN': 'Отдых {n}',
    },
  };
}

class _SimpleLocalizationsDelegate extends LocalizationsDelegate<SimpleLocalizations> {
  const _SimpleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<SimpleLocalizations> load(Locale locale) async {
    return SimpleLocalizations(locale);
  }

  @override
  bool shouldReload(_SimpleLocalizationsDelegate old) => false;
}

const kDefaultLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  SimpleLocalizations.delegate,
];

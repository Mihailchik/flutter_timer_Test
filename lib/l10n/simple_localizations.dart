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

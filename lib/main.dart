import 'package:flutter/material.dart';
import 'l10n/simple_localizations.dart';
import 'timer/timer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Training Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: kDefaultLocalizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: const TimerPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'timer_model.dart';
import 'timer_service.dart';
import 'timer_setup_widget.dart';
import 'timer_display_widget.dart';
import 'timer_controls_widget.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late TimerService _timerService;

  // Updated sequence according to requirements:
  // 1 block with alternating exercise and pause timers
  TimerSequence _sequence = TimerSequence(
    blocks: [
      TimerBlock(
        name: 'Блок 1',
        repeats: 1,
        items: [
          TimerItem(name: 'Упражнение 1', duration: 4, isPause: false),
          TimerItem(name: 'Отдых 1', duration: 2, isPause: true),
          TimerItem(name: 'Упражнение 2', duration: 2, isPause: false),
        ],
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.setSequence(_sequence);
    // Добавляем слушатель изменений таймера
    _timerService.addListener(_onTimerChanged);
  }

  @override
  void dispose() {
    // Удаляем слушатель изменений таймера
    _timerService.removeListener(_onTimerChanged);
    _timerService.dispose();
    super.dispose();
  }

  void _onTimerChanged() {
    // Обновляем состояние виджета при изменении таймера
    setState(() {});
  }

  void _updateSequence(TimerSequence sequence) {
    setState(() {
      _sequence = sequence;
      _timerService.setSequence(sequence);
    });
  }

  void _startTimer() {
    debugPrint('=== START BUTTON PRESSED ===');
    debugPrint('Timer service status before start: ${_timerService.status}');
    _timerService.start();
    debugPrint('Timer service status after start: ${_timerService.status}');

    // Force UI update
    setState(() {});
  }

  void _pauseTimer() {
    _timerService.pause();
  }

  void _resetTimer() {
    _timerService.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Таймер интервальных тренировок'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
              if (_timerService.status == TimerStatus.stopped)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: TimerSetupWidget(
                          sequence: _sequence,
                          onSequenceUpdate: _updateSequence,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startTimer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Старт',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TimerDisplayWidget(timerService: _timerService),
                      ),
                      const SizedBox(height: 20),
                      TimerControlsWidget(
                        timerService: _timerService,
                        onStart: _startTimer,
                        onPause: _pauseTimer,
                        onReset: _resetTimer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

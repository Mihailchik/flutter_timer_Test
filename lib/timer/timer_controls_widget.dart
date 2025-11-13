import 'package:flutter/material.dart';
import '../l10n/simple_localizations.dart';
import 'timer_service.dart';

class TimerControlsWidget extends StatelessWidget {
  final TimerService timerService;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onReplay;

  const TimerControlsWidget({
    super.key,
    required this.timerService,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = size.width < 360 || size.height < 600;
    final isRunning = timerService.status == TimerStatus.running;
    final isReadyToStart = timerService.status == TimerStatus.stopped ||
        timerService.status == TimerStatus.paused;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Center(
        child: ElevatedButton(
          onPressed: isRunning ? onPause : onStart,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
            backgroundColor: isRunning
                ? Colors.orange
                : (isReadyToStart ? Colors.green : Colors.grey),
            fixedSize: Size(compact ? 56 : 88, compact ? 56 : 88),
            alignment: Alignment.center,
          ),
          child: Icon(
            isRunning ? Icons.pause : Icons.play_arrow,
            size: compact ? 32 : 44,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

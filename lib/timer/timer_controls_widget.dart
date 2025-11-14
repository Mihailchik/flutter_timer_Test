import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (timerService.status == TimerStatus.stopped ||
              timerService.status == TimerStatus.paused)
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                backgroundColor: Colors.green,
                fixedSize: Size(compact ? 44 : 72, compact ? 44 : 72),
                alignment: Alignment.center,
              ),
              child: Icon(
                Icons.play_arrow,
                size: compact ? 28 : 36,
                color: Colors.white,
              ),
            ),
          if (timerService.status == TimerStatus.running)
            ElevatedButton(
              onPressed: onPause,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                backgroundColor: Colors.orange,
                fixedSize: Size(compact ? 44 : 72, compact ? 44 : 72),
                alignment: Alignment.center,
              ),
              child: Icon(Icons.pause,
                  size: compact ? 28 : 36, color: Colors.white),
            ),
          if (timerService.status != TimerStatus.stopped)
            ElevatedButton(
              onPressed: onReplay,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                backgroundColor: Colors.blue,
                fixedSize: Size(compact ? 44 : 72, compact ? 44 : 72),
                alignment: Alignment.center,
              ),
              child: Icon(Icons.replay,
                  size: compact ? 28 : 36, color: Colors.white),
            ),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
              backgroundColor: Colors.red,
              fixedSize: Size(compact ? 44 : 72, compact ? 44 : 72),
              alignment: Alignment.center,
            ),
            child:
                Icon(Icons.stop, size: compact ? 28 : 36, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

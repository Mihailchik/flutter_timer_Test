import 'package:flutter/material.dart';
import 'timer_service.dart';

class TimerControlsWidget extends StatelessWidget {
  final TimerService timerService;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const TimerControlsWidget({
    super.key,
    required this.timerService,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (timerService.status == TimerStatus.stopped ||
              timerService.status == TimerStatus.paused)
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: const CircleBorder(),
                backgroundColor: Colors.green,
                minimumSize: const Size(70, 70),
                maximumSize: const Size(70, 70),
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 35,
                color: Colors.white,
              ),
            ),
          if (timerService.status == TimerStatus.running)
            ElevatedButton(
              onPressed: onPause,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: const CircleBorder(),
                backgroundColor: Colors.orange,
                minimumSize: const Size(70, 70),
                maximumSize: const Size(70, 70),
              ),
              child: const Icon(Icons.pause, size: 35, color: Colors.white),
            ),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              shape: const CircleBorder(),
              backgroundColor: Colors.red,
              minimumSize: const Size(70, 70),
              maximumSize: const Size(70, 70),
            ),
            child: const Icon(Icons.stop, size: 35, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

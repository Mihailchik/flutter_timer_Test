import 'package:flutter/material.dart';
import 'timer_service.dart';

class TimerDisplayWidget extends StatefulWidget {
  final TimerService timerService;

  const TimerDisplayWidget({super.key, required this.timerService});

  @override
  State<TimerDisplayWidget> createState() => _TimerDisplayWidgetState();
}

class _TimerDisplayWidgetState extends State<TimerDisplayWidget> {
  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения таймера
    widget.timerService.addListener(_update);
  }

  @override
  void dispose() {
    // Отписываемся от изменений таймера
    widget.timerService.removeListener(_update);
    super.dispose();
  }

  void _update() {
    // Обновляем состояние виджета при изменении таймера
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _getBlockColor(),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getDisplayTitle(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            widget.timerService.formatTime(widget.timerService.remainingTime),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 20),
          ..._getProgressInfo(),
        ],
      ),
    );
  }

  List<Widget> _getProgressInfo() {
    // Если это подготовительный таймер, не показываем информацию о блоках
    if (widget.timerService.currentPhase == TimerPhase.preparation) {
      return [];
    }

    return [
      if (widget.timerService.currentBlock != null &&
          widget.timerService.currentBlock!.repeats > 1)
        Text(
          'Повтор ${widget.timerService.currentRepeat + 1} из ${widget.timerService.currentBlock?.repeats ?? 1}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      const SizedBox(height: 10),
      Text(
        'Блок ${widget.timerService.currentBlockIndex + 1} из ${widget.timerService.sequence?.blocks.length ?? 1}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 10),
      if (widget.timerService.currentBlock != null &&
          widget.timerService.currentItem != null)
        Text(
          'Таймер ${widget.timerService.currentItemIndex + 1} из ${widget.timerService.currentBlock?.items.length ?? 1}',
          style: const TextStyle(fontSize: 16),
        ),
    ];
  }

  Color _getBlockColor() {
    switch (widget.timerService.currentPhase) {
      case TimerPhase.preparation:
        return Colors.yellow.shade100; // Желтый для подготовки
      case TimerPhase.pause:
        return Colors.red.shade100; // Красный для паузы
      case TimerPhase.exercise:
        // Зеленый для упражнения
        return Colors.green.shade100;
    }
  }

  String _getDisplayTitle() {
    switch (widget.timerService.currentPhase) {
      case TimerPhase.preparation:
        return 'Приготовьтесь';
      case TimerPhase.pause:
        final currentItem = widget.timerService.currentItem;
        return currentItem?.name ?? 'Отдых';
      case TimerPhase.exercise:
        final currentItem = widget.timerService.currentItem;
        return currentItem?.name ?? 'Упражнение';
    }
  }
}

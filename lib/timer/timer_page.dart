import 'package:flutter/material.dart';
import '../l10n/simple_localizations.dart';
import 'package:flutter/foundation.dart';
import 'timer_model.dart';
import 'timer_service.dart';
import 'timer_setup_widget.dart';
import 'timer_display_widget.dart';
import 'timer_controls_widget.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late TimerService _timerService;

  // Updated sequence according to requirements:
  // 1 блок "startBlock": 1 упражнение 1 мин, 1 отдых 30 сек
  TimerSequence _sequence = TimerSequence(
    blocks: [
      TimerBlock(
        name: 'startBlock',
        repeats: 1,
        items: [
          TimerItem(name: 'Exercise', duration: 60, isPause: false),
          TimerItem(name: 'Rest', duration: 30, isPause: true),
        ],
      ),
    ],
  );

  bool _localizedDefaultsApplied = false;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.setSequence(_sequence);
    // Добавляем слушатель изменений таймера
    _timerService.addListener(_onTimerChanged);
    // Загружаем сохранённую последовательность, если она есть
    _initLoad();
    // Загружаем настройку mute
    _timerService.loadMuted();
    // Рантайм-состояние таймера не восстанавливаем — сохраняем только конфигурацию
  }

  Future<void> _initLoad() async {
    final loaded = await _timerService.loadSequence();
    if (loaded != null) {
      _updateSequence(loaded);
    }
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
    // Сохраняем обновлённую последовательность
    _timerService.saveSequence();
  }

  void _ensureLocalizedDefaults(BuildContext context) {
    if (_localizedDefaultsApplied) return;
    final loc = SimpleLocalizations.of(context);
    // Меняем только дефолтные английские названия на локализованные
    final updatedBlocks = _sequence.blocks.map((b) {
      final updatedItems = b.items.map((it) {
        String name = it.name;
        if (name == 'Exercise') name = loc.exercise;
        if (name == 'Rest') name = loc.rest;
        if (name != it.name) {
          return TimerItem(
              name: name, duration: it.duration, isPause: it.isPause);
        }
        return it;
      }).toList();
      return TimerBlock(name: b.name, repeats: b.repeats, items: updatedItems);
    }).toList();

    final updated = TimerSequence(blocks: updatedBlocks);
    // Если что-то изменилось — применим и сохраним
    final changed =
        updated.toJson().toString() != _sequence.toJson().toString();
    if (changed) {
      _updateSequence(updated);
    }
    _localizedDefaultsApplied = true;
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

  void _replayLast() {
    _timerService.repeatLast();
    setState(() {});
  }

  void _toggleMute() {
    final newVal = !_timerService.muted;
    _timerService.setMuted(newVal);
    setState(() {});
  }

  TimerSequence _defaultSequence() {
    return TimerSequence(
      blocks: [
        TimerBlock(
          name: 'startBlock',
          repeats: 1,
          items: [
            TimerItem(name: 'Exercise', duration: 60, isPause: false),
            TimerItem(name: 'Rest', duration: 30, isPause: true),
          ],
        ),
      ],
    );
  }

  void _resetToDefaultConfig() {
    final def = _defaultSequence();
    _updateSequence(def);
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final compact = MediaQuery.of(ctx).size.width < 360;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings,
                      color: Theme.of(ctx).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Setup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Mute'),
                value: _timerService.muted,
                onChanged: (val) {
                  _timerService.setMuted(val);
                  setState(() {});
                },
                secondary: Icon(
                  _timerService.muted ? Icons.volume_off : Icons.volume_up,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _resetToDefaultConfig();
                    Navigator.of(ctx).pop();
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset to default'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 12,
                      vertical: compact ? 8 : 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.expand_less),
                  label: const Text('Collapse settings'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 12,
                      vertical: compact ? 8 : 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Автоподстановка локализованных названий элементов в стартовой конфигурации
    _ensureLocalizedDefaults(context);
    final compactHeight = MediaQuery.of(context).size.height < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(SimpleLocalizations.of(context).appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Setup',
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
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
                            child: Text(
                              SimpleLocalizations.of(context).start,
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
                          child:
                              TimerDisplayWidget(timerService: _timerService),
                        ),
                        SizedBox(height: compactHeight ? 12 : 20),
                        TimerControlsWidget(
                          timerService: _timerService,
                          onStart: _startTimer,
                          onPause: _pauseTimer,
                          onReset: _resetTimer,
                          onReplay: _replayLast,
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

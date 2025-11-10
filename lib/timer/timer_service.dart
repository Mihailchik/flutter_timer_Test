import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'timer_model.dart';
import '../features/timer/infra/sound_service.dart';

enum TimerStatus { stopped, running, paused }

// Добавим тип для идентификации текущего состояния таймера
enum TimerPhase { preparation, exercise, pause }

class TimerService extends ChangeNotifier {
  TimerStatus _status = TimerStatus.stopped;
  Timer? _timer;

  TimerSequence? _sequence;
  int _currentBlockIndex = 0;
  int _currentItemIndex = 0; // Index of current timer item within block
  int _remainingTime = 0;
  int _currentRepeat = 0; // Current repeat within the block

  // Флаг для отслеживания завершения подготовительного таймера
  bool _preparationCompleted = false;

  // Длительность стартового таймера (10 секунд)
  static const int preparationTime = 10;

  // Sound service для звуковых эффектов
  final SoundService _soundService = SoundService();

  // Halfway point sound flag
  bool _halfwaySoundPlayed = false;
  // End sound flag to avoid double-play and to trigger at 00
  bool _endSoundPlayed = false;
  // Second half state flag for UI highlighting
  bool _isInSecondHalf = false;

  TimerService();

  // Getters
  TimerStatus get status => _status;
  TimerSequence? get sequence => _sequence;
  int get currentBlockIndex => _currentBlockIndex;
  int get currentItemIndex => _currentItemIndex;
  int get remainingTime => _remainingTime;
  int get currentRepeat => _currentRepeat;

  TimerBlock? get currentBlock {
    if (_sequence == null || _currentBlockIndex >= _sequence!.blocks.length) {
      return null;
    }
    return _sequence!.blocks[_currentBlockIndex];
  }

  TimerItem? get currentItem {
    final block = currentBlock;
    if (block == null || _currentItemIndex >= block.items.length) {
      return null;
    }
    return block.items[_currentItemIndex];
  }

  // Set the timer sequence
  void setSequence(TimerSequence sequence) {
    _sequence = sequence;
    reset();
    notifyListeners();
  }

  // Start the timer
  void start() {
    debugPrint('=== TimerService.start() called ===');
    debugPrint('Current status: $_status');
    debugPrint('Sequence blocks count: ${_sequence?.blocks.length ?? 0}');
    debugPrint(
      'Current block index: $_currentBlockIndex, Current item index: $_currentItemIndex',
    );
    debugPrint('Current repeat: $_currentRepeat');

    if (_status == TimerStatus.stopped || _status == TimerStatus.paused) {
      debugPrint('Timer is stopped or paused, checking sequence');
      if (_sequence == null) {
        debugPrint('ERROR: Sequence is null, returning');
        return;
      }

      if (_sequence!.blocks.isEmpty) {
        debugPrint('ERROR: Sequence has no blocks, returning');
        return;
      }

      // Initialize if starting from stopped
      if (_status == TimerStatus.stopped) {
        debugPrint('Initializing timer from stopped state');
        // Начинаем со стартового таймера
        _remainingTime = preparationTime;
        _currentBlockIndex = 0;
        _currentItemIndex = 0;
        _currentRepeat = 0;
        _preparationCompleted = false;
        _halfwaySoundPlayed = false;
        _endSoundPlayed = false;
        debugPrint('Set preparation time to: $_remainingTime');
      }

      _status = TimerStatus.running;
      debugPrint('Setting status to running, starting timer');
      _startTimer();
      notifyListeners();
      debugPrint('=== TimerService.start() finished ===');
    } else {
      debugPrint('Timer is already running or in invalid state: $_status');
    }
  }

  // Pause the timer
  void pause() {
    if (_status == TimerStatus.running) {
      _timer?.cancel();
      _status = TimerStatus.paused;
      notifyListeners();
    }
  }

  // Reset the timer
  void reset() {
    debugPrint('=== TimerService.reset() called ===');
    _timer?.cancel();
    _status = TimerStatus.stopped;
    _currentBlockIndex = 0;
    _currentItemIndex = 0;
    _currentRepeat = 0;
    _remainingTime = preparationTime;
    _preparationCompleted = false;
    _halfwaySoundPlayed = false;
    _endSoundPlayed = false;

    notifyListeners();
    debugPrint('=== TimerService.reset() finished ===');
  }

  // Start the internal timer
  void _startTimer() {
    debugPrint('Starting internal timer');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint('Timer tick, calling _tick()');
      _tick();
    });
  }

  // Handle timer tick
  void _tick() {
    debugPrint('=== Timer tick ===');
    debugPrint('Status: $_status, Remaining time: $_remainingTime');
    debugPrint(
      'Block index: $_currentBlockIndex, Item index: $_currentItemIndex, Repeat: $_currentRepeat',
    );
    debugPrint('Preparation completed: $_preparationCompleted');

    // Always check if timer should be running
    if (_status != TimerStatus.running) {
      debugPrint('Timer not running, exiting tick');
      return;
    }

    // Decrement time if there's time left
    if (_remainingTime > 0) {
      _remainingTime--;
      debugPrint('Decremented time to: $_remainingTime');

      // Countdown signals at 3/2/1 seconds
      if (_remainingTime == 3) {
        debugPrint('Playing countdown sound: 3');
        _playCountdownSound(3);
      } else if (_remainingTime == 2) {
        debugPrint('Playing countdown sound: 2');
        _playCountdownSound(2);
      } else if (_remainingTime == 1) {
        debugPrint('Playing countdown sound: 1');
        _playCountdownSound(1);
      }

      // Play halfway sound if needed (только для основных блоков, не для подготовки)
      // Исключаем фазу подготовки — половинный сигнал не должен звучать на ней
      final currentItem = this.currentItem;
      if (_preparationCompleted &&
          _remainingTime > 0 && // Make sure we still have time
          currentItem != null &&
          !_halfwaySoundPlayed &&
          // Only for timers longer than 30 sec
          currentItem.duration > 30 &&
          // Halfway computed as integer division (floor), e.g., 31 -> 15
          _remainingTime == (currentItem.duration ~/ 2)) {
        debugPrint('Playing halfway sound');
        _playHalfwaySound();
        _halfwaySoundPlayed = true;
        _isInSecondHalf = true;
      }

      // If just reached 0, play end sound immediately (at 00)
      if (_remainingTime == 0 && !_endSoundPlayed) {
        debugPrint('Reached 00, playing end sound immediately');
        _playEndSound();
        _endSoundPlayed = true;
      }

      notifyListeners();
      return;
    }

    // Time is up - handle transitions
    debugPrint('Time is up, handling transition');
    // End sound уже проигран на момент достижения 00

    // Переход к следующему элементу или блоку
    _moveToNextItem();
    _endSoundPlayed = false; // reset for next item
    notifyListeners();
  }

  // Метод для перехода к следующему элементу
  void _moveToNextItem() {
    if (_sequence == null) return;

    // Если это подготовительный таймер и он еще не завершен
    if (!_preparationCompleted) {
      debugPrint('Preparation time is up, marking as completed');
      _preparationCompleted = true;

      // Переход к первому блоку
      if (_sequence!.blocks.isNotEmpty) {
        final firstBlock = _sequence!.blocks[0];
        if (firstBlock.items.isNotEmpty) {
          _currentBlockIndex = 0;
          _currentItemIndex = 0;
          _currentRepeat = 0;
          _remainingTime = firstBlock.items[0].duration;
          _halfwaySoundPlayed = false;
          _endSoundPlayed = false;
          _isInSecondHalf = false;
          debugPrint('Moved to first block item with duration $_remainingTime');
        }
      }
      return;
    }

    // Получаем текущий блок
    final currentBlock = this.currentBlock;
    if (currentBlock == null) {
      // No more blocks - timer sequence complete
      debugPrint('Timer sequence complete');
      _status = TimerStatus.stopped;
      _timer?.cancel();
      return;
    }

    // Переход к следующему элементу в блоке
    if (_currentItemIndex < currentBlock.items.length - 1) {
      // Переход к следующему элементу в текущем блоке
      _currentItemIndex++;
      _remainingTime = currentBlock.items[_currentItemIndex].duration;
      _halfwaySoundPlayed = false;
      _endSoundPlayed = false;
      _isInSecondHalf = false;
      debugPrint('Moved to next item in block with duration $_remainingTime');
      return;
    }

    // Все элементы в блоке пройдены, проверяем повторы
    if (_currentRepeat < currentBlock.repeats - 1) {
      // Переход к следующему повтору блока
      _currentRepeat++;
      _currentItemIndex = 0;
      _remainingTime = currentBlock.items[0].duration;
      _halfwaySoundPlayed = false;
      _endSoundPlayed = false;
      _isInSecondHalf = false;
      debugPrint('Moved to next repeat of block with duration $_remainingTime');
      return;
    }

    // Все повторы блока пройдены, переходим к следующему блоку
    if (_currentBlockIndex < _sequence!.blocks.length - 1) {
      // Переход к следующему блоку
      _currentBlockIndex++;
      _currentRepeat = 0;
      _currentItemIndex = 0;

      final nextBlock = _sequence!.blocks[_currentBlockIndex];
      if (nextBlock.items.isNotEmpty) {
        _remainingTime = nextBlock.items[0].duration;
        _halfwaySoundPlayed = false;
        _endSoundPlayed = false;
        _isInSecondHalf = false;
        debugPrint('Moved to next block with duration $_remainingTime');
      }
      return;
    }

    // Все блоки пройдены
    debugPrint('Timer sequence complete');
    _status = TimerStatus.stopped;
    _timer?.cancel();
  }

  // Play sound at halfway point: "бииип" (средняя длительность)
  Future<void> _playHalfwaySound() async {
    await _soundService.playBeep(
      durationMs: 200,
      frequency: 440,
      rate: 1.0,
      volume: 0.9,
    );
    debugPrint('Halfway sound played (бииип)');
  }

  // Play sound at end of timer block: "0-бииииииип" (длинный)
  Future<void> _playEndSound() async {
    await _soundService.playBeep(
      durationMs: 700,
      frequency: 440,
      rate: 1.0,
      volume: 1.0,
    );
    debugPrint('End sound played (0-бииииииип)');
  }

  // Play sound for countdown (3/2/1) с растущей длительностью: бип/биип/бииип
  Future<void> _playCountdownSound(int secondsLeft) async {
    if (secondsLeft == 3) {
      await _soundService.playBeep(
        durationMs: 120,
        frequency: 440,
        rate: 1.0,
        volume: 0.9,
      );
    } else if (secondsLeft == 2) {
      await _soundService.playBeep(
        durationMs: 180,
        frequency: 440,
        rate: 1.0,
        volume: 0.9,
      );
    } else if (secondsLeft == 1) {
      await _soundService.playBeep(
        durationMs: 240,
        frequency: 440,
        rate: 1.0,
        volume: 0.95,
      );
    }
  }

  // Динамическое форматирование времени:
  // <60 сек -> SS
  // <60 мин -> MM:SS
  // >=60 мин -> HH:MM:SS
  String formatTime(int totalSeconds) {
    if (totalSeconds < 60) {
      return totalSeconds.toString().padLeft(2, '0');
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get current phase for color coding
  TimerPhase get currentPhase {
    // Если это подготовительный таймер и он еще не завершен
    if (!_preparationCompleted && _status != TimerStatus.stopped) {
      return TimerPhase.preparation;
    }

    final currentItem = this.currentItem;
    if (currentItem == null) return TimerPhase.preparation;

    return currentItem.isPause ? TimerPhase.pause : TimerPhase.exercise;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.dispose();
    super.dispose();
  }

  // Expose UI helpers
  bool get isInSecondHalf => _isInSecondHalf;
}

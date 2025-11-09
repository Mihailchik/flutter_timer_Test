import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'timer_model.dart';

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
  static const int PREPARATION_TIME = 10;

  // Audio player for sound effects
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _beepFilePath; // Generated beep wav file path (mobile/desktop)

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
        _remainingTime = PREPARATION_TIME;
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
    _remainingTime = PREPARATION_TIME;
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
      final currentItem = this.currentItem;
      if (_remainingTime > 0 && // Make sure we still have time
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
    await _playBeep(durationMs: 200, frequency: 440, rate: 1.0, volume: 0.9);
    debugPrint('Halfway sound played (бииип)');
  }

  // Play sound at end of timer block: "0-бииииииип" (длинный)
  Future<void> _playEndSound() async {
    await _playBeep(durationMs: 700, frequency: 440, rate: 1.0, volume: 1.0);
    debugPrint('End sound played (0-бииииииип)');
  }

  // Play sound for countdown (3/2/1) с растущей длительностью: бип/биип/бииип
  Future<void> _playCountdownSound(int secondsLeft) async {
    if (secondsLeft == 3) {
      await _playBeep(durationMs: 120, frequency: 440, rate: 1.0, volume: 0.9);
    } else if (secondsLeft == 2) {
      await _playBeep(durationMs: 180, frequency: 440, rate: 1.0, volume: 0.9);
    } else if (secondsLeft == 1) {
      await _playBeep(durationMs: 240, frequency: 440, rate: 1.0, volume: 0.95);
    }
  }

  // Unified beep player: generate short WAV with requested duration/frequency
  Future<void> _playBeep({
    int durationMs = 200,
    double frequency = 440,
    double rate = 1.0,
    double volume = 0.9,
  }) async {
    try {
      await _audioPlayer.setVolume(volume);

      // Try to set playback rate (not always supported, esp. web)
      try {
        await _audioPlayer.setPlaybackRate(rate);
      } catch (e) {
        debugPrint('Playback rate not supported on this platform: $e');
      }

      // Web: play data URL WAV inline (no filesystem)
      if (kIsWeb) {
        final dataUrl = _generateBeepDataUrl(
          durationMs: durationMs,
          frequency: frequency,
          amplitude: 0.9,
        );
        debugPrint('Playing web data URL beep');
        await _audioPlayer.play(UrlSource(dataUrl));
        return;
      }

      // Non-web: generate WAV file per request and play
      final path = await _writeBeepWavFile(
        durationMs: durationMs,
        frequency: frequency,
        amplitude: 0.9,
      );
      debugPrint('Playing generated beep WAV: $path');
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('Error playing beep: $e');
    }
  }

  // Generate requested beep WAV file and return its path (non-web)
  Future<String> _writeBeepWavFile({
    required int durationMs,
    required double frequency,
    required double amplitude,
  }) async {
    // Create temp file path (overwrite each time)
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/flutter_timer_beep.wav');

    final sampleRate = 44100;
    final totalSamples = (sampleRate * durationMs / 1000).round();
    final bytes = _generateWavBytes(
      totalSamples: totalSamples,
      sampleRate: sampleRate,
      amplitude: amplitude,
      frequency: frequency,
    );
    await file.writeAsBytes(bytes, flush: true);
    _beepFilePath = file.path;
    debugPrint('Generated beep WAV at: ${file.path}');
    return _beepFilePath!;
  }

  // Generate WAV bytes with simple sinusoidal PCM data
  List<int> _generateWavBytes({
    required int totalSamples,
    required int sampleRate,
    required double amplitude,
    required double frequency,
  }) {
    // PCM 16-bit mono
    final data = BytesBuilder();
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final sample = (amplitude * sin(2 * pi * frequency * t));
      // 16-bit signed
      int s = (sample * 32767).round();
      // little-endian
      data.add([s & 0xFF, (s >> 8) & 0xFF]);
    }

    final pcm = data.toBytes();
    final byteRate = sampleRate * 2; // mono 16-bit
    final blockAlign = 2; // mono 16-bit
    final subchunk2Size = pcm.length;
    final chunkSize = 36 + subchunk2Size;

    // Build WAV header (RIFF)
    final header = BytesBuilder();
    // ChunkID 'RIFF'
    header.add('RIFF'.codeUnits);
    header.add(_le32(chunkSize));
    // Format 'WAVE'
    header.add('WAVE'.codeUnits);
    // Subchunk1ID 'fmt '
    header.add('fmt '.codeUnits);
    header.add(_le32(16)); // Subchunk1Size (PCM)
    header.add(_le16(1)); // AudioFormat PCM
    header.add(_le16(1)); // NumChannels mono
    header.add(_le32(sampleRate));
    header.add(_le32(byteRate));
    header.add(_le16(blockAlign));
    header.add(_le16(16)); // BitsPerSample
    // Subchunk2ID 'data'
    header.add('data'.codeUnits);
    header.add(_le32(subchunk2Size));

    return [...header.toBytes(), ...pcm];
  }

  List<int> _le16(int value) => [value & 0xFF, (value >> 8) & 0xFF];
  List<int> _le32(int value) => [
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ];

  // Build data URL for WAV (for web playback)
  String _generateBeepDataUrl({
    required int durationMs,
    required double frequency,
    required double amplitude,
  }) {
    final sampleRate = 44100;
    final totalSamples = (sampleRate * durationMs / 1000).round();
    final bytes = _generateWavBytes(
      totalSamples: totalSamples,
      sampleRate: sampleRate,
      amplitude: amplitude,
      frequency: frequency,
    );
    final b64 = base64Encode(bytes);
    return 'data:audio/wav;base64,$b64';
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
    _audioPlayer.dispose();
    super.dispose();
  }

  // Expose UI helpers
  bool get isInSecondHalf => _isInSecondHalf;
}

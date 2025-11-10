import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'beep_generator.dart';

class SoundService {
  final AudioPlayer _audio = AudioPlayer();

  Future<void> playBeep({
    int durationMs = 200,
    double frequency = 440,
    double rate = 1.0,
    double volume = 0.9,
  }) async {
    try {
      await _audio.setVolume(volume);
      try {
        await _audio.setPlaybackRate(rate);
      } catch (e) {
        // Неподдерживается на некоторых платформах (например, web)
      }

      if (kIsWeb) {
        final dataUrl = BeepGenerator.buildDataUrl(
          durationMs: durationMs,
          frequency: frequency,
          amplitude: 0.9,
        );
        await _audio.play(UrlSource(dataUrl));
        return;
      }

      // Non-web: генерируем WAV и играем из временного файла
      const sampleRate = 44100;
      final totalSamples = (sampleRate * durationMs / 1000).round();
      final bytes = BeepGenerator.generateWavBytes(
        totalSamples: totalSamples,
        sampleRate: sampleRate,
        amplitude: 0.9,
        frequency: frequency,
      );
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/flutter_timer_beep.wav');
      await file.writeAsBytes(bytes, flush: true);
      await _audio.play(DeviceFileSource(file.path));
    } catch (e) {
      // Логирование оставляем вызывающему коду (через debugPrint)
    }
  }

  void dispose() {
    _audio.dispose();
  }
}

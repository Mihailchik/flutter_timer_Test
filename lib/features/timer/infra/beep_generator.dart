import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class BeepGenerator {
  /// Генерация WAV байтов с простым синусоидальным PCM 16-bit mono
  static List<int> generateWavBytes({
    required int totalSamples,
    required int sampleRate,
    required double amplitude,
    required double frequency,
  }) {
    final data = BytesBuilder();
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final sample = (amplitude * sin(2 * pi * frequency * t));
      int s = (sample * 32767).round();
      data.add([s & 0xFF, (s >> 8) & 0xFF]);
    }

    final pcm = data.toBytes();
    final byteRate = sampleRate * 2; // mono 16-bit
    const blockAlign = 2; // mono 16-bit
    final subchunk2Size = pcm.length;
    final int chunkSize = 36 + subchunk2Size;

    final header = BytesBuilder();
    header.add('RIFF'.codeUnits);
    header.add(_le32(chunkSize));
    header.add('WAVE'.codeUnits);
    header.add('fmt '.codeUnits);
    header.add(_le32(16)); // Subchunk1Size (PCM)
    header.add(_le16(1)); // AudioFormat PCM
    header.add(_le16(1)); // NumChannels mono
    header.add(_le32(sampleRate));
    header.add(_le32(byteRate));
    header.add(_le16(blockAlign));
    header.add(_le16(16)); // BitsPerSample
    header.add('data'.codeUnits);
    header.add(_le32(subchunk2Size));

    return [...header.toBytes(), ...pcm];
  }

  /// Построение data URL для WAV (для web)
  static String buildDataUrl({
    required int durationMs,
    required double frequency,
    required double amplitude,
    int sampleRate = 44100,
  }) {
    final totalSamples = (sampleRate * durationMs / 1000).round();
    final bytes = generateWavBytes(
      totalSamples: totalSamples,
      sampleRate: sampleRate,
      amplitude: amplitude,
      frequency: frequency,
    );
    final b64 = base64Encode(bytes);
    return 'data:audio/wav;base64,$b64';
  }

  static List<int> _le16(int value) => [value & 0xFF, (value >> 8) & 0xFF];
  static List<int> _le32(int value) => [
        value & 0xFF,
        (value >> 8) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 24) & 0xFF,
      ];
}

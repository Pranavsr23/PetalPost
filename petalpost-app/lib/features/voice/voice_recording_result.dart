import "dart:io";

class VoiceRecordingResult {
  VoiceRecordingResult({
    required this.file,
    required this.duration,
    required this.waveform,
  });

  final File file;
  final Duration duration;
  final List<int> waveform;
}

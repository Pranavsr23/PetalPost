import "dart:math";

class WaveformUtils {
  static List<int> placeholderPeaks({int bars = 24}) {
    final random = Random();
    return List<int>.generate(bars, (index) => 2 + random.nextInt(8));
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(1, "0");
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }
}

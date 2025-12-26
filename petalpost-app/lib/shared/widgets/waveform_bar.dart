import "package:flutter/material.dart";

class WaveformBar extends StatelessWidget {
  const WaveformBar({super.key, required this.peaks, this.color});

  final List<int> peaks;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      children: peaks
          .map(
            (peak) => Container(
              width: 3,
              height: peak.toDouble(),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
          .toList(),
    );
  }
}

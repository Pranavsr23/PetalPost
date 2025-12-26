import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../data/models/note.dart";
import "../../../data/models/note_type.dart";
import "../../../shared/utils/date_formatters.dart";
import "../../../shared/widgets/waveform_bar.dart";

class NoteTimelineItem extends StatelessWidget {
  const NoteTimelineItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.isUnread,
  });

  final Note note;
  final VoidCallback onTap;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(note.type, note.isLocked);
    final timeLabel = DateFormatters.formatTime(note.createdAt);
    final iconColor = _iconColor(note.type, note.isLocked);
    final iconBg = _iconBackground(note.type, note.isLocked);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.softStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titleFor(note),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(timeLabel,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildPreview(context),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (note.isLocked) {
      final label = note.unlockAt == null
          ? "Opens soon"
          : "Opens ${DateFormatters.formatMonthDay(note.unlockAt!)}";
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.softStroke,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 14, color: AppColors.mutedText),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }
    if (note.type == NoteType.voice) {
      return Row(
        children: [
          WaveformBar(peaks: note.waveformPeaks ?? const [3, 6, 4, 7, 5]),
          const SizedBox(width: 8),
          Text(
            "${note.audioDurationSec ?? 0}s",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }
    return Text(
      note.text ?? _titleFor(note),
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _titleFor(Note note) {
    if (note.type == NoteType.handwriting) {
      return "Handwritten note";
    }
    if (note.type == NoteType.voice) {
      return "Voice note";
    }
    if (note.text != null && note.text!.trim().isNotEmpty) {
      return note.text!.split("\n").first;
    }
    return "Text note";
  }

  IconData _iconFor(NoteType type, bool locked) {
    if (locked) return Icons.lock;
    switch (type) {
      case NoteType.voice:
        return Icons.mic;
      case NoteType.handwriting:
        return Icons.draw;
      case NoteType.text:
        return Icons.mail;
    }
  }

  Color _iconColor(NoteType type, bool locked) {
    if (locked) return AppColors.mutedText;
    switch (type) {
      case NoteType.voice:
        return AppColors.primary;
      case NoteType.handwriting:
        return AppColors.primary;
      case NoteType.text:
        return const Color(0xFFE85D75);
    }
  }

  Color _iconBackground(NoteType type, bool locked) {
    if (locked) return const Color(0xFFF2ECEE);
    switch (type) {
      case NoteType.voice:
        return AppColors.primary.withOpacity(0.12);
      case NoteType.handwriting:
        return AppColors.primary.withOpacity(0.12);
      case NoteType.text:
        return const Color(0xFFFFEEF2);
    }
  }
}

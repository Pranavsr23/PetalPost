import "dart:ui";

import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../data/models/note.dart";
import "../../../data/models/note_type.dart";
import "../../../shared/widgets/avatar_stack.dart";

class HeroNoteCard extends StatelessWidget {
  const HeroNoteCard({
    super.key,
    required this.note,
    required this.senderName,
    required this.onTap,
  });

  final Note note;
  final String senderName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = note.surprise ? "Surprise note" : _typeLabel(note.type);
    final subtitle =
        note.surprise ? "Tap to reveal what's inside" : _previewText(note);

    return Semantics(
      label: "Latest from $senderName",
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _HeroBackground(note: note),
                      Container(
                        color: Colors.black.withValues(alpha: 0.16),
                      ),
                      if (note.surprise)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(
                                note.surprise ? Icons.redeem : Icons.mail,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28),
                              child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const AvatarStack(first: null, second: null),
                        const SizedBox(width: 8),
                        Text(
                          "Sent with love",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Icon(Icons.more_horiz, color: AppColors.mutedText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _previewText(Note note) {
    if (note.type == NoteType.text && (note.text?.isNotEmpty ?? false)) {
      return note.text!;
    }
    if (note.type == NoteType.voice) {
      return "Voice note";
    }
    if (note.type == NoteType.handwriting) {
      return "Handwritten note";
    }
    return "New note";
  }

  String _typeLabel(NoteType type) {
    switch (type) {
      case NoteType.voice:
        return "Voice note";
      case NoteType.handwriting:
        return "Handwritten note";
      case NoteType.text:
      default:
        return "Text note";
    }
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final imageUrl = note.imageUrl ?? note.thumbnailUrl;
    if (imageUrl == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFDBE4), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFDBE4), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

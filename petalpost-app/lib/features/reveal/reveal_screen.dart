import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:just_audio/just_audio.dart";
import "package:scratcher/scratcher.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/note.dart";
import "../../data/models/note_type.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../providers/repository_providers.dart";
import "../../shared/utils/date_formatters.dart";
import "../../shared/widgets/empty_state.dart";
import "../../shared/widgets/waveform_bar.dart";

class RevealScreen extends ConsumerStatefulWidget {
  const RevealScreen({super.key, this.note});

  static const String routePath = "/reveal";

  final Note? note;

  @override
  ConsumerState<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends ConsumerState<RevealScreen> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    if (note != null && !note.surprise && !note.isLocked) {
      _markRead(note);
    }
  }

  Future<void> _markRead(Note note) async {
    final user = ref.read(currentUserProvider);
    final space = ref.read(selectedSpaceProvider);
    if (user == null || space == null) return;
    await ref.read(noteRepositoryProvider).markRead(
          spaceId: space.id,
          noteId: note.id,
          uid: user.uid,
        );
  }

  String _senderLabel(Note note, String? uid) {
    if (uid != null && note.senderUid == uid) {
      return "You";
    }
    return "Your partner";
  }

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(selectedSpaceProvider);
    Note? note = widget.note;
    if (note == null && space != null) {
      note = ref.watch(latestNoteProvider(space.id)).valueOrNull;
    }

    if (note == null) {
      return const Scaffold(
        body: Center(
          child: EmptyState(
            title: "No note to reveal",
            subtitle: "Check back when your partner sends a note.",
          ),
        ),
      );
    }

    if (note.isLocked) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceDark,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Time capsule",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock, size: 56, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                "Opens ${DateFormatters.formatMonthDay(note.unlockAt ?? DateTime.now())}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    final senderLabel = _senderLabel(note, ref.read(currentUserProvider)?.uid);
    final timeLabel = DateFormatters.formatTime(note.createdAt);
    final card = _RevealCard(
      note: note,
      senderLabel: senderLabel,
      timeLabel: timeLabel,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _RevealTopBar(
                  title: note.surprise ? "Surprise Mode" : "Reveal",
                  subtitle: "$senderLabel's Note",
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: note.surprise && !_revealed
                        ? Scratcher(
                            brushSize: 40,
                            threshold: 35,
                            color: AppColors.primary.withOpacity(0.7),
                            onThreshold: () {
                              setState(() => _revealed = true);
                              _markRead(note!);
                            },
                            child: card,
                          )
                        : card,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _BottomActions(
                    onReply: () {},
                    onFavorite: () {},
                    onJar: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.note,
    required this.senderLabel,
    required this.timeLabel,
  });

  final Note note;
  final String senderLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderMedia(
            note: note,
            senderLabel: senderLabel,
            timeLabel: timeLabel,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(note),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                _buildBody(context),
                const SizedBox(height: 16),
                NoteActions(note: note),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (note.type) {
      case NoteType.handwriting:
        if (note.imageUrl == null) {
          return const Text("No image", style: TextStyle(color: Colors.white70));
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(imageUrl: note.imageUrl!, fit: BoxFit.contain),
        );
      case NoteType.voice:
        return _VoicePlayer(
          url: note.audioUrl,
          duration: note.audioDurationSec ?? 0,
          peaks: note.waveformPeaks,
        );
      case NoteType.text:
      default:
        return Text(
          note.text ?? "",
          style: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            height: 1.5,
          ),
        );
    }
  }

  String _title(Note note) {
    if (note.type == NoteType.text && (note.text?.isNotEmpty ?? false)) {
      return note.text!.split("\n").first;
    }
    if (note.type == NoteType.voice) return "Voice note";
    if (note.type == NoteType.handwriting) return "Handwritten note";
    return "Your note";
  }
}

class _HeaderMedia extends StatelessWidget {
  const _HeaderMedia({
    required this.note,
    required this.senderLabel,
    required this.timeLabel,
  });

  final Note note;
  final String senderLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final hasImage = note.imageUrl != null && note.type == NoteType.handwriting;
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        image: hasImage
            ? DecorationImage(
                image: CachedNetworkImageProvider(note.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: hasImage
            ? null
            : const LinearGradient(
                colors: [Color(0xFF351A20), Color(0xFF2B161C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Stack(
        children: [
          if (hasImage)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    note.surprise ? "Surprise" : "Revealed",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoicePlayer extends StatefulWidget {
  const _VoicePlayer({
    required this.url,
    required this.duration,
    required this.peaks,
  });

  final String? url;
  final int duration;
  final List<int>? peaks;

  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (widget.url == null) return;
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }
    await _player.setUrl(widget.url!);
    setState(() => _isPlaying = true);
    _player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF48232C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Voice Note",
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDuration(widget.duration),
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                WaveformBar(
                  peaks: widget.peaks ?? const [4, 7, 5, 8, 4, 6, 3, 5],
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(1, "0");
    final remaining = (seconds % 60).toString().padLeft(2, "0");
    return "$minutes:$remaining";
  }
}

class NoteActions extends ConsumerWidget {
  const NoteActions({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final space = ref.watch(selectedSpaceProvider);
    final isFavorite = user == null ? false : (note.isFavoriteBy[user.uid] ?? false);
    final favoriteCount = note.isFavoriteBy.values.where((value) => value).length;
    final smileCount =
        note.reactions.values.where((value) => value == "smile").length;
    final giftCount =
        note.reactions.values.where((value) => value == "gift").length;
    final fireCount =
        note.reactions.values.where((value) => value == "fire").length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ReactionPill(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          color: AppColors.primary,
          count: favoriteCount,
          onTap: user == null || space == null
              ? null
              : () {
                  ref.read(noteRepositoryProvider).toggleFavorite(
                        spaceId: space.id,
                        noteId: note.id,
                        uid: user.uid,
                        isFavorite: !isFavorite,
                      );
                },
        ),
        _ReactionPill(
          icon: Icons.sentiment_satisfied,
          color: Colors.white70,
          count: smileCount,
          onTap: user == null || space == null
              ? null
              : () {
                  ref.read(noteRepositoryProvider).react(
                        spaceId: space.id,
                        noteId: note.id,
                        uid: user.uid,
                        emoji: "smile",
                      );
                },
        ),
        _ReactionPill(
          icon: Icons.card_giftcard,
          color: Colors.white70,
          count: giftCount,
          onTap: user == null || space == null
              ? null
              : () {
                  ref.read(noteRepositoryProvider).react(
                        spaceId: space.id,
                        noteId: note.id,
                        uid: user.uid,
                        emoji: "gift",
                      );
                },
        ),
        _ReactionPill(
          icon: Icons.local_fire_department,
          color: Colors.white70,
          count: fireCount,
          onTap: user == null || space == null
              ? null
              : () {
                  ref.read(noteRepositoryProvider).react(
                        spaceId: space.id,
                        noteId: note.id,
                        uid: user.uid,
                        emoji: "fire",
                      );
                },
        ),
      ],
    );
  }
}

class _ReactionPill extends StatelessWidget {
  const _ReactionPill({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            count == 0 ? "0" : count.toString(),
            style: TextStyle(
              color: count == 0 ? Colors.transparent : color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealTopBar extends StatelessWidget {
  const _RevealTopBar({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: Colors.white,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.mutedText, letterSpacing: 1.2),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onReply,
    required this.onFavorite,
    required this.onJar,
  });

  final VoidCallback onReply;
  final VoidCallback onFavorite;
  final VoidCallback onJar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleAction(
          icon: Icons.star_border,
          onTap: onFavorite,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onReply,
            icon: const Icon(Icons.reply, size: 18),
            label: const Text("Reply"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _CircleAction(
          icon: Icons.kitchen,
          onTap: onJar,
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF3A2027),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}

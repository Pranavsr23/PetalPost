import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/note.dart";
import "../../data/models/note_type.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";
import "../../shared/utils/date_formatters.dart";
import "../../shared/utils/string_utils.dart";
import "../../shared/widgets/primary_button.dart";
import "../handwriting/handwriting_screen.dart";
import "../voice/voice_record_screen.dart";
import "../voice/voice_recording_result.dart";

class ComposeNoteScreen extends ConsumerStatefulWidget {
  const ComposeNoteScreen({super.key});

  static const String routePath = "/notes/compose";

  @override
  ConsumerState<ComposeNoteScreen> createState() => _ComposeNoteScreenState();
}

class _ComposeNoteScreenState extends ConsumerState<ComposeNoteScreen> {
  final TextEditingController _textController = TextEditingController();
  NoteType _type = NoteType.text;
  File? _handwritingFile;
  VoiceRecordingResult? _voiceResult;
  bool _surprise = false;
  bool _timeCapsule = false;
  DateTime? _unlockAt;
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _openHandwriting() async {
    final result = await context.push<File?>(HandwritingScreen.routePath);
    if (result != null) {
      setState(() {
        _handwritingFile = result;
        _type = NoteType.handwriting;
      });
    }
  }

  Future<void> _openVoice() async {
    final result =
        await context.push<VoiceRecordingResult?>(VoiceRecordScreen.routePath);
    if (result != null) {
      setState(() {
        _voiceResult = result;
        _type = NoteType.voice;
      });
    }
  }

  Future<void> _pickUnlockDate() async {
    final initial = _unlockAt ?? DateTime.now().add(const Duration(days: 1));
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimeCapsuleSheet(initialDate: initial),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _unlockAt = selected;
      _timeCapsule = true;
    });
  }

  Future<void> _send() async {
    final user = ref.read(currentUserProvider);
    final space = ref.read(selectedSpaceProvider);
    if (user == null || space == null) return;

    if (_type == NoteType.text && _textController.text.trim().isEmpty) return;
    if (_type == NoteType.handwriting && _handwritingFile == null) return;
    if (_type == NoteType.voice && _voiceResult == null) return;

    setState(() => _isSending = true);
    final noteRepo = ref.read(noteRepositoryProvider);
    final storageRepo = ref.read(storageRepositoryProvider);
    final spaceRepo = ref.read(spaceRepositoryProvider);

    final docRef = noteRepo.newNoteRef(space.id);
    String? imageUrl;
    String? audioUrl;
    int? durationSec;
    List<int>? waveform;

    if (_type == NoteType.handwriting && _handwritingFile != null) {
      imageUrl = await storageRepo.uploadHandwriting(
        spaceId: space.id,
        noteId: docRef.id,
        file: _handwritingFile!,
      );
    }

    if (_type == NoteType.voice && _voiceResult != null) {
      audioUrl = await storageRepo.uploadVoice(
        spaceId: space.id,
        noteId: docRef.id,
        file: _voiceResult!.file,
      );
      durationSec = _voiceResult!.duration.inSeconds;
      waveform = _voiceResult!.waveform;
    }

    final note = Note(
      id: docRef.id,
      senderUid: user.uid,
      createdAt: DateTime.now(),
      type: _type,
      text: _type == NoteType.text ? _textController.text.trim() : null,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      audioDurationSec: durationSec,
      waveformPeaks: waveform,
      surprise: _surprise,
      timeCapsule: _timeCapsule,
      unlockAt: _timeCapsule ? _unlockAt : null,
      deliveredTo: const {},
      readBy: const {},
      reactions: const {},
      isFavoriteBy: const {},
    );

    await docRef.set(note.toMap());
    final preview = _previewFor(note);
    await spaceRepo.updateLastNote(
      spaceId: space.id,
      noteId: docRef.id,
      preview: preview,
      createdAt: note.createdAt,
    );

    await ref.read(widgetServiceProvider).saveLatestNote(
          preview: preview,
          senderName: user.displayName ?? "You",
          createdAt: note.createdAt,
          hasUnread: true,
          lockedUntil: note.unlockAt,
        );
    await ref.read(widgetServiceProvider).requestWidgetUpdate();

    ref.read(analyticsServiceProvider).track("note_sent", properties: {
      "type": noteTypeToString(_type),
      "surprise": _surprise,
      "timeCapsule": _timeCapsule,
    });

    if (mounted) {
      setState(() => _isSending = false);
      context.pop();
    }
  }

  String _previewFor(Note note) {
    if (note.type == NoteType.text && note.text != null) {
      return StringUtils.truncate(note.text!, 80);
    }
    if (note.type == NoteType.handwriting) {
      return "Handwritten note";
    }
    if (note.type == NoteType.voice) {
      return "Voice note";
    }
    return "New note";
  }

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(selectedSpaceProvider);
    if (space == null) {
      return const Scaffold(body: Center(child: Text("Create a space first")));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.blushBackground),
        child: SafeArea(
          child: Column(
            children: [
              _ComposeHeader(
                spaceName: space.name,
                surprise: _surprise,
                onBack: () => context.pop(),
                onSurpriseChanged: (value) => setState(() => _surprise = value),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _NoteTypeTabs(
                  selected: _type,
                  onChanged: (type) => setState(() => _type = type),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ComposerCard(
                    type: _type,
                    textController: _textController,
                    handwritingFile: _handwritingFile,
                    voiceResult: _voiceResult,
                    onOpenHandwriting: _openHandwriting,
                    onOpenVoice: _openVoice,
                  ),
                ),
              ),
              if (_timeCapsule)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: _pickUnlockDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.softStroke),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_clock,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _unlockAt == null
                                  ? "Select unlock date"
                                  : "Unlocks ${DateFormatters.formatMonthDay(_unlockAt!)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 18, color: AppColors.mutedText),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _ComposeFooter(
                timeCapsule: _timeCapsule,
                onTimeCapsuleChanged: (value) {
                  setState(() {
                    _timeCapsule = value;
                    if (!value) _unlockAt = null;
                  });
                  if (value && _unlockAt == null) {
                    _pickUnlockDate();
                  }
                },
                isSending: _isSending,
                onSend: _isSending ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposeHeader extends StatelessWidget {
  const _ComposeHeader({
    required this.spaceName,
    required this.surprise,
    required this.onBack,
    required this.onSurpriseChanged,
  });

  final String spaceName;
  final bool surprise;
  final VoidCallback onBack;
  final ValueChanged<bool> onSurpriseChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "To: $spaceName",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Send something sweet",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.softStroke),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_florist,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(spaceName,
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "Surprise mode",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(width: 6),
                  Switch.adaptive(
                      value: surprise, onChanged: onSurpriseChanged),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteTypeTabs extends StatelessWidget {
  const _NoteTypeTabs({required this.selected, required this.onChanged});

  final NoteType selected;
  final ValueChanged<NoteType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.softStroke),
      ),
      child: Row(
        children: [
          _TabChip(
            label: "Text",
            isActive: selected == NoteType.text,
            onTap: () => onChanged(NoteType.text),
          ),
          _TabChip(
            label: "Handwrite",
            isActive: selected == NoteType.handwriting,
            onTap: () => onChanged(NoteType.handwriting),
          ),
          _TabChip(
            label: "Voice",
            isActive: selected == NoteType.voice,
            onTap: () => onChanged(NoteType.voice),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip(
      {required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({
    required this.type,
    required this.textController,
    required this.handwritingFile,
    required this.voiceResult,
    required this.onOpenHandwriting,
    required this.onOpenVoice,
  });

  final NoteType type;
  final TextEditingController textController;
  final File? handwritingFile;
  final VoiceRecordingResult? voiceResult;
  final VoidCallback onOpenHandwriting;
  final VoidCallback onOpenVoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          if (type == NoteType.text) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PaperLinesPainter(),
                        ),
                      ),
                      TextField(
                        controller: textController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: "Write something sweet...",
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        ),
                        style: const TextStyle(height: 1.6, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _ComposerFontToggle(),
                    _ComposerThemeDots(),
                  ],
                ),
              ],
            );
          }

          if (type == NoteType.handwriting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (handwritingFile != null)
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: FileImage(handwritingFile!),
                            fit: BoxFit.contain),
                      ),
                    )
                  else
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softStroke),
                      ),
                      child: const Icon(Icons.brush,
                          size: 48, color: AppColors.primary),
                    ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onOpenHandwriting,
                    icon: const Icon(Icons.brush),
                    label: const Text("Open canvas"),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic,
                      size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                if (voiceResult != null)
                  Text("${voiceResult!.duration.inSeconds}s recorded"),
                TextButton.icon(
                  onPressed: onOpenVoice,
                  icon: const Icon(Icons.mic),
                  label: const Text("Record voice"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ComposeFooter extends StatelessWidget {
  const _ComposeFooter({
    required this.timeCapsule,
    required this.onTimeCapsuleChanged,
    required this.isSending,
    required this.onSend,
  });

  final bool timeCapsule;
  final ValueChanged<bool> onTimeCapsuleChanged;
  final bool isSending;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: AppColors.softStroke)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => onTimeCapsuleChanged(!timeCapsule),
            icon: Icon(timeCapsule ? Icons.lock_clock : Icons.schedule),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.softStroke,
              foregroundColor: AppColors.ink,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: "Send note",
              isLoading: isSending,
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE7CFD5)
      ..strokeWidth = 1;
    const spacing = 32.0;
    double y = 28;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ComposerFontToggle extends StatelessWidget {
  const _ComposerFontToggle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.softStroke),
      ),
      child: Row(
        children: const [
          _FontChip(label: "Aa", isActive: true),
          _FontChip(label: "Aa", isActive: false, italic: true),
        ],
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  const _FontChip({
    required this.label,
    required this.isActive,
    this.italic = false,
  });

  final String label;
  final bool isActive;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.softStroke : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: isActive ? AppColors.ink : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _ComposerThemeDots extends StatelessWidget {
  const _ComposerThemeDots();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.softStroke),
      ),
      child: Row(
        children: const [
          _ThemeDot(color: Colors.white, isActive: true),
          SizedBox(width: 6),
          _ThemeDot(color: Color(0xFFFFDCE6)),
          SizedBox(width: 6),
          _ThemeDot(color: Color(0xFFF8DDE7)),
        ],
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({required this.color, this.isActive = false});

  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.softStroke),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

class _TimeCapsuleSheet extends StatefulWidget {
  const _TimeCapsuleSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_TimeCapsuleSheet> createState() => _TimeCapsuleSheetState();
}

class _TimeCapsuleSheetState extends State<_TimeCapsuleSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        "${DateFormatters.formatMonthDay(_selected)}, ${DateFormatters.formatTime(_selected)}";
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.softStroke,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Lock this note",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "They can only open it after the time you choose.",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softStroke),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_clock,
                          color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Locked until the moment arrives",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.softStroke),
                      ),
                      child: Text(
                        "Opens on $dateLabel",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minimumDate: DateTime.now().add(const Duration(days: 1)),
                  maximumDate:
                      DateTime.now().add(const Duration(days: 3650)),
                  initialDateTime: _selected,
                  onDateTimeChanged: (value) {
                    setState(() => _selected = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  icon: const Icon(Icons.lock),
                  label: const Text("Lock it"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

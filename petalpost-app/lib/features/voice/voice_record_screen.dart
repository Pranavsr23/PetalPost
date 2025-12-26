import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:just_audio/just_audio.dart";
import "package:path_provider/path_provider.dart";
import "package:record/record.dart";

import "../../core/services/permissions_service.dart";
import "../../shared/utils/waveform_utils.dart";
import "voice_recording_result.dart";

class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key});

  static const String routePath = "/voice";

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen> {
  static const Duration _maxDuration = Duration(seconds: 20);
  static const Color _primary = Color(0xFF197FE6);
  static const Color _background = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFF6F7F8);
  static const Color _darkText = Color(0xFF111921);
  static const Color _mutedText = Color(0xFF6B7280);

  final AudioRecorder _record = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final PermissionsService _permissionsService = PermissionsService();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRecording = false;
  bool _isPlaying = false;
  File? _audioFile;
  List<int> _waveform = const [];

  @override
  void dispose() {
    _timer?.cancel();
    _record.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _permissionsService.requestMicrophone();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";
    await _record.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
      _audioFile = null;
      _waveform = WaveformUtils.placeholderPeaks();
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_elapsed.inSeconds >= _maxDuration.inSeconds) {
        await _stopRecording();
        return;
      }
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    _timer?.cancel();
    if (path == null) return;
    setState(() {
      _isRecording = false;
      _audioFile = File(path);
    });
  }

  Future<void> _togglePlayback() async {
    if (_audioFile == null) return;
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }
    await _player.setFilePath(_audioFile!.path);
    setState(() => _isPlaying = true);
    _player.play();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  void _useRecording() {
    if (_audioFile == null) return;
    final result = VoiceRecordingResult(
      file: _audioFile!,
      duration: _elapsed,
      waveform: _waveform,
    );
    Navigator.of(context).pop(result);
  }

  void _resetRecording() {
    setState(() {
      _audioFile = null;
      _elapsed = Duration.zero;
      _isPlaying = false;
      _waveform = const [];
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, "0");
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = _audioFile != null;
    final title = _isRecording
        ? "Recording..."
        : isPreview
            ? "Review"
            : "New Voice Note";

    return Scaffold(
      backgroundColor: _background,
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.splineSansTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                title: title,
                showClose: !_isRecording,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isPreview
                      ? _PreviewState(
                          key: const ValueKey("preview"),
                          elapsed: _elapsed,
                          waveform: _waveform,
                          isPlaying: _isPlaying,
                          onTogglePlayback: _togglePlayback,
                          onUse: _useRecording,
                          onReset: _resetRecording,
                          formatDuration: _formatDuration,
                        )
                      : _isRecording
                          ? _RecordingState(
                              key: const ValueKey("recording"),
                              elapsed: _elapsed,
                              maxDuration: _maxDuration,
                              waveform: _waveform,
                              onStop: _stopRecording,
                              formatDuration: _formatDuration,
                            )
                          : _ReadyState(
                              key: const ValueKey("ready"),
                              onStart: _startRecording,
                              formatDuration: _formatDuration,
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showClose,
    required this.onClose,
  });

  final String title;
  final bool showClose;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          if (showClose)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: _VoiceRecordScreenState._surface,
                foregroundColor: _VoiceRecordScreenState._darkText,
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ReadyState extends StatelessWidget {
  const _ReadyState({
    super.key,
    required this.onStart,
    required this.formatDuration,
  });

  final VoidCallback onStart;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatDuration(Duration.zero),
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: _VoiceRecordScreenState._mutedText),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _VoiceRecordScreenState._primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        _VoiceRecordScreenState._primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 42),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Tap to record a thought",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: _VoiceRecordScreenState._mutedText),
          ),
          const SizedBox(height: 4),
          Text(
            "(max 20s)",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: _VoiceRecordScreenState._mutedText),
          ),
        ],
      ),
    );
  }
}

class _RecordingState extends StatelessWidget {
  const _RecordingState({
    super.key,
    required this.elapsed,
    required this.maxDuration,
    required this.waveform,
    required this.onStop,
    required this.formatDuration,
  });

  final Duration elapsed;
  final Duration maxDuration;
  final List<int> waveform;
  final VoidCallback onStop;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final peaks =
        waveform.isEmpty ? WaveformUtils.placeholderPeaks(bars: 18) : waveform;
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          "${formatDuration(elapsed)} / ${formatDuration(maxDuration)}",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: _VoiceRecordScreenState._darkText),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final peak in peaks)
                Container(
                  width: 4,
                  height: _barHeight(peak),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _VoiceRecordScreenState._primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: onStop,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(
                  value: elapsed.inSeconds / maxDuration.inSeconds,
                  strokeWidth: 3,
                  color: _VoiceRecordScreenState._primary,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _VoiceRecordScreenState._primary.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Tap to stop",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: _VoiceRecordScreenState._mutedText),
        ),
      ],
    );
  }

  double _barHeight(int peak) {
    final height = peak.toDouble() * 4;
    if (height < 12) return 12;
    if (height > 56) return 56;
    return height;
  }
}

class _PreviewState extends StatelessWidget {
  const _PreviewState({
    super.key,
    required this.elapsed,
    required this.waveform,
    required this.isPlaying,
    required this.onTogglePlayback,
    required this.onUse,
    required this.onReset,
    required this.formatDuration,
  });

  final Duration elapsed;
  final List<int> waveform;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
  final VoidCallback onUse;
  final VoidCallback onReset;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final peaks =
        waveform.isEmpty ? WaveformUtils.placeholderPeaks(bars: 18) : waveform;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _VoiceRecordScreenState._surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  formatDuration(elapsed),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: _VoiceRecordScreenState._darkText),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < peaks.length; i++)
                        Container(
                          width: 4,
                          height: _barHeight(peaks[i]),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: i < peaks.length ~/ 2
                                ? _VoiceRecordScreenState._primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.replay_10),
                      color: _VoiceRecordScreenState._mutedText,
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: onTogglePlayback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _VoiceRecordScreenState._darkText,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.forward_10),
                      color: _VoiceRecordScreenState._mutedText,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onUse,
              icon: const Icon(Icons.check_circle),
              label: const Text("Use this voice note"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _VoiceRecordScreenState._primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text("Re-record"),
            style: TextButton.styleFrom(
              foregroundColor: _VoiceRecordScreenState._mutedText,
            ),
          ),
        ],
      ),
    );
  }

  double _barHeight(int peak) {
    final height = peak.toDouble() * 3.5;
    if (height < 10) return 10;
    if (height > 52) return 52;
    return height;
  }
}

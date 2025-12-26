import "dart:io";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:signature/signature.dart";

import "../../core/theme/app_colors.dart";

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  static const String routePath = "/handwriting";

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  static const Color _paperLight = Color(0xFFFDFBF7);

  late SignatureController _controller;
  int _selectedTool = 0;
  int _selectedColor = 1;
  double _strokeWidth = 4;

  final List<Color> _palette = const [
    AppColors.ink,
    AppColors.primary,
    Color(0xFF3B82F6),
    Color(0xFF10B981),
  ];

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SignatureController _buildController() {
    return SignatureController(
      penStrokeWidth: _strokeWidth,
      penColor: _currentPenColor,
      exportBackgroundColor: _paperLight,
    );
  }

  Color get _currentPenColor {
    if (_selectedTool == 2) {
      return _paperLight;
    }
    return _palette[_selectedColor];
  }

  void _updateController() {
    final points = _controller.points;
    _controller.dispose();
    _controller = SignatureController(
      points: points,
      penStrokeWidth: _strokeWidth,
      penColor: _currentPenColor,
      exportBackgroundColor: _paperLight,
    );
    setState(() {});
  }

  Future<void> _save() async {
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;
    final file = await _writeTemp(bytes);
    if (!mounted) return;
    Navigator.of(context).pop(file);
  }

  Future<File> _writeTemp(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
        "${dir.path}/handwriting_${DateTime.now().millisecondsSinceEpoch}.png");
    return file.writeAsBytes(bytes, flush: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Text("Write by hand", style: theme.textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: _controller.undo,
                    icon: const Icon(Icons.undo),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _controller.redo,
                    icon: const Icon(Icons.redo),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(color: _paperLight),
                      ),
                      Positioned.fill(
                        child: Signature(
                          controller: _controller,
                          backgroundColor: _paperLight,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _PaperTexturePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: AppColors.softStroke)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _ToolButton(
                        icon: Icons.edit,
                        label: "Pen",
                        isActive: _selectedTool == 0,
                        onTap: () {
                          setState(() => _selectedTool = 0);
                          _updateController();
                        },
                      ),
                      const SizedBox(width: 8),
                      _ToolButton(
                        icon: Icons.brush,
                        label: "Marker",
                        isActive: _selectedTool == 1,
                        onTap: () {
                          setState(() => _selectedTool = 1);
                          _updateController();
                        },
                      ),
                      const SizedBox(width: 8),
                      _ToolButton(
                        icon: Icons.auto_fix_off,
                        label: "Eraser",
                        isActive: _selectedTool == 2,
                        onTap: () {
                          setState(() => _selectedTool = 2);
                          _updateController();
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                        },
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _palette.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final color = _palette[index];
                              final isActive = _selectedColor == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedColor = index);
                                  _updateController();
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 12, color: AppColors.mutedText),
                          SizedBox(
                            width: 120,
                            child: Slider(
                              value: _strokeWidth,
                              min: 2,
                              max: 10,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() => _strokeWidth = value);
                                _updateController();
                              },
                            ),
                          ),
                          const Icon(Icons.circle,
                              size: 18, color: AppColors.mutedText),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text("Use this note"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.softStroke),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isActive ? AppColors.primary : AppColors.mutedText),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? AppColors.primary : AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 18.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

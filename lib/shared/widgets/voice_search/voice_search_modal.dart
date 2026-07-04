import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/theme/app_colors.dart';
import '../dialogs/app_dialog.dart';
import '../texts/app_text.dart';
import '../buttons/app_button.dart';

class VoiceSearchModal {
  static Future<void> show(
    BuildContext context, {
    required void Function(String query) onSearch,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _VoiceSearchDialog(onSearch: onSearch),
    );
  }
}

// ─── Dialog ───────────────────────────────────────────────────────────────────

class _VoiceSearchDialog extends StatefulWidget {
  final void Function(String query) onSearch;
  const _VoiceSearchDialog({required this.onSearch});

  @override
  State<_VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<_VoiceSearchDialog>
    with SingleTickerProviderStateMixin {
  // ── Slow rotation controller (12 s / rev, runs continuously) ─────────────────
  late final AnimationController _rotateCtrl;

  // ── Speech ────────────────────────────────────────────────────────────────────
  final _speech = SpeechToText();

  // Text confirmed at the end of each STT session.
  // New sessions append to this so the user's full utterance is preserved.
  String _confirmedText = '';

  // Text currently shown (confirmed + in-progress current session).
  String _text = '';

  bool _isListening = false;

  // Set to false when the user explicitly acts (Search / Cancel / Retake).
  // Prevents the auto-restart loop from firing after the user is done.
  bool _keepListening = true;

  // ── Live mic amplitude (0.0–1.0, smoothed) ───────────────────────────────────
  // Written directly from onSoundLevelChange; no setState needed because
  // _rotateCtrl drives repaints at ~60 fps already.
  double _liveAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _initSpeech();
  }

  @override
  void dispose() {
    _keepListening = false;
    _rotateCtrl.dispose();
    _speech.cancel();
    super.dispose();
  }

  // ── Speech ────────────────────────────────────────────────────────────────────

  // initialize() is called ONCE. After that only _listen() is called to
  // restart sessions — calling initialize() again adds delay and can reset state.
  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _liveAmplitude = 0;
        });
        if (_keepListening) {
          Future.delayed(const Duration(milliseconds: 400), _listen);
        }
      },
      onStatus: (s) {
        if (!mounted) return;
        if (s == 'done' || s == 'notListening') {
          setState(() {
            _isListening = false;
            _liveAmplitude = 0;
          });
          // Small delay lets the engine fully release before we restart.
          // Without this, _speech.isListening may still be true and _listen() exits early.
          if (_keepListening) {
            Future.delayed(const Duration(milliseconds: 150), _listen);
          }
        }
      },
    );
    if (available && mounted && _keepListening) _listen();
  }

  void _listen() {
    if (!mounted || !_keepListening) return;
    setState(() => _isListening = true);

    _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        // Show partial results in real-time as the user speaks.
        // Prepend confirmed text from previous sessions.
        final current = r.recognizedWords.trim();
        final display = _confirmedText.isEmpty
            ? current
            : '$_confirmedText $current'.trim();
        setState(() => _text = display);

        // Lock in as confirmed when the engine marks the result final,
        // so the next session appends to it cleanly.
        if (r.finalResult && current.isNotEmpty) _confirmedText = display;
      },
      onSoundLevelChange: (level) {
        final normalised = (level.clamp(0.0, 10.0) / 10.0);
        _liveAmplitude = _liveAmplitude * 0.65 + normalised * 0.35;
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 8),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        // dictation mode tolerates soft speech and longer pauses
        listenMode: ListenMode.dictation,
        // cloud recognition is far more sensitive than on-device
        onDevice: false,
        cancelOnError: false,
      ),
    );
  }

  Future<void> _retake() async {
    HapticFeedback.selectionClick();
    _keepListening = false;
    await _speech.cancel();
    setState(() {
      _text = '';
      _confirmedText = '';
      _isListening = false;
      _liveAmplitude = 0;
    });
    _keepListening = true;
    _listen();
  }

  void _search() {
    HapticFeedback.mediumImpact();
    _keepListening = false;
    _speech.cancel();
    context.pop();
    if (_text.trim().isNotEmpty) widget.onSearch(_text.trim());
  }

  void _cancel() {
    HapticFeedback.selectionClick();
    _keepListening = false;
    _speech.cancel();
    context.pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Wave orb ──────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Continuous wave — reads _liveAmplitude every frame
                    AnimatedBuilder(
                      animation: _rotateCtrl,
                      builder: (_, __) => CustomPaint(
                        size: const Size(220, 220),
                        painter: _VoiceWavePainter(
                          phase: _rotateCtrl.value,
                          amplitude: _liveAmplitude,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    // Mic icon — gradient, no background circle (matches image)
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [AppColors.teal, const Color(0xFF7C3AED)]
                            : [
                                const Color(0xFF9B59B6),
                                const Color(0xFFF5A623)
                              ],
                      ).createShader(bounds),
                      child: const Icon(Icons.mic_rounded, size: 36),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Recognized text / hint ────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _text.isEmpty
                ? AppText.bodySm(
                    _isListening
                        ? 'Listening… say the medicine name'
                        : 'Tap retake to try again',
                    key: const ValueKey('hint'),
                    color: AppColors.textSecondary,
                  )
                : Text(
                    _text,
                    key: ValueKey(_text),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      height: 1.35,
                    ),
                  ),
          ),
        ],
      ),
      actions: [
        AppButton(
            variant: AppButtonVariant.secondary,
            label: 'Cancel',
            onPressed: _cancel),
        AppButton(
            variant: AppButtonVariant.outline,
            label: 'Retake',
            onPressed: _retake),
        AppButton(
          variant: AppButtonVariant.primary,
          label: 'Search',
          onPressed: _text.trim().isNotEmpty ? _search : null,
        ),
      ],
    );
  }
}

// ─── Wave Painter ─────────────────────────────────────────────────────────────
//
// Idle  → always-visible base circle
// Speaking → 8 sine-wave lines (frequency 6) drawn on top, opacity 0.5

class _VoiceWavePainter extends CustomPainter {
  const _VoiceWavePainter({
    required this.phase,
    required this.amplitude,
    required this.isDark,
  });

  final double phase; // 0.0–1.0 from the 12-second rotation controller
  final double amplitude; // 0.0–1.0 real mic level (smoothed)
  final bool isDark;

  // Per-line colors — opacity is set per-paint, no shader complications
  static const _lightColors = [
    Color(0xFF9B59B6), // violet
    Color(0xFFAB68D3),
    Color(0xFFBD85F0),
    Color(0xFFD46FD4), // pink-purple
    Color(0xFFE891C0), // pink
    Color(0xFFF5A16A), // peach
    Color(0xFFF5A623), // amber
    Color(0xFFEE7B3A), // orange
  ];

  static const _darkColors = [
    Color(0xFF2DD4BF),
    Color(0xFF34D399),
    Color(0xFF38BDF8),
    Color(0xFF818CF8),
    Color(0xFFA78BFA),
    Color(0xFFC084FC),
    Color(0xFF38BDF8),
    Color(0xFF2DD4BF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.39;
    final idleColor = isDark ? AppColors.teal : const Color(0xFF9B59B6);

    // ── Always draw the base circle ──────────────────────────────────────────
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = idleColor.withValues(alpha: 0.45)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // ── Nothing to animate yet ───────────────────────────────────────────────
    if (amplitude < 0.02) return;

    // ── Wave lines ───────────────────────────────────────────────────────────
    final colors = isDark ? _darkColors : _lightColors;
    final animPhase = phase * 2 * math.pi;
    final waveAmp = size.width * 0.10 * amplitude;
    const lineCount = 8;
    const frequency = 6;
    const steps = 300;

    for (int i = 0; i < lineCount; i++) {
      final rotOffset = (i / lineCount) * 2 * math.pi;
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color.withValues(alpha: 0.50)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      for (int j = 0; j <= steps; j++) {
        final t = j / steps;
        final theta = t * 2 * math.pi + rotOffset;
        final r =
            baseRadius + waveAmp * math.sin(frequency * theta + animPhase);
        final x = center.dx + r * math.cos(theta);
        final y = center.dy + r * math.sin(theta);
        j == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_VoiceWavePainter old) =>
      old.phase != phase || old.amplitude != amplitude || old.isDark != isDark;
}

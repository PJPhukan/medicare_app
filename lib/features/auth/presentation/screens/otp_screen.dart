import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_shell.dart';
import 'auth_flow.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.draft,
    required this.onBack,
    this.onVerified,
  });

  final AuthDraft draft;
  final VoidCallback onBack;
  final VoidCallback? onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes  = List.generate(_length, (_) => FocusNode());
  bool _resent = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _length; i++) {
      _focusNodes[i].onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[i].text.isEmpty &&
            i > 0) {
          _controllers[i - 1].clear();
          _focusNodes[i - 1].requestFocus();
          setState(() {});
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _complete => _otp.length == _length;

  void _onKey(int i, String val) {
    if (val.length > 1) {
      final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
      for (var j = 0; j < _length && j < digits.length; j++) {
        _controllers[j].text = digits[j];
      }
      _focusNodes[(_length - 1).clamp(0, _length - 1)].requestFocus();
      setState(() {});
      return;
    }
    if (val.isNotEmpty && i < _length - 1) {
      _focusNodes[i + 1].requestFocus();
    } else if (val.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }
    setState(() {});
  }

  void _resend() {
    setState(() => _resent = true);
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _resent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgInput = isDark ? AppColors.dark700 : Colors.white;
    final identifier = widget.draft.identifier.isNotEmpty
        ? widget.draft.identifier
        : 'your number';

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AuthBrand()),
          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.10),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, size: 34, color: AppColors.teal),
                  ),
                ),
                const SizedBox(height: 20),
                Text(AppStrings.verifyIdentity,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 13, color: secondaryColor),
                    children: [
                      TextSpan(text: '${AppStrings.otpSentMessage}\n'),
                      TextSpan(
                        text: identifier,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A202C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_length, (i) {
              final filled = _controllers[i].text.isNotEmpty;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < _length - 1 ? 10 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 58,
                    decoration: BoxDecoration(
                      color: filled
                          ? AppColors.teal.withValues(alpha: 0.08)
                          : bgInput,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filled
                            ? AppColors.teal.withValues(alpha: 0.5)
                            : borderColor,
                        width: filled ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppColors.teal,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) => _onKey(i, v),
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          AuthButton(
            label: AppStrings.verify,
            enabled: _complete,
            onPressed: widget.onVerified,
          ),
          const SizedBox(height: 20),

          Center(
            child: _resent
                ? Text(AppStrings.codeSent,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.teal,
                    ))
                : RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 13, color: secondaryColor),
                      children: [
                        TextSpan(text: AppStrings.didntReceiveIt),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _resend,
                            child: Text(AppStrings.resend,
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppColors.teal,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

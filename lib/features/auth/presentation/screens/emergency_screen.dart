import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_shell.dart';
import 'auth_flow.dart';

const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({
    super.key,
    required this.draft,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  });

  final AuthDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String _bloodGroup = '';
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _allergiesCtrl = TextEditingController(text: widget.draft.allergies);
    _nameCtrl      = TextEditingController(text: widget.draft.emergencyName);
    _phoneCtrl     = TextEditingController(text: widget.draft.emergencyPhone);
    _bloodGroup    = widget.draft.bloodGroup;
  }

  @override
  void dispose() {
    _allergiesCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_phoneCtrl.text.trim().isNotEmpty) {
      final err = Validators.phone(_phoneCtrl.text);
      if (err != null) { setState(() => _phoneError = err); return; }
    }
    widget.draft.allergies      = _allergiesCtrl.text.trim();
    widget.draft.emergencyName  = _nameCtrl.text.trim();
    widget.draft.emergencyPhone = _phoneCtrl.text.trim();
    widget.draft.bloodGroup     = _bloodGroup;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgInput = isDark ? AppColors.dark700 : Colors.white;

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AuthBrand()),
          const SizedBox(height: 16),

          AuthStepper(steps: const ['Account', 'Health', 'Emergency', 'Plan'], current: 2),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf87171).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFf87171).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(AppStrings.emergencyBadge,
                          style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: const Color(0xFFf87171), letterSpacing: 0.8,
                          )),
                    ),
                    const SizedBox(height: 10),
                    Text(AppStrings.emergencyTitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1A202C),
                          letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 4),
                    Text(AppStrings.emergencySubtitle,
                        style: GoogleFonts.inter(fontSize: 13, color: secondaryColor)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(AppStrings.skip,
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(AppStrings.bloodGroup,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: secondaryColor, letterSpacing: 0.3,
              )),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
            ),
            itemCount: _bloodGroups.length,
            itemBuilder: (_, i) {
              final bg = _bloodGroups[i];
              final active = _bloodGroup == bg;
              return GestureDetector(
                onTap: () => setState(() => _bloodGroup = active ? '' : bg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal.withValues(alpha: 0.12) : bgInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? AppColors.teal.withValues(alpha: 0.5) : borderColor,
                    ),
                  ),
                  child: Center(
                    child: Text(bg,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: active ? AppColors.teal : secondaryColor,
                        )),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          AuthField(
            controller: _allergiesCtrl,
            label: AppStrings.knownAllergies,
            hint: AppStrings.allergiesHint,
          ),
          const SizedBox(height: 14),

          Text(AppStrings.emergencyContact,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: secondaryColor, letterSpacing: 0.3,
              )),
          const SizedBox(height: 8),

          AuthField(controller: _nameCtrl, hint: AppStrings.contactName),
          const SizedBox(height: 10),

          AuthField(
            controller: _phoneCtrl,
            hint: AppStrings.phoneNumber,
            keyboardType: TextInputType.phone,
            error: _phoneError,
            onChanged: (_) => setState(() => _phoneError = null),
          ),
          const SizedBox(height: 24),

          AuthButton(label: AppStrings.saveAndContinue, onPressed: _save),
          const SizedBox(height: 12),

          Center(
            child: Text(
              AppStrings.emergencyDataNote,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppColors.dark500 : const Color(0xFFCBD5E1),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

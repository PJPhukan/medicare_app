import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class RequestFeatureDialog extends ConsumerStatefulWidget {
  const RequestFeatureDialog({super.key});

  @override
  ConsumerState<RequestFeatureDialog> createState() =>
      _RequestFeatureDialogState();
}

class _RequestFeatureDialogState extends ConsumerState<RequestFeatureDialog> {
  late TextEditingController _featureNameCtrl;
  late TextEditingController _importanceCtrl;
  String _selectedFrequency = 'Weekly';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _featureNameCtrl = TextEditingController();
    _importanceCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _featureNameCtrl.dispose();
    _importanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_featureNameCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Please enter a feature name');
      return;
    }

    if (_importanceCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Please describe why this is important');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      AppLogger.i('Feature request submitted', tag: 'Support');
      if (!mounted) return;
      AppSnackbar.success(context, 'Thank you for your feature request!');
      Navigator.pop(context);
    } on Exception catch (e) {
      AppLogger.e('Feature request failed', tag: 'Support', error: e);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.error(context, 'Failed to submit request. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Feature',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Help us improve the CareDose experience.',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.borderCol),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feature Name
                    Text(
                      'FEATURE NAME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: TextField(
                        controller: _featureNameCtrl,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Apple Watch Sync',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Why is this important?
                    Text(
                      'WHY IS THIS IMPORTANT?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: TextField(
                        controller: _importanceCtrl,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.primaryText,
                        ),
                        maxLines: 4,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Describe the problem you\'re trying to solve...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // How often would you use this?
                    Text(
                      'HOW OFTEN WOULD YOU USE THIS?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.mdAll,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          _buildFrequencyButton('Daily'),
                          const SizedBox(width: 8),
                          _buildFrequencyButton('Weekly'),
                          const SizedBox(width: 8),
                          _buildFrequencyButton('Occasionally'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            Divider(height: 1, color: context.borderCol),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        disabledBackgroundColor:
                            AppColors.teal.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        _isSubmitting ? 'Sending...' : 'Send Request',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
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

  Widget _buildFrequencyButton(String label) {
    final isSelected = _selectedFrequency == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFrequency = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: AppBorderRadius.pill,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.teal : AppColors.textHint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

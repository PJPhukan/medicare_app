import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class ReportBugDialog extends ConsumerStatefulWidget {
  const ReportBugDialog({super.key});

  @override
  ConsumerState<ReportBugDialog> createState() => _ReportBugDialogState();
}

class _ReportBugDialogState extends ConsumerState<ReportBugDialog> {
  late TextEditingController _bugTitleCtrl;
  late TextEditingController _descriptionCtrl;
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Performance',
    'Crashes',
    'UI/UX Issues',
    'Data Sync',
    'Authentication',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _bugTitleCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _bugTitleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitBugReport() async {
    if (_bugTitleCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Please enter a bug title');
      return;
    }

    if (_selectedCategory == null) {
      AppSnackbar.error(context, 'Please select a category');
      return;
    }

    if (_descriptionCtrl.text.isEmpty) {
      AppSnackbar.error(context, 'Please describe the bug');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      AppLogger.i('Bug report submitted', tag: 'Support');
      if (!mounted) return;
      AppSnackbar.success(context, 'Thank you for reporting this bug!');
      Navigator.pop(context);
    } on Exception catch (e) {
      AppLogger.e('Bug report failed', tag: 'Support', error: e);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.error(context, 'Failed to submit report. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.mdAll,
                        ),
                        child: const Icon(
                          Icons.bug_report_rounded,
                          size: 20,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Report Bug',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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

            // ── Description ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Help us improve CareDose by describing the issue in detail. Our technical team will review it shortly.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.secondaryText,
                  height: 1.5,
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bug Title
                    const Text(
                      'Bug Title',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                        controller: _bugTitleCtrl,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., App crashes when uploading lab result',
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
                    const SizedBox(height: 16),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: _categories
                            .map((cat) => DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedCategory = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Select a category',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: context.primaryText,
                        ),
                        dropdownColor: context.cardBg,
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                        controller: _descriptionCtrl,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.primaryText,
                        ),
                        maxLines: 4,
                        minLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'What happened? What were you doing when the bug occurred?',
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
                    const SizedBox(height: 16),

                    // Attachment
                    const Text(
                      'Attachment (Optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          AppSnackbar.info(context, 'Screenshot upload coming soon'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(
                            color: context.borderCol,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            style: BorderStyle.solid,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              size: 32,
                              color: context.secondaryText,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attach Screenshot',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PNG, JPG UP TO 5MB',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
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
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitBugReport,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        disabledBackgroundColor:
                            AppColors.teal.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.mdAll,
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Report model (passed in from list) ──────────────────────────────────────

class ReportViewerArgs {
  final String id;
  final String title;
  final String doctor;
  final String date;
  final String type;
  final List<String> tags;
  final String? description;
  final String fileSize;

  const ReportViewerArgs({
    required this.id,
    required this.title,
    required this.doctor,
    required this.date,
    required this.type,
    this.tags = const [],
    this.description,
    this.fileSize = '',
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ReportViewerScreen extends StatelessWidget {
  final ReportViewerArgs report;

  const ReportViewerScreen({super.key, required this.report});

  Color _typeColor(String type) => switch (type.toLowerCase()) {
        'lab'          => AppColors.teal,
        'imaging'      => AppColors.blue,
        'prescription' => AppColors.purple,
        'pdf'          => AppColors.amber,
        _              => AppColors.textSecondary,
      };

  IconData _typeIcon(String type) => switch (type.toLowerCase()) {
        'lab'          => Icons.biotech_rounded,
        'imaging'      => Icons.image_search_rounded,
        'prescription' => Icons.medical_information_rounded,
        'pdf'          => Icons.picture_as_pdf_rounded,
        _              => Icons.description_rounded,
      };

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTypography.bodySm),
      backgroundColor: context.inputBg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(report.type);
    final icon = _typeIcon(report.type);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 20),
                  color: context.primaryText,
                  onPressed: () => _snack(context, 'Sharing report…'),
                  tooltip: AppStrings.share,
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  color: context.primaryText,
                  onPressed: () => _snack(context, 'Downloading…'),
                  tooltip: AppStrings.download,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: Text(AppStrings.reports, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: AppBorderRadius.xlAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(report.title,
                                      style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: AppBorderRadius.pill,
                                    ),
                                    child: Text(report.type,
                                        style: AppTypography.labelXs.copyWith(color: color, letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _MetaRow(icon: Icons.person_rounded, label: 'Doctor', value: report.doctor),
                        const SizedBox(height: 8),
                        _MetaRow(icon: Icons.calendar_today_rounded, label: 'Date', value: report.date),
                        if (report.fileSize.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _MetaRow(icon: Icons.insert_drive_file_rounded, label: 'File size', value: report.fileSize),
                        ],
                      ],
                    ),
                  ),
                  if (report.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TAGS', style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: report.tags.map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.08),
                                borderRadius: AppBorderRadius.pill,
                                border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                              ),
                              child: Text(t, style: AppTypography.labelXs.copyWith(color: AppColors.teal)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (report.description != null && report.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NOTES', style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1)),
                          const SizedBox(height: 10),
                          Text(report.description!, style: AppTypography.bodySm.copyWith(color: context.primaryText, height: 1.6)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Preview area
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: context.inputBg,
                      borderRadius: AppBorderRadius.xlAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 52, color: color.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('Preview not available', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Download the file to view its contents',
                            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _snack(context, 'Downloading…'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.12),
                              borderRadius: AppBorderRadius.lgAll,
                              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.download_rounded, color: AppColors.teal, size: 16),
                                const SizedBox(width: 8),
                                Text(AppStrings.download, style: AppTypography.buttonSm.copyWith(color: AppColors.teal)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Actions row
                  Row(
                    children: [
                      Expanded(child: _ActionBtn(
                        icon: Icons.share_rounded,
                        label: AppStrings.share,
                        color: AppColors.blue,
                        onTap: () => _snack(context, 'Sharing report…'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _ActionBtn(
                        icon: Icons.download_rounded,
                        label: AppStrings.download,
                        color: AppColors.teal,
                        onTap: () => _snack(context, 'Downloading…'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _ActionBtn(
                        icon: Icons.delete_outline_rounded,
                        label: AppStrings.delete,
                        color: AppColors.error,
                        onTap: () => _confirmDelete(context),
                      )),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(AppStrings.deleteReport, style: AppTypography.h3),
        content: Text(AppStrings.deleteReportConfirm,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel, style: AppTypography.bodySm),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete, style: AppTypography.bodySm.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.reportDeleted, style: AppTypography.bodySm),
          backgroundColor: context.inputBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        ));
        Navigator.pop(context);
      }
    });
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text('$label: ', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: AppTypography.bodyXs.copyWith(color: context.primaryText, fontWeight: FontWeight.w600))),
        ],
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.labelXs.copyWith(color: color)),
            ],
          ),
        ),
      );
}

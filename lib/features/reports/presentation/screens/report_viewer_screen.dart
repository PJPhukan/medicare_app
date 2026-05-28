import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

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

class ReportViewerScreen extends ConsumerWidget {
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

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppDialog.confirm(
      context,
      title: AppStrings.deleteReport,
      message: AppStrings.deleteReportConfirm,
      confirmLabel: AppStrings.delete,
      cancelLabel: AppStrings.cancel,
      isDanger: true,
    );
    if (ok == true && context.mounted) {
      AppSnackbar.info(context, AppStrings.reportDeleted);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Reports');
    }
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
              leading: AppIconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                AppIconButton(
                  icon: Icon(Icons.share_rounded, size: 20, color: context.primaryText),
                  tooltip: AppStrings.share,
                  onPressed: () => AppSnackbar.info(context, 'Sharing report…'),
                ),
                AppIconButton(
                  icon: Icon(Icons.download_rounded, size: 20, color: context.primaryText),
                  tooltip: AppStrings.download,
                  onPressed: () => AppSnackbar.info(context, 'Downloading…'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: AppText.h2(AppStrings.reports),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header card
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppContainer.tinted(
                              color: color,
                              borderRadius: AppBorderRadius.mdAll,
                              padding: const EdgeInsets.all(12),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.bodyMd(report.title, fontWeight: FontWeight.w700),
                                  const SizedBox(height: 4),
                                  AppContainer.tinted(
                                    color: color,
                                    borderRadius: AppBorderRadius.pill,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    child: AppText.labelXs(report.type, color: color),
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
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TAGS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: AppColors.textHint, letterSpacing: 1)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: report.tags.map((t) => AppContainer.tinted(
                              color: AppColors.teal,
                              borderRadius: AppBorderRadius.pill,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: AppText.labelXs(t, color: AppColors.teal),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (report.description != null && report.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NOTES',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: AppColors.textHint, letterSpacing: 1)),
                          const SizedBox(height: 10),
                          AppText.bodySm(report.description!, color: context.primaryText),
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
                        AppText.bodySm('Preview not available', color: AppColors.textSecondary),
                        const SizedBox(height: 4),
                        AppText.bodyXs('Download the file to view its contents',
                            color: AppColors.textHint),
                        const SizedBox(height: 20),
                        AppButton.outline(
                          label: AppStrings.download,
                          icon: const Icon(Icons.download_rounded, size: 16),
                          color: AppColors.teal,
                          size: AppButtonSize.sm,
                          onPressed: () => AppSnackbar.info(context, 'Downloading…'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outline(
                          label: AppStrings.share,
                          icon: const Icon(Icons.share_rounded, size: 16),
                          color: AppColors.blue,
                          isFullWidth: true,
                          onPressed: () => AppSnackbar.info(context, 'Sharing report…'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton.outline(
                          label: AppStrings.download,
                          icon: const Icon(Icons.download_rounded, size: 16),
                          color: AppColors.teal,
                          isFullWidth: true,
                          onPressed: () => AppSnackbar.info(context, 'Downloading…'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton.danger(
                          label: AppStrings.delete,
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          isFullWidth: true,
                          onPressed: () => _confirmDelete(context),
                        ),
                      ),
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
}

// ─── Meta row ─────────────────────────────────────────────────────────────────

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
          AppText.bodyXs('$label: ', color: context.secondaryText),
          Expanded(
            child: AppText.bodyXs(value, color: context.primaryText, fontWeight: FontWeight.w600),
          ),
        ],
      );
}

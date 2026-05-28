import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../presentation/providers/reports_provider.dart';
import '../../data/models/report_model.dart' as rep_model;
import '../../../../core/network/connectivity_monitor.dart';

// ─── Report model ─────────────────────────────────────────────────────────────

enum _ReportType { pdf, image, lab, prescription, imaging, other }

class _Report {
  final String id;
  final String title;
  final String doctor;
  final DateTime reportDate;
  final _ReportType type;
  final List<String> tags;
  final String? description;
  final String fileSize;

  const _Report({
    required this.id,
    required this.title,
    required this.doctor,
    required this.reportDate,
    required this.type,
    this.tags = const [],
    this.description,
    this.fileSize = '',
  });
}

// ─── Adapter ──────────────────────────────────────────────────────────────────

_Report _toReport(rep_model.MedicalReport r) {
  final type = r.isPdf
      ? _ReportType.pdf
      : r.isImage
          ? _ReportType.image
          : _ReportType.other;
  final date = r.reportDate != null
      ? DateTime.tryParse(r.reportDate!) ?? r.createdAtDate
      : r.createdAtDate;
  return _Report(
    id: r.id,
    title: r.title,
    doctor: '',
    reportDate: date,
    type: type,
    tags: r.tags.map((t) => t.name).toList(),
    description: r.description,
    fileSize: '',
  );
}

// ─── Type helpers ─────────────────────────────────────────────────────────────

IconData _typeIcon(_ReportType t) {
  return switch (t) {
    _ReportType.pdf => Icons.picture_as_pdf_rounded,
    _ReportType.image => Icons.image_rounded,
    _ReportType.lab => Icons.science_rounded,
    _ReportType.prescription => Icons.medication_rounded,
    _ReportType.imaging => Icons.radio_rounded,
    _ReportType.other => Icons.description_rounded,
  };
}

Color _typeColor(_ReportType t) {
  return switch (t) {
    _ReportType.pdf => AppColors.red,
    _ReportType.image => AppColors.blue,
    _ReportType.lab => AppColors.teal,
    _ReportType.prescription => AppColors.amber,
    _ReportType.imaging => AppColors.purple,
    _ReportType.other => AppColors.textSecondary,
  };
}

// ─── Filter definitions ───────────────────────────────────────────────────────

const _kFilters = ['All', 'PDF', 'Images', 'Lab', 'Prescription', 'Imaging'];

bool _matchesFilter(_Report r, String filter) {
  return switch (filter) {
    'PDF' => r.type == _ReportType.pdf,
    'Images' => r.type == _ReportType.image,
    'Lab' => r.type == _ReportType.lab,
    'Prescription' => r.type == _ReportType.prescription,
    'Imaging' => r.type == _ReportType.imaging,
    _ => true,
  };
}

// ─── Month grouping ───────────────────────────────────────────────────────────

List<({String month, List<_Report> reports})> _groupByMonth(List<_Report> reports) {
  final map = <String, List<_Report>>{};
  for (final r in reports) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    final label = '${months[r.reportDate.month - 1]} ${r.reportDate.year}';
    (map[label] ??= []).add(r);
  }
  return map.entries.map((e) => (month: e.key, reports: e.value)).toList();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'All';

  List<_Report> get _reports =>
      ref.watch(reportsProvider).reports.map(_toReport).toList();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Report> get _filtered {
    return _reports.where((r) {
      if (!_matchesFilter(r, _filter)) return false;
      if (_query.isEmpty) return true;
      final hay = '${r.title} ${r.tags.join(' ')} ${r.description ?? ''}'.toLowerCase();
      return hay.contains(_query);
    }).toList();
  }

  void _openDetail(_Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailSheet(
        report: report,
        onDelete: () {
          Navigator.pop(context);
          ref.read(reportsProvider.notifier).deleteReport(report.id);
          AppSnackbar.info(context, AppStrings.reportDeleted);
        },
      ),
    );
  }

  void _openUpload() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadSheet(
        onUploaded: () => AppSnackbar.success(context, AppStrings.reportUploaded),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Reports', showAppBar: false);
    }
    final isLoading = ref.watch(reportsProvider).isLoading;
    final filtered = _filtered;
    final timeline = _groupByMonth(filtered);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          onRefresh: () => ref.read(reportsProvider.notifier).load(),
          child: CustomScrollView(
            slivers: [
              // ── App bar ────────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: context.bg,
                surfaceTintColor: Colors.transparent,
                expandedHeight: 96,
                leading: AppIconButton(
                  icon: const Icon(Icons.menu_rounded, size: 22),
                  onPressed: openAppSidebar,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                  title: AppText.h3(AppStrings.myReports),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppButton.outline(
                      label: AppStrings.uploadReport,
                      icon: const Icon(Icons.upload_rounded, size: 15),
                      size: AppButtonSize.sm,
                      color: AppColors.teal,
                      onPressed: _openUpload,
                    ),
                  ),
                ],
              ),

              // ── Search bar ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: AppSearchField(
                    controller: _searchCtrl,
                    hint: AppStrings.searchReports,
                    onClear: _searchCtrl.clear,
                  ),
                ),
              ),

              // ── Filter chips ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _kFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _kFilters[i];
                      final active = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.teal : context.inputBg,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(
                              color: active ? AppColors.teal : context.borderCol,
                            ),
                          ),
                          child: AppText.labelSm(
                            f,
                            color: active ? context.bg : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────────────────
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppSkeleton(
                          child: Container(
                            height: 96,
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: AppBorderRadius.lgAll,
                            ),
                          ),
                        ),
                      ),
                      childCount: 5,
                    ),
                  ),
                )
              else if (timeline.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: AppEmptyState(
                      icon: Icons.description_outlined,
                      title: _reports.isEmpty
                          ? AppStrings.noReportsUploaded
                          : AppStrings.noReportsFilter,
                      action: _reports.isEmpty ? _openUpload : null,
                      actionLabel: _reports.isEmpty ? AppStrings.uploadReport : null,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, gi) {
                        final group = timeline[gi];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (gi > 0) const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    group.month.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textHint,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Divider(height: 1, color: context.borderCol)),
                                ],
                              ),
                            ),
                            ...group.reports.map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _ReportCard(report: r, onTap: () => _openDetail(r)),
                                )),
                          ],
                        );
                      },
                      childCount: timeline.length,
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

// ─── Report card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final _Report report;
  final VoidCallback onTap;
  const _ReportCard({required this.report, required this.onTap});

  String _fmtDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(report.type);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AppContainer.tinted(
            color: color,
            borderRadius: AppBorderRadius.mdAll,
            padding: const EdgeInsets.all(12),
            child: Icon(_typeIcon(report.type), size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelMd(
                  report.title,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText.bodyXs(report.doctor, color: context.secondaryText),
                const SizedBox(height: 2),
                AppText.bodyXs(_fmtDate(report.reportDate), color: AppColors.textHint),
                if (report.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: report.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: AppText.labelXs(tag, color: context.secondaryText),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (report.fileSize.isNotEmpty)
                Text(report.fileSize,
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
              const SizedBox(height: 4),
              const Text('View →',
                  style: TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Report detail bottom sheet ───────────────────────────────────────────────

class _ReportDetailSheet extends StatelessWidget {
  final _Report report;
  final VoidCallback onDelete;
  const _ReportDetailSheet({required this.report, required this.onDelete});

  String _fmtDate(DateTime dt) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await AppDialog.confirm(
      context,
      title: AppStrings.deleteReport,
      message: AppStrings.deleteReportConfirm,
      confirmLabel: AppStrings.delete,
      cancelLabel: AppStrings.cancel,
      isDanger: true,
    );
    if (ok == true && context.mounted) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final color = _typeColor(report.type);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),

          // Icon + title
          Row(
            children: [
              AppContainer.tinted(
                color: color,
                borderRadius: AppBorderRadius.lgAll,
                padding: const EdgeInsets.all(14),
                child: Icon(_typeIcon(report.type), size: 24, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMd(report.title, fontWeight: FontWeight.w700),
                    const SizedBox(height: 3),
                    AppText.bodyXs(report.doctor, color: context.secondaryText),
                    AppText.bodyXs(_fmtDate(report.reportDate), color: AppColors.textHint),
                  ],
                ),
              ),
            ],
          ),

          if (report.description != null) ...[
            const SizedBox(height: 14),
            AppText.bodySm(report.description!, color: context.secondaryText),
          ],

          if (report.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: report.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.inputBg,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(color: context.borderCol),
                ),
                child: AppText.labelXs(tag, color: context.secondaryText),
              )).toList(),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton.outline(
                  label: 'View',
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  color: AppColors.teal,
                  isFullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    AppSnackbar.info(context, 'Opening ${report.title}…');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.outline(
                  label: AppStrings.download,
                  icon: const Icon(Icons.download_rounded, size: 15),
                  color: AppColors.blue,
                  isFullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    AppSnackbar.info(context, 'Downloading ${report.title}…');
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: AppContainer.tinted(
                  color: AppColors.red,
                  borderRadius: AppBorderRadius.lgAll,
                  padding: const EdgeInsets.all(13),
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Upload bottom sheet ──────────────────────────────────────────────────────

class _UploadSheet extends ConsumerStatefulWidget {
  final VoidCallback onUploaded;
  const _UploadSheet({required this.onUploaded});

  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _filePath;
  bool _hasFile = false;
  bool _uploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(primary: AppColors.teal, surface: context.cardBg),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _hasFile = true;
      });
    }
  }

  Future<void> _upload() async {
    if (_titleCtrl.text.trim().isEmpty || _filePath == null) return;
    setState(() => _uploading = true);
    try {
      final tags = _tagsCtrl.text.trim().split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      await ref.read(reportsProvider.notifier).uploadReport(
        filePath: _filePath!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        reportDate: _selectedDate?.toIso8601String(),
        tags: tags,
      );
      if (!mounted) return;
      widget.onUploaded();
      Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPad),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle + header
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.h3(AppStrings.uploadReport),
                  AppIconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // File picker
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 100,
                  decoration: BoxDecoration(
                    color: _hasFile ? AppColors.teal.withValues(alpha: 0.06) : context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(
                      color: _hasFile ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _hasFile ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                        size: 28,
                        color: _hasFile ? AppColors.teal : AppColors.textHint,
                      ),
                      const SizedBox(height: 6),
                      AppText.bodySm(
                        _hasFile ? 'File selected' : 'Tap to choose a file',
                        color: _hasFile ? AppColors.teal : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              _FieldLabel(AppStrings.reportTitle, required: true),
              const SizedBox(height: 6),
              AppTextField(controller: _titleCtrl, hint: 'e.g. Blood Test April 2026'),
              const SizedBox(height: 12),

              // Date
              _FieldLabel(AppStrings.reportDate),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.textHint),
                      const SizedBox(width: 10),
                      AppText.bodyMd(
                        _selectedDate == null
                            ? 'Select date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        color: _selectedDate == null ? AppColors.textHint : context.primaryText,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tags
              _FieldLabel(AppStrings.reportTags),
              const SizedBox(height: 6),
              AppTextField(controller: _tagsCtrl, hint: AppStrings.reportTagsHint),
              const SizedBox(height: 12),

              // Description
              _FieldLabel(AppStrings.reportDescription),
              const SizedBox(height: 6),
              AppTextArea(controller: _descCtrl, hint: AppStrings.reportDescHint, maxLines: 3, minLines: 3),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: AppStrings.cancel,
                      isFullWidth: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _titleCtrl,
                      builder: (_, v, __) {
                        final canUpload = v.text.trim().isNotEmpty && _hasFile && !_uploading;
                        return GestureDetector(
                          onTap: canUpload ? _upload : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: canUpload ? AppColors.teal : context.inputBg,
                              borderRadius: AppBorderRadius.lgAll,
                            ),
                            alignment: Alignment.center,
                            child: _uploading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: context.bg),
                                  )
                                : AppText.labelMd(
                                    AppStrings.uploadReport,
                                    color: canUpload ? context.bg : AppColors.textHint,
                                    fontWeight: FontWeight.w600,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form helpers ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          AppText.bodyXs(text, color: context.secondaryText, fontWeight: FontWeight.w600),
          if (required) ...[
            const SizedBox(width: 3),
            const Text('*', style: TextStyle(color: AppColors.red, fontSize: 12)),
          ],
        ],
      );
}

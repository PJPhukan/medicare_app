import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

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

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kReports = [
  _Report(
    id: 'r1',
    title: 'Complete Blood Count (CBC)',
    doctor: 'Dr. Arjun Sharma',
    reportDate: DateTime(2026, 4, 12),
    type: _ReportType.lab,
    tags: ['Lab', 'Blood', 'Routine'],
    description: 'Routine CBC with differential. Haemoglobin slightly low.',
    fileSize: '1.2 MB',
  ),
  _Report(
    id: 'r2',
    title: 'Chest X-Ray',
    doctor: 'Dr. Priya Nair',
    reportDate: DateTime(2026, 4, 3),
    type: _ReportType.imaging,
    tags: ['Imaging', 'X-Ray'],
    description: 'PA view chest X-ray. No active lesions.',
    fileSize: '4.8 MB',
  ),
  _Report(
    id: 'r3',
    title: 'Metformin Prescription',
    doctor: 'Dr. Vikram Menon',
    reportDate: DateTime(2026, 3, 28),
    type: _ReportType.prescription,
    tags: ['Prescription', 'Diabetes'],
    fileSize: '320 KB',
  ),
  _Report(
    id: 'r4',
    title: 'HbA1c Report',
    doctor: 'Dr. Arjun Sharma',
    reportDate: DateTime(2026, 3, 15),
    type: _ReportType.pdf,
    tags: ['Lab', 'Diabetes'],
    description: 'HbA1c: 7.2% — borderline. Reassess in 3 months.',
    fileSize: '890 KB',
  ),
  _Report(
    id: 'r5',
    title: 'Echocardiogram',
    doctor: 'Dr. Deepa Krishnan',
    reportDate: DateTime(2026, 2, 20),
    type: _ReportType.imaging,
    tags: ['Imaging', 'Heart'],
    description: 'Normal LV function. EF 62%.',
    fileSize: '6.1 MB',
  ),
  _Report(
    id: 'r6',
    title: 'Thyroid Profile',
    doctor: 'Dr. Priya Nair',
    reportDate: DateTime(2026, 2, 10),
    type: _ReportType.lab,
    tags: ['Lab', 'Thyroid'],
    fileSize: '670 KB',
  ),
];

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

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'All';
  final _reports = List<_Report>.from(_kReports);

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
          setState(() => _reports.removeWhere((r) => r.id == report.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.reportDeleted, style: AppTypography.bodySm),
              backgroundColor: context.inputBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
            ),
          );
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
        onUploaded: (report) {
          setState(() => _reports.insert(0, report));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.reportUploaded, style: AppTypography.bodySm),
              backgroundColor: context.inputBg,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final timeline = _groupByMonth(filtered);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                onPressed: openAppSidebar,
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: Text(AppStrings.myReports, style: AppTypography.h3),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _openUpload,
                    icon: const Icon(Icons.upload_rounded, size: 15, color: AppColors.teal),
                    label: Text(AppStrings.uploadReport,
                        style: AppTypography.labelSm.copyWith(color: AppColors.teal)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.mdAll,
                        side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Search bar ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _SearchBar(controller: _searchCtrl),
              ),
            ),

            // ── Filter chips ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _kFilters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = _kFilters[i];
                    final active = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.teal : context.inputBg,
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(
                            color: active ? AppColors.teal : context.borderCol,
                          ),
                        ),
                        child: Text(
                          f,
                          style: AppTypography.labelSm.copyWith(
                            color: active ? context.bg : AppColors.textSecondary,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────────
            timeline.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.description_outlined, size: 52, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          Text(
                            _reports.isEmpty ? AppStrings.noReportsUploaded : AppStrings.noReportsFilter,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          if (_reports.isEmpty) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _openUpload,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(color: AppColors.teal, borderRadius: AppBorderRadius.lgAll),
                                child: Text(AppStrings.uploadReport,
                                    style: AppTypography.buttonSm.copyWith(color: context.bg)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, gi) {
                          final group = timeline[gi];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (gi > 0) const SizedBox(height: 20),
                              // Month header
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      group.month.toUpperCase(),
                                      style: AppTypography.overline.copyWith(
                                        color: AppColors.textHint,
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Divider(height: 1, color: context.borderCol)),
                                  ],
                                ),
                              ),
                              // Report cards
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
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.search_rounded, color: AppColors.textHint, size: 18),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                decoration: InputDecoration(
                  hintText: AppStrings.searchReports,
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (_, v, __) => v.text.isNotEmpty
                  ? GestureDetector(
                      onTap: controller.clear,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.close_rounded, size: 16, color: AppColors.textHint),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.mdAll,
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: Icon(_typeIcon(report.type), size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(report.doctor, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(_fmtDate(report.reportDate), style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
                  if (report.tags.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: report.tags.take(3).map((tag) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.pill,
                          border: Border.all(color: context.borderCol),
                        ),
                        child: Text(tag, style: AppTypography.labelXs.copyWith(color: AppColors.textSecondary, fontSize: 10)),
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
                  Text(report.fileSize, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
                const SizedBox(height: 4),
                Text('View →', style: AppTypography.labelXs.copyWith(color: AppColors.teal, fontSize: 11)),
              ],
            ),
          ],
        ),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.lgAll,
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.2)),
        ),
        title: Text(AppStrings.deleteReport, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
        content: Text(AppStrings.deleteReportConfirm, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text('Delete', style: AppTypography.labelSm.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final color = _typeColor(report.type);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                alignment: Alignment.center,
                child: Icon(_typeIcon(report.type), size: 24, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(report.doctor, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                    Text(_fmtDate(report.reportDate), style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),

          if (report.description != null) ...[
            const SizedBox(height: 14),
            Text(report.description!, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5)),
          ],

          if (report.tags.isNotEmpty) ...[
            SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: report.tags.map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.inputBg,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(color: context.borderCol),
                ),
                child: Text(tag, style: AppTypography.labelXs.copyWith(color: AppColors.textSecondary)),
              )).toList(),
            ),
          ],

          SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.visibility_outlined,
                  label: 'View',
                  color: AppColors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${report.title}…', style: AppTypography.bodySm),
                        backgroundColor: context.inputBg,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.download_rounded,
                  label: AppStrings.download,
                  color: AppColors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${report.title}…', style: AppTypography.bodySm),
                        backgroundColor: context.inputBg,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
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
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.buttonSm.copyWith(color: color)),
            ],
          ),
        ),
      );
}

// ─── Upload bottom sheet ──────────────────────────────────────────────────────

class _UploadSheet extends StatefulWidget {
  final void Function(_Report) onUploaded;
  const _UploadSheet({required this.onUploaded});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
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

  Future<void> _upload() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _uploading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final tags = _tagsCtrl.text.trim().split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final report = _Report(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      doctor: 'You',
      reportDate: _selectedDate ?? DateTime.now(),
      type: _ReportType.pdf,
      tags: tags,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      fileSize: '1.0 MB',
    );
    Navigator.pop(context);
    widget.onUploaded(report);
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  Text(AppStrings.uploadReport, style: AppTypography.h3.copyWith(fontSize: 17)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Drop zone (mock)
              GestureDetector(
                onTap: () => setState(() => _hasFile = true),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 100,
                  decoration: BoxDecoration(
                    color: _hasFile ? AppColors.teal.withValues(alpha: 0.06) : context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(
                      color: _hasFile ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                      style: BorderStyle.solid,
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
                      Text(
                        _hasFile ? 'File selected' : 'Tap to choose a file',
                        style: AppTypography.bodySm.copyWith(
                          color: _hasFile ? AppColors.teal : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              _FieldLabel(AppStrings.reportTitle, required: true),
              const SizedBox(height: 6),
              _InputField(controller: _titleCtrl, hint: 'e.g. Blood Test April 2026'),
              const SizedBox(height: 12),

              // Date
              _FieldLabel(AppStrings.reportDate),
              SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.textHint),
                      SizedBox(width: 10),
                      Text(
                        _selectedDate == null
                            ? 'Select date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: AppTypography.bodyMd.copyWith(
                          color: _selectedDate == null ? AppColors.textHint : context.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tags
              _FieldLabel(AppStrings.reportTags),
              const SizedBox(height: 6),
              _InputField(controller: _tagsCtrl, hint: AppStrings.reportTagsHint),
              const SizedBox(height: 12),

              // Description
              _FieldLabel(AppStrings.reportDescription),
              const SizedBox(height: 6),
              _InputField(controller: _descCtrl, hint: AppStrings.reportDescHint, maxLines: 3),
              SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                        ),
                        alignment: Alignment.center,
                        child: Text('Cancel', style: AppTypography.buttonSm.copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _titleCtrl,
                      builder: (_, v, __) {
                        final canUpload = v.text.trim().isNotEmpty && !_uploading;
                        return GestureDetector(
                          onTap: canUpload ? _upload : null,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 13),
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
                                : Text(
                                    AppStrings.uploadReport,
                                    style: AppTypography.buttonSm.copyWith(
                                      color: canUpload ? context.bg : AppColors.textHint,
                                    ),
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

// ─── Shared form helpers ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (required) ...[
            const SizedBox(width: 3),
            const Text('*', style: TextStyle(color: AppColors.red, fontSize: 12)),
          ],
        ],
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  _InputField({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyMd.copyWith(color: context.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      );
}

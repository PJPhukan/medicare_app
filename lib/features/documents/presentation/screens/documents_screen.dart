import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _DocCategory { medical, insurance, legal, other }

class _Doc {
  final String id;
  final String title;
  final _DocCategory category;
  final String date;
  final String fileSize;
  final IconData icon;

  const _Doc({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.fileSize,
    required this.icon,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kDocs = [
  _Doc(id: 'd1', title: 'Health Insurance Card', category: _DocCategory.insurance, date: '12 Jan 2026', fileSize: '1.2 MB', icon: Icons.credit_card_rounded),
  _Doc(id: 'd2', title: 'Hospital Discharge Summary', category: _DocCategory.medical, date: '5 Mar 2026', fileSize: '842 KB', icon: Icons.description_rounded),
  _Doc(id: 'd3', title: 'Power of Attorney', category: _DocCategory.legal, date: '18 Nov 2025', fileSize: '2.1 MB', icon: Icons.gavel_rounded),
  _Doc(id: 'd4', title: 'Vaccination Record', category: _DocCategory.medical, date: '2 Feb 2026', fileSize: '340 KB', icon: Icons.vaccines_rounded),
  _Doc(id: 'd5', title: 'Insurance Policy Document', category: _DocCategory.insurance, date: '15 Oct 2025', fileSize: '4.7 MB', icon: Icons.policy_rounded),
  _Doc(id: 'd6', title: 'Referral Letter – Cardiology', category: _DocCategory.medical, date: '28 Apr 2026', fileSize: '195 KB', icon: Icons.mail_rounded),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _catColor(_DocCategory c) => switch (c) {
      _DocCategory.medical   => AppColors.teal,
      _DocCategory.insurance => AppColors.blue,
      _DocCategory.legal     => AppColors.purple,
      _DocCategory.other     => AppColors.amber,
    };

String _catLabel(_DocCategory c) => switch (c) {
      _DocCategory.medical   => AppStrings.catMedical,
      _DocCategory.insurance => AppStrings.catInsurance,
      _DocCategory.legal     => AppStrings.catLegal,
      _DocCategory.other     => AppStrings.catOther,
    };

// ─── Screen ───────────────────────────────────────────────────────────────────

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _searchCtrl = TextEditingController();
  _DocCategory? _filter;
  final List<_Doc> _docs = List.from(_kDocs);
  String _query = '';

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

  List<_Doc> get _filtered => _docs.where((d) {
        final matchQuery = _query.isEmpty || d.title.toLowerCase().contains(_query);
        final matchCat = _filter == null || d.category == _filter;
        return matchQuery && matchCat;
      }).toList();

  Future<void> _uploadDocument() async {
    final result = await showModalBottomSheet<_Doc>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UploadDocSheet(),
    );
    if (result != null && mounted) {
      setState(() => _docs.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.documentUploaded, style: AppTypography.bodySm)),
      );
    }
  }

  void _openDoc(_Doc doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DocDetailSheet(
        doc: doc,
        onDelete: () {
          setState(() => _docs.remove(doc));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.documentDeleted, style: AppTypography.bodySm)),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
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
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: Text(AppStrings.documents, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
              actions: [
                IconButton(
                  onPressed: _uploadDocument,
                  icon: Icon(Icons.upload_rounded, color: AppColors.teal),
                  tooltip: AppStrings.uploadDocument,
                ),
                SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                        decoration: InputDecoration(
                          hintText: 'Search documents…',
                          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(label: 'All', selected: _filter == null, color: AppColors.teal, onTap: () => setState(() => _filter = null)),
                          const SizedBox(width: 8),
                          ..._DocCategory.values.map((c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: _catLabel(c),
                                  selected: _filter == c,
                                  color: _catColor(c),
                                  onTap: () => setState(() => _filter = _filter == c ? null : c),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        _query.isNotEmpty || _filter != null ? 'No matching documents' : AppStrings.noDocuments,
                        style: AppTypography.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _query.isNotEmpty || _filter != null ? 'Try a different search or filter' : AppStrings.noDocumentsDesc,
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                      if (_query.isEmpty && _filter == null) ...[
                        SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _uploadDocument,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: context.bg,
                            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                          ),
                          icon: const Icon(Icons.upload_rounded, size: 18),
                          label: Text(AppStrings.uploadDocument, style: AppTypography.buttonMd),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _DocCard(doc: filtered[i], onTap: () => _openDoc(filtered[i])),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : context.cardBg,
            borderRadius: AppBorderRadius.pill,
            border: Border.all(color: selected ? color.withValues(alpha: 0.5) : context.borderCol),
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: selected ? color : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
}

// ─── Doc card ─────────────────────────────────────────────────────────────────

class _DocCard extends StatelessWidget {
  final _Doc doc;
  final VoidCallback onTap;

  _DocCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _catColor(doc.category);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: Icon(doc.icon, color: color, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.pill,
                          ),
                          child: Text(
                            _catLabel(doc.category),
                            style: AppTypography.bodyXs.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(doc.date, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
                        const Spacer(),
                        Text(doc.fileSize, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail sheet ─────────────────────────────────────────────────────────────

class _DocDetailSheet extends StatelessWidget {
  final _Doc doc;
  final VoidCallback onDelete;

  _DocDetailSheet({required this.doc, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = _catColor(doc.category);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
            ),
          ),
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppBorderRadius.mdAll),
                child: Icon(doc.icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: AppTypography.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${doc.date} · ${doc.fileSize}', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'View',
                  icon: Icons.visibility_rounded,
                  color: AppColors.teal,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening document…')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Download',
                  icon: Icons.download_rounded,
                  color: AppColors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading…')),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: AppStrings.delete,
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.red,
                  onTap: () {
                    Navigator.pop(context);
                    showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: context.cardBg,
                        title: Text(AppStrings.deleteDocument, style: AppTypography.h3),
                        content: Text(AppStrings.deleteDocumentConfirm, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(AppStrings.delete, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
                          ),
                        ],
                      ),
                    ).then((ok) { if (ok == true) onDelete(); });
                  },
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
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.labelSm.copyWith(color: color, fontSize: 11)),
            ],
          ),
        ),
      );
}

// ─── Upload sheet ─────────────────────────────────────────────────────────────

class _UploadDocSheet extends StatefulWidget {
  const _UploadDocSheet();

  @override
  State<_UploadDocSheet> createState() => _UploadDocSheetState();
}

class _UploadDocSheetState extends State<_UploadDocSheet> {
  final _titleCtrl = TextEditingController();
  _DocCategory _category = _DocCategory.medical;
  bool _filePicked = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || !_filePicked) return;
    Navigator.pop(
      context,
      _Doc(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: _category,
        date: 'Today',
        fileSize: '512 KB',
        icon: Icons.description_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
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
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.uploadDocument, style: AppTypography.h3.copyWith(fontSize: 17)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // File picker mock
              GestureDetector(
                onTap: () => setState(() => _filePicked = true),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _filePicked ? AppColors.teal.withValues(alpha: 0.08) : context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(
                      color: _filePicked ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _filePicked ? Icons.check_circle_outline_rounded : Icons.upload_file_rounded,
                        color: _filePicked ? AppColors.teal : AppColors.textHint,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _filePicked ? 'document_selected.pdf' : 'Tap to select a file',
                        style: AppTypography.bodySm.copyWith(
                          color: _filePicked ? AppColors.teal : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _SheetLabel(AppStrings.documentTitle, required: true),
              const SizedBox(height: 6),
              _SheetField(controller: _titleCtrl, hint: AppStrings.documentTitleHint),
              const SizedBox(height: 14),

              _SheetLabel(AppStrings.documentCategory),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _DocCategory.values.map((c) {
                  final selected = _category == c;
                  final color = _catColor(c);
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 160),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.15) : context.inputBg,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(color: selected ? color.withValues(alpha: 0.5) : context.borderCol),
                      ),
                      child: Text(
                        _catLabel(c),
                        style: AppTypography.labelSm.copyWith(
                          color: selected ? color : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _titleCtrl,
                builder: (_, val, __) {
                  final canSave = val.text.trim().isNotEmpty && _filePicked;
                  return SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: canSave ? _save : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: canSave ? AppColors.teal : context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_rounded, size: 16, color: canSave ? context.bg : AppColors.textHint),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.uploadDocument,
                              style: AppTypography.buttonMd.copyWith(color: canSave ? context.bg : AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  final bool required;
  _SheetLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (required) ...[const SizedBox(width: 3), const Text('*', style: TextStyle(color: AppColors.red, fontSize: 12))],
        ],
      );
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  _SheetField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: TextField(
          controller: controller,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Data args ────────────────────────────────────────────────────────────────

enum MedStatus { active, lowStock, prn }

class MedicineDetailArgs {
  final String name, genericName, strength, form, usedFor, description, food;
  final List<String> times;
  final int stock;
  final String? expiry;
  final MedStatus status;

  const MedicineDetailArgs({
    required this.name,
    required this.genericName,
    required this.strength,
    required this.form,
    required this.usedFor,
    required this.description,
    required this.times,
    required this.food,
    required this.stock,
    this.expiry,
    this.status = MedStatus.active,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class MedicineDetailScreen extends StatefulWidget {
  final MedicineDetailArgs med;

  const MedicineDetailScreen({super.key, required this.med});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _confirmRemove() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.removeMedicineTitle,
      message: AppStrings.removeMedicineDesc,
      confirmLabel: AppStrings.remove,
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.med;
    final stockColor =
        m.status == MedStatus.lowStock ? AppColors.warning : AppColors.teal;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.cardBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_back_rounded, color: context.primaryText),
            ),
          ),
          title: AppText.h3(m.name),
          actions: [
            TextButton(
              onPressed: () => AppSnackbar.info(context, 'Edit coming soon'),
              child: Text(AppStrings.edit,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.teal, letterSpacing: 0,
                  )),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
        ),
        body: Column(
          children: [
            // ── Hero ─────────────────────────────────────────────────────────
            Container(
              color: context.cardBg,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                children: [
                  AppContainer.tinted(
                    color: AppColors.teal,
                    borderRadius: AppBorderRadius.mdAll,
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.medication_rounded,
                        color: AppColors.teal, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bodyMd(m.genericName),
                        AppText.bodySm('${m.strength} · ${m.form}'),
                      ],
                    ),
                  ),
                  _StatusBadge(m.status),
                ],
              ),
            ),

            // ── Tab bar ───────────────────────────────────────────────────────
            Container(
              color: context.cardBg,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.teal, letterSpacing: 0),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary, letterSpacing: 0),
                indicatorColor: AppColors.teal,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: context.borderCol,
                tabs: const [
                  Tab(text: AppStrings.overviewTab),
                  Tab(text: AppStrings.scheduleTab),
                  Tab(text: AppStrings.stockTab),
                  Tab(text: AppStrings.infoTab),
                ],
              ),
            ),

            // ── Tab views ─────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _OverviewTab(med: m, onRemove: _confirmRemove),
                  _ScheduleTab(med: m),
                  _StockTab(med: m, stockColor: stockColor),
                  _InfoTab(med: m),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final MedStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      MedStatus.active => (AppColors.teal, AppStrings.activeStatus),
      MedStatus.lowStock => (AppColors.warning, AppStrings.lowStockStatus),
      MedStatus.prn => (AppColors.purple, AppStrings.prnLabel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: color, letterSpacing: 0.4)),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final MedicineDetailArgs med;
  final VoidCallback onRemove;

  const _OverviewTab({required this.med, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(
          label: AppStrings.primaryUseLabel,
          child: AppText.bodyMd(med.usedFor),
        ),
        const SizedBox(height: 20),

        _Section(
          label: AppStrings.scheduleLabel,
          child: med.status == MedStatus.prn
              ? AppText.bodyMd(AppStrings.prnNote, color: AppColors.purple)
              : med.times.isEmpty
                  ? AppText.bodySm(AppStrings.noScheduleSet)
                  : Column(
                      children: med.times
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: context.inputBg,
                                    borderRadius: AppBorderRadius.mdAll,
                                  ),
                                  child: Row(
                                    children: [
                                      AppText.labelMd(t, color: AppColors.teal),
                                      const SizedBox(width: 12),
                                      Expanded(child: AppText.bodySm('1 dose')),
                                      AppText.bodySm(med.food),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
        ),
        const SizedBox(height: 20),

        _Section(
          label: AppStrings.adherenceLabel,
          child: Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .asMap()
                .entries
                .map((e) {
              final i = e.key;
              final todayIdx = DateTime.now().weekday - 1;
              final isFuture = i > todayIdx;
              final isToday = i == todayIdx;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 6 ? 4 : 0),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isFuture
                        ? Colors.transparent
                        : isToday
                            ? AppColors.teal.withValues(alpha: 0.15)
                            : AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: AppBorderRadius.smAll,
                    border: isFuture
                        ? Border.all(color: context.borderCol)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isFuture
                            ? AppColors.textHint
                            : isToday
                                ? AppColors.teal
                                : AppColors.teal.withValues(alpha: 0.6),
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        _Section(
          label: AppStrings.instructionsLabel,
          child: Text(med.description,
              style: const TextStyle(fontSize: 14, height: 1.7)),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            if (med.status != MedStatus.prn) ...[
              Expanded(
                child: AppButton.primary(
                  label: AppStrings.markTaken,
                  isFullWidth: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: AppButton.outline(
                label: AppStrings.restock,
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: onRemove,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Schedule tab ─────────────────────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  final MedicineDetailArgs med;
  const _ScheduleTab({required this.med});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(AppStrings.fullScheduleLabel,
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.textHint, letterSpacing: 1,
            )),
        const SizedBox(height: 12),
        if (med.status == MedStatus.prn || med.times.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.mdAll,
              border:
                  Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.purple),
                const SizedBox(width: 10),
                AppText.bodyMd(AppStrings.prnNote, color: AppColors.purple),
              ],
            ),
          )
        else
          ...med.times.asMap().entries.map((e) {
            const slotNames = {
              1: ['Morning'],
              2: ['Morning', 'Evening'],
              3: ['Morning', 'Afternoon', 'Evening'],
              4: ['Morning', 'Noon', 'Evening', 'Night'],
            };
            final label =
                (slotNames[med.times.length] ?? [])[e.key];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: context.borderCol),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.12),
                        borderRadius: AppBorderRadius.smAll,
                      ),
                      child: AppText.labelMd(e.value, color: AppColors.teal),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  letterSpacing: 0)),
                          AppText.bodySm('1 dose · ${med.food}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ─── Stock tab ────────────────────────────────────────────────────────────────

class _StockTab extends StatelessWidget {
  final MedicineDetailArgs med;
  final Color stockColor;
  const _StockTab({required this.med, required this.stockColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: stockColor.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: stockColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${med.stock}',
                      style: TextStyle(
                        fontSize: 42, fontWeight: FontWeight.w800,
                        color: context.primaryText,
                      )),
                  AppText.bodySm(AppStrings.unitsRemaining),
                  if (med.expiry != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: AppText.bodyXs('Expires: ${med.expiry}'),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: stockColor.withValues(alpha: 0.4), width: 4),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: (med.stock / 60).clamp(0, 1),
                    strokeWidth: 5,
                    backgroundColor: stockColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(stockColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(AppStrings.stockHistoryLabel,
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.textHint, letterSpacing: 1,
            )),
        const SizedBox(height: 12),
        ...[
          ('+', 'Restocked', '30 units added', 'May 2026'),
          ('-', 'Daily usage', '12 units consumed', 'Apr–May 2026'),
          ('+', 'Initial stock', '${med.stock} units added', 'Apr 2026'),
        ].map((h) => Container(
              margin: const EdgeInsets.only(bottom: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: context.borderCol.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: h.$1 == '+'
                          ? AppColors.teal.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.10),
                      borderRadius: AppBorderRadius.smAll,
                    ),
                    child: Center(
                      child: AppText.labelMd(h.$1,
                          color: h.$1 == '+' ? AppColors.teal : AppColors.error),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bodyMd(h.$2),
                        AppText.bodySm(h.$3),
                      ],
                    ),
                  ),
                  AppText.bodyXs(h.$4),
                ],
              ),
            )),
        const SizedBox(height: 20),
        AppButton.outline(
          label: AppStrings.addStock,
          icon: const Icon(Icons.add_rounded, size: 18),
          isFullWidth: true,
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─── Info tab ─────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final MedicineDetailArgs med;
  const _InfoTab({required this.med});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AccordionItem(title: 'What is it used for?', body: med.usedFor),
        _AccordionItem(title: 'How to take', body: med.description),
        _AccordionItem(
          title: 'Side effects',
          body: 'Common side effects may include nausea, dizziness, or stomach upset. Contact your doctor if symptoms persist.',
        ),
        _AccordionItem(
          title: 'Precautions',
          body: 'Inform your doctor of all medications you are taking. Do not stop without consulting your healthcare provider.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.mdAll,
            border:
                Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Text(
            AppStrings.infoDisclaimer,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.warning.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Accordion item ───────────────────────────────────────────────────────────

class _AccordionItem extends StatefulWidget {
  final String title, body;
  const _AccordionItem({required this.title, required this.body});

  @override
  State<_AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<_AccordionItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: AppText.labelMd(widget.title)),
                  Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(widget.body,
                  style: const TextStyle(fontSize: 14, height: 1.65)),
            ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textHint, letterSpacing: 1,
              )),
          const SizedBox(height: 8),
          child,
        ],
      );
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import 'app_button.dart';
import 'shimmer_widget.dart';

// ─── Column definition ────────────────────────────────────────────────────────

class AppTableColumn<T> {
  const AppTableColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.sortable = false,
    this.minWidth,
  });

  final String label;
  final Widget Function(T row) cellBuilder;
  final int flex;
  final Alignment alignment;
  final bool sortable;
  final double? minWidth;
}

// ─── Main data table ──────────────────────────────────────────────────────────

class AppDataTable<T> extends StatefulWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage,
    this.onRowTap,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.showDividers = true,
    this.stickyHeader = true,
    this.headerColor,
    this.alternateRowColor = false,
  });

  final List<AppTableColumn<T>> columns;
  final List<T> rows;
  final bool isLoading;
  final String? emptyMessage;
  final ValueChanged<T>? onRowTap;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int colIndex, bool ascending)? onSort;
  final bool showDividers;
  final bool stickyHeader;
  final Color? headerColor;
  final bool alternateRowColor;

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: AppColors.dark600),
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.xlAll,
        child: Column(
          children: [
            // Header
            _buildHeader(),
            if (widget.showDividers)
              const Divider(height: 1, color: AppColors.dark600),
            // Body
            if (widget.isLoading)
              _buildSkeleton()
            else if (widget.rows.isEmpty)
              _buildEmpty()
            else
              _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.headerColor ?? AppColors.dark700,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: widget.columns.asMap().entries.map((e) {
            final col = e.value;
            Widget label = Text(
              col.label,
              style: AppTypography.labelXs.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            );

            if (col.sortable && widget.onSort != null) {
              final isSorted = widget.sortColumnIndex == e.key;
              label = GestureDetector(
                onTap: () => widget.onSort!(
                  e.key,
                  isSorted ? !widget.sortAscending : true,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    label,
                    const SizedBox(width: 4),
                    Icon(
                      isSorted
                          ? (widget.sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded)
                          : Icons.unfold_more_rounded,
                      size: 12,
                      color: isSorted ? AppColors.teal : AppColors.textHint,
                    ),
                  ],
                ),
              );
            }

            return Expanded(
              flex: col.flex,
              child: Align(alignment: col.alignment, child: label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: widget.rows.asMap().entries.map((e) {
          final row = e.value;
          final isAlt = widget.alternateRowColor && e.key.isOdd;
          return Column(
            children: [
              GestureDetector(
                onTap: widget.onRowTap != null ? () => widget.onRowTap!(row) : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isAlt ? AppColors.dark700.withValues(alpha: 0.4) : Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: widget.columns.map((col) => Expanded(
                        flex: col.flex,
                        child: Align(
                          alignment: col.alignment,
                          child: col.cellBuilder(row),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),
              if (widget.showDividers && e.key < widget.rows.length - 1)
                const Divider(height: 1, color: AppColors.dark600, indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          widget.emptyMessage ?? AppStrings.nothingFound,
          style: AppTypography.bodySm,
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return AppShimmer(
      child: Column(
        children: List.generate(5, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: widget.columns.map((col) => Expanded(
              flex: col.flex,
              child: Container(
                height: 14,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.dark700,
                  borderRadius: AppBorderRadius.smAll,
                ),
              ),
            )).toList(),
          ),
        )),
      ),
    );
  }
}

// ─── Report summary card ──────────────────────────────────────────────────────

class AppReportCard extends StatelessWidget {
  const AppReportCard({
    super.key,
    required this.title,
    required this.dateRange,
    this.subtitle,
    this.onDownload,
    this.onShare,
    this.color,
    this.icon,
    this.status,
  });

  final String title;
  final String dateRange;
  final String? subtitle;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final Color? color;
  final IconData? icon;
  final ReportStatus? status;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final (Color statusColor, String statusLabel) = switch (status) {
      ReportStatus.ready     => (AppColors.green, 'Ready'),
      ReportStatus.generating=> (AppColors.amber, 'Generating…'),
      ReportStatus.failed    => (AppColors.error,  'Failed'),
      null                   => (AppColors.textHint, ''),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.lgAll,
              ),
              child: Icon(icon ?? Icons.description_rounded, color: c, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelMd),
                  const SizedBox(height: 2),
                  Text(dateRange, style: AppTypography.bodySm),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.bodyXs),
                  if (status != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(statusLabel,
                          style: AppTypography.labelXs.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (status == ReportStatus.ready) ...[
              if (onShare != null)
                AppIconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: onShare,
                  size: 36, iconSize: 16,
                  hasBorder: true,
                ),
              if (onDownload != null) ...[
                const SizedBox(width: 6),
                AppIconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: onDownload,
                  size: 36, iconSize: 16,
                  color: c,
                  backgroundColor: c.withValues(alpha: 0.12),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

enum ReportStatus { ready, generating, failed }

// ─── Key-value detail row ─────────────────────────────────────────────────────

class AppDetailRow extends StatelessWidget {
  const AppDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.icon,
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color? color;
  final IconData? icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: color ?? AppColors.textHint),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.bodySm),
              const Spacer(),
              Text(
                value,
                style: AppTypography.labelMd.copyWith(color: color),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppColors.dark600),
      ],
    );
  }
}

// ─── Detail section ───────────────────────────────────────────────────────────

class AppDetailSection extends StatelessWidget {
  const AppDetailSection({
    super.key,
    required this.rows,
    this.title,
  });

  final List<AppDetailRow> rows;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final last = rows.last;
    final updatedRows = rows.asMap().entries.map((e) {
      final isLast = e.value == last;
      return AppDetailRow(
        label: e.value.label,
        value: e.value.value,
        color: e.value.color,
        icon: e.value.icon,
        isLast: isLast,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!.toUpperCase(),
            style: AppTypography.overline,
          ),
          const SizedBox(height: 8),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: AppBorderRadius.xlAll,
            border: Border.all(color: AppColors.dark600),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: updatedRows),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class ScheduleDateStrip extends StatefulWidget {
  const ScheduleDateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  State<ScheduleDateStrip> createState() => _ScheduleDateStripState();
}

class _ScheduleDateStripState extends State<ScheduleDateStrip> {
  late DateTime _visibleMonth;
  late List<DateTime> _days;
  late final ScrollController _scrollCtrl;

  static const double _chipWidth = 46.0;
  static const double _chipMargin = 4.0;
  static const double _chipExtent = _chipWidth + (_chipMargin * 2);

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _visibleMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _buildDays();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelected(animate: false));
  }

  @override
  void didUpdateWidget(ScheduleDateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateFormatter.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      if (widget.selectedDate.month != _visibleMonth.month ||
          widget.selectedDate.year != _visibleMonth.year) {
        _visibleMonth =
            DateTime(widget.selectedDate.year, widget.selectedDate.month);
        _buildDays();
      }
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToSelected(animate: true));
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _buildDays() {
    final count = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    _days = List.generate(
      count,
      (i) => DateTime(_visibleMonth.year, _visibleMonth.month, i + 1),
    );
  }

  void _scrollToSelected({bool animate = true}) {
    if (!_scrollCtrl.hasClients || _days.isEmpty) return;
    final idx = _days
        .indexWhere((d) => DateFormatter.isSameDay(d, widget.selectedDate));
    if (idx < 0) return;

    final target = (idx * _chipExtent) - 120.0;
    final maxScroll = _scrollCtrl.position.maxScrollExtent;
    final clamped = target.clamp(0.0, maxScroll);

    if (animate) {
      _scrollCtrl.animateTo(
        clamped,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(clamped);
    }
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
      _buildDays();
    });
    widget.onMonthChanged(_visibleMonth);
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
      _buildDays();
    });
    widget.onMonthChanged(_visibleMonth);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Month header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                size: 32,
                iconSize: 20,
                onPressed: _prevMonth,
              ),
              Text(
                DateFormatter.relativeDateHeader(widget.selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.primaryText,
                ),
              ),
              AppIconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                size: 32,
                iconSize: 20,
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Horizontal Date Strip
        SizedBox(
          height: 72,
          child: ListView.builder(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _days.length,
            itemBuilder: (ctx, i) {
              final d = _days[i];
              final isSel = DateFormatter.isSameDay(d, widget.selectedDate);
              final isToday = DateFormatter.isSameDay(d, DateTime.now());

              return GestureDetector(
                onTap: () => widget.onDateSelected(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _chipWidth,
                  margin: const EdgeInsets.symmetric(horizontal: _chipMargin),
                  decoration: BoxDecoration(
                    color: isSel
                        ? null
                        : (isDark
                            ? context.cardBg
                            : AppColors.teal.withValues(alpha: 0.05)),
                    gradient: isSel
                        ? const LinearGradient(
                            colors: [AppColors.teal, Color(0xFF1B6B6C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: AppBorderRadius.pill,
                    border: Border.all(
                      color: isSel
                          ? AppColors.teal
                          : (isDark
                              ? context.borderCol
                              : AppColors.teal.withValues(alpha: 0.2)),
                      width: isSel ? 1.5 : 1,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdays[d.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? Colors.white.withValues(alpha: 0.85)
                              : context.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSel
                              ? Colors.white.withValues(alpha: 0.2)
                              : (isToday
                                  ? AppColors.teal.withValues(alpha: 0.12)
                                  : null),
                        ),
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel || isToday
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSel
                                ? Colors.white
                                : (isToday
                                    ? AppColors.teal
                                    : context.primaryText),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

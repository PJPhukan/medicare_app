import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class LanguageRegionScreen extends ConsumerStatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  ConsumerState<LanguageRegionScreen> createState() =>
      _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends ConsumerState<LanguageRegionScreen> {
  late TextEditingController _searchCtrl;

  String _activeLanguage = 'English (India)';
  String _region = 'India';
  String _timezone = 'Asia/Kolkata';
  String _dateFormat = 'DD/MM/YYYY';
  String _timeFormat = '12 Hour';
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String _tempUnit = '°C';
  String _glucoseUnit = 'mg/dL';

  final List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'native': 'English', 'flag': '🇺🇸', 'code': 'en_US'},
    {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳', 'code': 'hi'},
    {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩', 'code': 'bn'},
    {'name': 'Assamese', 'native': 'অসমীয়া', 'flag': '🇮🇳', 'code': 'as'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳', 'code': 'ta'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳', 'code': 'te'},
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _save() {
    AppLogger.i('Language & Region preferences saved', tag: 'Settings');
    AppSnackbar.success(context, 'Preferences saved successfully');
  }

  void _reset() {
    setState(() {
      _activeLanguage = 'English (India)';
      _region = 'India';
      _timezone = 'Asia/Kolkata';
      _dateFormat = 'DD/MM/YYYY';
      _timeFormat = '12 Hour';
      _heightUnit = 'cm';
      _weightUnit = 'kg';
      _tempUnit = '°C';
      _glucoseUnit = 'mg/dL';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: 'Language & Region',
                leading: AppBarLeading.back,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => AppSnackbar.info(context, 'Search coming soon'),
                        child: const Icon(Icons.search_rounded, size: 20, color: AppColors.teal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Search Bar ─────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(color: context.borderCol),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(fontSize: 14, color: context.primaryText),
                          decoration: InputDecoration(
                            hintText: 'Search language...',
                            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Icon(Icons.search_rounded, size: 18, color: AppColors.textHint),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Active Language ────────────────────────────────────
                      const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.language_rounded,
                                  size: 20,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _activeLanguage,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Currently selected language',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── All Languages ─────────────────────────────────────
                      const Text(
                        'All Languages',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ..._languages.asMap().entries.map((entry) {
                              final lang = entry.value;
                              final isLast = entry.key == _languages.length - 1;
                              final isSelected = lang['name'] == _activeLanguage;

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          lang['flag']!,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lang['name']!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                lang['native']!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: context.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_rounded,
                                            size: 18,
                                            color: AppColors.teal,
                                          )
                                        else
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 18,
                                            color: context.secondaryText,
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(height: 1, color: context.borderCol),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Region ────────────────────────────────────────────
                      const Text(
                        'REGION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _region,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.pill,
                                border: Border.all(
                                  color: AppColors.teal.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Change',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.expand_more_rounded,
                                    size: 14,
                                    color: AppColors.teal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Timezone ───────────────────────────────────────────
                      const Text(
                        'TIMEZONE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _timezone,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'GMT +5:30',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AppColors.teal,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Date Format ────────────────────────────────────────
                      const Text(
                        'Date Format',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY/MM/DD'].map((format) {
                          final isSelected = format == _dateFormat;
                          return GestureDetector(
                            onTap: () => setState(() => _dateFormat = format),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.teal.withValues(alpha: 0.15)
                                    : context.inputBg,
                                borderRadius: AppBorderRadius.pill,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.teal
                                      : context.borderCol,
                                ),
                              ),
                              child: Text(
                                format,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.teal
                                      : context.primaryText,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ── Time Format ────────────────────────────────────────
                      const Text(
                        'Time Format',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _timeFormat = '12 Hour'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _timeFormat == '12 Hour'
                                      ? AppColors.teal.withValues(alpha: 0.2)
                                      : context.inputBg,
                                  borderRadius: AppBorderRadius.mdAll,
                                  border: Border.all(
                                    color: _timeFormat == '12 Hour'
                                        ? AppColors.teal
                                        : context.borderCol,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '12 Hour',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _timeFormat == '12 Hour'
                                            ? AppColors.teal
                                            : context.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '08:45 PM',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _timeFormat = '24 Hour'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _timeFormat == '24 Hour'
                                      ? AppColors.teal.withValues(alpha: 0.2)
                                      : context.inputBg,
                                  borderRadius: AppBorderRadius.mdAll,
                                  border: Border.all(
                                    color: _timeFormat == '24 Hour'
                                        ? AppColors.teal
                                        : context.borderCol,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '24 Hour',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _timeFormat == '24 Hour'
                                            ? AppColors.teal
                                            : context.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '20:45',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Measurement Units ──────────────────────────────────
                      const Text(
                        'Measurement Units',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      _buildMeasurementUnit('Height', ['cm', 'feet'], _heightUnit, (val) {
                        setState(() => _heightUnit = val);
                      }),
                      const SizedBox(height: 16),
                      _buildMeasurementUnit('Weight', ['kg', 'lbs'], _weightUnit, (val) {
                        setState(() => _weightUnit = val);
                      }),
                      const SizedBox(height: 16),
                      _buildMeasurementUnit('Temperature', ['°C', '°F'], _tempUnit, (val) {
                        setState(() => _tempUnit = val);
                      }),
                      const SizedBox(height: 16),
                      _buildMeasurementUnit(
                        'Blood Glucose',
                        ['mg/dL', 'mmol/L'],
                        _glucoseUnit,
                        (val) {
                          setState(() => _glucoseUnit = val);
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Live Preview ───────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'LIVE PREVIEW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHint,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Icon(
                            Icons.preview_rounded,
                            size: 18,
                            color: context.secondaryText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  size: 20,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Today's Reminder",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '8:00 AM',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '12 Jul 2026',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Visualizing data & time formats in real-time',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Action Buttons ────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _reset,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Reset'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: context.borderCol,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.mdAll,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_rounded, size: 18),
                              label: const Text('Save Preferences'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.mdAll,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementUnit(
    String label,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Row(
          children: options.map((option) {
            final isSelected = option == selected;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.teal.withValues(alpha: 0.15)
                        : context.inputBg,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.teal
                          : context.borderCol,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.teal : context.primaryText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

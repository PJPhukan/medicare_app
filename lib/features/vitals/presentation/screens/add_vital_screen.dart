import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Vital type config ────────────────────────────────────────────────────────

class _InputField {
  final String id, label, unit, hint;
  final double min, max;
  const _InputField({
    required this.id,
    required this.label,
    required this.unit,
    required this.hint,
    required this.min,
    required this.max,
  });
}

class _VitalType {
  final String id, name;
  final IconData icon;
  final Color color;
  final List<_InputField> fields;

  const _VitalType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.fields,
  });
}

const _vitalTypes = [
  _VitalType(
    id: 'bp',
    name: AppStrings.bloodPressure,
    icon: Icons.favorite_rounded,
    color: AppColors.teal,
    fields: [
      _InputField(id: 'sys', label: AppStrings.systolic, unit: AppStrings.mmHg, hint: 'e.g. 120', min: 50, max: 250),
      _InputField(id: 'dia', label: AppStrings.diastolic, unit: AppStrings.mmHg, hint: 'e.g. 80', min: 30, max: 150),
    ],
  ),
  _VitalType(
    id: 'hr',
    name: AppStrings.heartRate,
    icon: Icons.monitor_heart_rounded,
    color: AppColors.red,
    fields: [
      _InputField(id: 'bpm', label: AppStrings.heartRate, unit: AppStrings.bpm, hint: 'e.g. 72', min: 30, max: 220),
    ],
  ),
  _VitalType(
    id: 'bg',
    name: AppStrings.bloodSugar,
    icon: Icons.water_drop_rounded,
    color: AppColors.amber,
    fields: [
      _InputField(id: 'glucose', label: AppStrings.bloodSugar, unit: AppStrings.mgDl, hint: 'e.g. 108', min: 20, max: 600),
    ],
  ),
  _VitalType(
    id: 'wt',
    name: AppStrings.weight,
    icon: Icons.scale_rounded,
    color: AppColors.purple,
    fields: [
      _InputField(id: 'kg', label: AppStrings.weight, unit: AppStrings.kg, hint: 'e.g. 72.4', min: 20, max: 300),
    ],
  ),
  _VitalType(
    id: 'spo2',
    name: AppStrings.oxygenLevel,
    icon: Icons.air_rounded,
    color: AppColors.blue,
    fields: [
      _InputField(id: 'pct', label: AppStrings.oxygenLevel, unit: AppStrings.percent, hint: 'e.g. 97', min: 50, max: 100),
    ],
  ),
  _VitalType(
    id: 'temp',
    name: AppStrings.temperature,
    icon: Icons.thermostat_rounded,
    color: AppColors.pink,
    fields: [
      _InputField(id: 'c', label: AppStrings.temperature, unit: AppStrings.celsius, hint: 'e.g. 37.0', min: 30, max: 45),
    ],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddVitalScreen extends StatefulWidget {
  final String? initialTypeId;

  const AddVitalScreen({super.key, this.initialTypeId});

  @override
  State<AddVitalScreen> createState() => _AddVitalScreenState();
}

class _AddVitalScreenState extends State<AddVitalScreen> {
  late String _selectedId;
  late Map<String, TextEditingController> _ctrls;
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  _VitalType get _activeType =>
      _vitalTypes.firstWhere((t) => t.id == _selectedId);

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialTypeId ?? _vitalTypes.first.id;
    _buildControllers();
  }

  void _buildControllers() {
    for (final c in _ctrls.values) { c.dispose(); }
    _ctrls = {for (final f in _activeType.fields) f.id: TextEditingController()};
  }

  void _selectType(String id) {
    if (id == _selectedId) return;
    setState(() {
      _selectedId = id;
      for (final c in _ctrls.values) { c.dispose(); }
      _ctrls = {for (final f in _activeType.fields.where((f) => f.id != id)) f.id: TextEditingController()};
      // rebuild for new type
      _ctrls = {for (final f in _vitalTypes.firstWhere((t) => t.id == id).fields) f.id: TextEditingController()};
    });
  }

  bool get _canSave {
    return _activeType.fields.every((f) {
      final v = _ctrls[f.id]?.text ?? '';
      final parsed = double.tryParse(v);
      return parsed != null && parsed >= f.min && parsed <= f.max;
    });
  }

  void _save() {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_activeType.name} reading saved.',
                style: AppTypography.bodySm),
            backgroundColor: context.inputBg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) { c.dispose(); }
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = _activeType;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.close_rounded, color: context.primaryText),
            ),
          ),
          title: Text(AppStrings.logReading, style: AppTypography.h3),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
        ),
        body: Column(
          children: [
            // ── Vital type picker ─────────────────────────────────────────
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                itemCount: _vitalTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _vitalTypes[i];
                  final active = t.id == _selectedId;
                  return GestureDetector(
                    onTap: () => _selectType(t.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? t.color : Colors.transparent,
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(
                          color: active
                              ? t.color
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon,
                              size: 14,
                              color: active
                                  ? AppColors.textInverse
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            t.name,
                            style: AppTypography.labelSm.copyWith(
                              color: active
                                  ? AppColors.textInverse
                                  : AppColors.textSecondary,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(height: 1, color: context.borderCol),

            // ── Form ──────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type header card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: type.color.withValues(alpha: 0.08),
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(
                            color: type.color.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: type.color.withValues(alpha: 0.15),
                              borderRadius: AppBorderRadius.mdAll,
                            ),
                            alignment: Alignment.center,
                            child: Icon(type.icon,
                                size: 22, color: type.color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(type.name,
                                    style: AppTypography.labelLg
                                        .copyWith(color: type.color)),
                                Text(
                                  type.fields
                                      .map((f) => f.unit)
                                      .toSet()
                                      .join(' / '),
                                  style: AppTypography.bodySm,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dynamic input fields
                    ...type.fields.map((f) {
                      final ctrl = _ctrls[f.id]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _InputRow(
                          field: f,
                          controller: ctrl,
                          accentColor: type.color,
                          onChanged: (_) => setState(() {}),
                        ),
                      );
                    }),

                    // Notes field
                    Text(
                      '${AppStrings.notes} (${AppStrings.optional})',
                      style: AppTypography.labelSm.copyWith(letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.mdAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: AppTypography.bodyMd,
                        decoration: InputDecoration(
                          hintText: 'e.g. After morning walk',
                          hintStyle: AppTypography.bodyMd
                              .copyWith(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Timestamp row (display only)
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 6),
                        Text(
                          _nowLabel(),
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Save button ───────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, 12 + MediaQuery.viewInsetsOf(context).bottom),
              decoration: BoxDecoration(
                color: context.cardBg,
                border: Border(top: BorderSide(color: context.borderCol)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_canSave && !_saving) ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: type.color,
                    disabledBackgroundColor: type.color.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: context.bg,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppStrings.logReading,
                          style: AppTypography.buttonLg
                              .copyWith(color: AppColors.textInverse),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nowLabel() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} · $h:$m';
  }
}

// ─── Input row ────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  final _InputField field;
  final TextEditingController controller;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  const _InputRow({
    required this.field,
    required this.controller,
    required this.accentColor,
    required this.onChanged,
  });

  bool get _valid {
    final v = double.tryParse(controller.text);
    return v != null && v >= field.min && v <= field.max;
  }

  bool get _hasInput => controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasInput
        ? _valid
            ? accentColor.withValues(alpha: 0.5)
            : AppColors.red.withValues(alpha: 0.5)
        : context.borderCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(field.label,
                style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
            const Spacer(),
            Text(
              '${field.min.toStringAsFixed(0)}–${field.max.toStringAsFixed(0)} ${field.unit}',
              style: AppTypography.bodyXs,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*')),
                  ],
                  style: AppTypography.statMd.copyWith(
                      color: context.primaryText, fontSize: 20),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: field.hint,
                    hintStyle: AppTypography.statMd.copyWith(
                        color: AppColors.textHint, fontSize: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  field.unit,
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              if (_hasInput)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    _valid
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    size: 18,
                    color: _valid ? accentColor : AppColors.red,
                  ),
                ),
            ],
          ),
        ),
        if (_hasInput && !_valid)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              AppStrings.valueTooLow,
              style: AppTypography.bodyXs.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }
}

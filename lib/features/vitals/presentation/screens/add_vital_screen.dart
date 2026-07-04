import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/vital_config_model.dart';
import '../providers/vitals_provider.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _hexColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}

IconData _iconForVital(String name) {
  final n = name.toLowerCase();
  if (n.contains('blood pressure') || n.contains(' bp')) return Icons.favorite_rounded;
  if (n.contains('heart')) return Icons.monitor_heart_rounded;
  if (n.contains('sugar') || n.contains('glucose')) return Icons.water_drop_rounded;
  if (n.contains('weight')) return Icons.scale_rounded;
  if (n.contains('spo2') || n.contains('oxygen') || n.contains('saturation')) return Icons.air_rounded;
  if (n.contains('temp')) return Icons.thermostat_rounded;
  return Icons.monitor_heart_outlined;
}

Color _configColor(VitalConfig c) =>
    c.inputs.isNotEmpty ? _hexColor(c.inputs.first.color) : AppColors.teal;

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddVitalScreen extends ConsumerStatefulWidget {
  final String? initialTypeId;

  const AddVitalScreen({super.key, this.initialTypeId});

  @override
  ConsumerState<AddVitalScreen> createState() => _AddVitalScreenState();
}

class _AddVitalScreenState extends ConsumerState<AddVitalScreen> {
  String? _selectedId;
  Map<String, TextEditingController> _ctrls = {};
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  VitalConfig? _activeConfig(List<VitalConfig> configs) {
    if (_selectedId == null || configs.isEmpty) return null;
    return configs.firstWhere((c) => c.id == _selectedId,
        orElse: () => configs.first);
  }

  void _initSelection(List<VitalConfig> configs) {
    if (_initialized || configs.isEmpty) return;
    _initialized = true;
    final initial = widget.initialTypeId != null
        ? configs.firstWhere((c) => c.id == widget.initialTypeId,
            orElse: () => configs.first)
        : configs.first;
    _selectedId = initial.id;
    _ctrls = {for (final i in initial.inputs) i.id: TextEditingController()};
  }

  void _selectType(String id, List<VitalConfig> configs) {
    if (id == _selectedId) return;
    setState(() {
      _selectedId = id;
      for (final c in _ctrls.values) {
        c.dispose();
      }
      final config = configs.firstWhere((c) => c.id == id);
      _ctrls = {for (final i in config.inputs) i.id: TextEditingController()};
    });
  }

  bool _canSave(VitalConfig? config) {
    if (config == null) return false;
    return config.inputs.every((inp) {
      final v = double.tryParse(_ctrls[inp.id]?.text ?? '');
      return v != null && v >= inp.warningMin && v <= inp.warningMax;
    });
  }

  Future<void> _save(VitalConfig config) async {
    if (!_canSave(config) || _saving) return;
    setState(() => _saving = true);
    try {
      final values = config.inputs
          .map((inp) => {
                'inputId': inp.id,
                'value': double.parse(_ctrls[inp.id]!.text),
              })
          .toList();
      await ref.read(vitalsProvider.notifier).addReading(
            vitalConfigId: config.id,
            values: values,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (mounted) {
        context.pop();
        AppSnackbar.success(context, '${config.name} reading saved.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vitalsState = ref.watch(vitalsProvider);
    final configs = vitalsState.configs;

    // Initialize selection once configs are available
    if (!_initialized && configs.isNotEmpty) {
      _initSelection(configs);
    }

    final config = _activeConfig(configs);

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
            onTap: () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.close_rounded, color: context.primaryText),
            ),
          ),
          title: AppText.h3(AppStrings.logReading),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
        ),
        body: vitalsState.isLoading && configs.isEmpty
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
            : configs.isEmpty
                ? Center(child: AppText.bodySm('No vital types configured.', color: AppColors.textSecondary))
                : Column(
                    children: [
                      // ── Vital type picker ─────────────────────────────────
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                          itemCount: configs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final c = configs[i];
                            final active = c.id == _selectedId;
                            final color = _configColor(c);
                            return GestureDetector(
                              onTap: () => _selectType(c.id, configs),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: active ? color : Colors.transparent,
                                  borderRadius: AppBorderRadius.pill,
                                  border: Border.all(
                                    color: active
                                        ? color
                                        : AppColors.textSecondary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_iconForVital(c.name),
                                        size: 14,
                                        color: active ? AppColors.textInverse : AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0,
                                        color: active ? AppColors.textInverse : AppColors.textSecondary,
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

                      // ── Form ──────────────────────────────────────────────
                      if (config != null)
                        Expanded(
                          child: _VitalForm(
                            config: config,
                            ctrls: _ctrls,
                            notesCtrl: _notesCtrl,
                            onChanged: () => setState(() {}),
                          ),
                        ),

                      // ── Save button ───────────────────────────────────────
                      if (config != null)
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
                              onPressed: (_canSave(config) && !_saving) ? () => _save(config) : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: _configColor(config),
                                disabledBackgroundColor: _configColor(config).withValues(alpha: 0.3),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _saving
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: context.bg, strokeWidth: 2),
                                    )
                                  : const Text(
                                      AppStrings.logReading,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: AppColors.textInverse),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

}

// ─── Vital form (stateless, rebuilt when config changes) ──────────────────────

class _VitalForm extends StatelessWidget {
  final VitalConfig config;
  final Map<String, TextEditingController> ctrls;
  final TextEditingController notesCtrl;
  final VoidCallback onChanged;

  const _VitalForm({
    required this.config,
    required this.ctrls,
    required this.notesCtrl,
    required this.onChanged,
  });

  String _nowLabel() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final color = _configColor(config);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  alignment: Alignment.center,
                  child: Icon(_iconForVital(config.name), size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(config.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
                      AppText.bodySm(
                        config.inputs.map((i) => i.unit).toSet().join(' / '),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dynamic input fields
          ...config.inputs.map((inp) {
            final ctrl = ctrls[inp.id];
            if (ctrl == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _InputRow(
                input: inp,
                controller: ctrl,
                accentColor: _hexColor(inp.color),
                onChanged: (_) => onChanged(),
              ),
            );
          }),

          // Notes field
          Text(
            '${AppStrings.notes} (${AppStrings.optional})',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: context.inputBg,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: context.borderCol),
            ),
            child: TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: TextStyle(fontSize: 14, color: context.primaryText),
              decoration: const InputDecoration(
                hintText: 'e.g. After morning walk',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              AppText.bodySm(_nowLabel(), color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Input row ────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  final VitalInput input;
  final TextEditingController controller;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  const _InputRow({
    required this.input,
    required this.controller,
    required this.accentColor,
    required this.onChanged,
  });

  bool get _valid {
    final v = double.tryParse(controller.text);
    return v != null && v >= input.warningMin && v <= input.warningMax;
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
            Text(input.label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
            const Spacer(),
            AppText.bodyXs(
                '${input.warningMin.toStringAsFixed(0)}–${input.warningMax.toStringAsFixed(0)} ${input.unit}'),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700, color: context.primaryText),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: input.placeholder ?? input.label,
                    hintStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(input.unit,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary)),
              ),
              if (_hasInput)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    _valid ? Icons.check_circle_rounded : Icons.error_outline_rounded,
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
            child: AppText.bodyXs(AppStrings.valueTooLow, color: AppColors.red),
          ),
      ],
    );
  }
}

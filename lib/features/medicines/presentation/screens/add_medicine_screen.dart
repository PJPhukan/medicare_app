import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicines_provider.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  int _step = 0;
  final _steps = [
    AppStrings.addMedicineStep1,
    AppStrings.addMedicineStep2,
    AppStrings.addMedicineStep3,
    AppStrings.addMedicineStep4,
  ];

  // Step 0
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  CatalogMedicineEntity? _selected;
  List<CatalogMedicineEntity> _catalogItems = [];
  bool _catalogLoading = false;
  bool _showRequest = false;
  final _reqNameCtrl = TextEditingController();

  // Step 1
  String _whoMode = 'self';

  // Step 2
  String _freq = 'twice';
  final _freqOptions = const [
    ('once', AppStrings.onceDaily, ['09:00']),
    ('twice', AppStrings.twiceDaily, ['09:00', '21:00']),
    ('three', AppStrings.threeDaily, ['08:00', '14:00', '21:00']),
    ('prn', AppStrings.asNeeded, <String>[]),
  ];
  List<String> _times = ['09:00', '21:00'];
  String _food = 'with';
  final _doseCtrl = TextEditingController(text: '1 tablet');
  final _foodOptions = const [
    ('before', AppStrings.beforeFood),
    ('with', AppStrings.withFood),
    ('after', AppStrings.afterFood),
  ];

  // Step 3
  final _qtyCtrl = TextEditingController(text: '30');
  final _expiryCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog('');
  }

  Future<void> _loadCatalog(String query) async {
    setState(() => _catalogLoading = true);
    try {
      final results =
          await ref.read(medicinesRepositoryProvider).searchCatalog(query);
      if (mounted) setState(() { _catalogItems = results; _catalogLoading = false; });
    } on Exception catch (_) {
      if (mounted) setState(() => _catalogLoading = false);
    }
  }

  void _setFreq(String f) {
    final opt = _freqOptions.firstWhere((x) => x.$1 == f);
    setState(() {
      _freq = f;
      _times = List<String>.from(opt.$3);
    });
  }

  bool get _canProceed {
    if (_step == 0) return _selected != null;
    return true;
  }

  void _next() {
    if (!_canProceed) return;
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(medicinesProvider.notifier).addMedicine(
            medicineId: _selected!.id,
            patientProfileId: _whoMode == 'patient' ? null : null,
          );
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.success(context, 'Medicine added successfully.');
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppSnackbar.error(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _reqNameCtrl.dispose();
    _doseCtrl.dispose();
    _qtyCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
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
          title: AppText.h3(AppStrings.addMedicine),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
        ),
        body: Column(
          children: [
            // ── Step indicator ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: _steps.asMap().entries.map((e) {
                  final i = e.key;
                  final done = i < _step;
                  final active = i == _step;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? AppColors.teal
                                      : active
                                          ? AppColors.teal.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                  border: Border.all(
                                    color: done || active
                                        ? AppColors.teal
                                        : context.borderCol,
                                    width: active ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: done
                                      ? const Icon(Icons.check_rounded,
                                          size: 12, color: Colors.black)
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0,
                                            color: active ? AppColors.teal : AppColors.textHint,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0,
                                  color: active || done ? AppColors.teal : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < _steps.length - 1)
                          Container(
                            width: 20,
                            height: 1,
                            color: i < _step ? AppColors.teal : context.borderCol,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            Container(height: 1, color: context.borderCol),

            // ── Step content ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(),
              ),
            ),

            // ── Bottom nav buttons ──────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, 12 + MediaQuery.viewInsetsOf(context).bottom),
              decoration: BoxDecoration(
                color: context.cardBg,
                border: Border(top: BorderSide(color: context.borderCol)),
              ),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: context.borderCol),
                        ),
                        child: const Text(
                          AppStrings.back,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: (_canProceed && !_saving) ? _next : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        disabledBackgroundColor:
                            AppColors.teal.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _saving
                            ? AppStrings.saving
                            : _step == _steps.length - 1
                                ? AppStrings.save
                                : AppStrings.next,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textInverse),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() => switch (_step) {
    0 => _buildStep0(),
    1 => _buildStep1(),
    2 => _buildStep2(),
    _ => _buildStep3(),
  };

  // ── Step 0: Find medicine ─────────────────────────────────────────────────

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(fontSize: 14, color: context.primaryText),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchMedicines,
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) {
                    setState(() {
                      _searchQuery = v;
                      _showRequest = false;
                    });
                    _loadCatalog(v);
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          _catalogLoading
              ? ''
              : _catalogItems.isEmpty
                  ? AppStrings.noMatchesLabel
                  : _searchQuery.isEmpty
                      ? AppStrings.popularLabel
                      : AppStrings.resultsLabel,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textHint),
        ),

        const SizedBox(height: 10),

        if (_catalogLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.teal),
            ),
          )
        else
          ..._catalogItems.map((item) {
          final active = _selected?.id == item.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selected = item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal.withValues(alpha: 0.08)
                      : context.cardBg,
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(
                    color: active
                        ? AppColors.teal.withValues(alpha: 0.4)
                        : context.borderCol,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.teal.withValues(alpha: 0.15)
                            : context.inputBg,
                        borderRadius: AppBorderRadius.smAll,
                      ),
                      child: Icon(Icons.medication_rounded,
                          size: 18,
                          color:
                              active ? AppColors.teal : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.labelMd(item.name),
                          AppText.bodySm(
                            [item.genericName, item.strength, item.dosageForm]
                                .join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (active)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.teal, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        if (!_showRequest)
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _showRequest = true;
                _reqNameCtrl.text = _searchQuery;
              }),
              child: AppText.bodySm(AppStrings.cantFindIt, color: AppColors.teal),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: AppText.labelMd(AppStrings.requestMedicine)),
                    GestureDetector(
                      onTap: () => setState(() => _showRequest = false),
                      child: AppText.bodySm(AppStrings.cancel, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText.bodySm(AppStrings.requestDesc),
                const SizedBox(height: 14),
                _FieldRow(
                    label: AppStrings.medicineNameLabel,
                    controller: _reqNameCtrl,
                    hint: 'e.g. 3 Mix Cream'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AppSnackbar.success(context, AppStrings.requestSubmitted);
                  },
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.teal),
                  child: const Text(AppStrings.submitRequest,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textInverse)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Step 1: Who for ──────────────────────────────────────────────────────

  Widget _buildStep1() {
    final options = [
      ('self', Icons.person_rounded, AppStrings.whoForYou,
          AppStrings.whoForYouDesc, AppColors.teal),
      ('patient', Icons.people_rounded, AppStrings.whoForPatient,
          AppStrings.whoForPatientDesc, AppColors.blue),
      ('shared', Icons.share_rounded, AppStrings.whoShared,
          AppStrings.whoSharedDesc, AppColors.purple),
    ];
    return Column(
      children: options.map((opt) {
        final active = _whoMode == opt.$1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _whoMode = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: active
                    ? opt.$5.withValues(alpha: 0.07)
                    : Colors.transparent,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(
                    color: active
                        ? opt.$5.withValues(alpha: 0.4)
                        : context.borderCol),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: active
                          ? opt.$5.withValues(alpha: 0.15)
                          : context.inputBg,
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                    child: Icon(opt.$2,
                        color:
                            active ? opt.$5 : AppColors.textSecondary,
                        size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.labelMd(opt.$3, color: active ? opt.$5 : null),
                        AppText.bodySm(opt.$4),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? opt.$5 : Colors.transparent,
                      border: Border.all(
                          color: active ? opt.$5 : context.borderCol, width: 2),
                    ),
                    child: active
                        ? const Icon(Icons.check_rounded,
                            size: 11, color: Colors.black)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Step 2: Schedule ─────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textHint)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _freqOptions.map((f) {
            final active = _freq == f.$1;
            return GestureDetector(
              onTap: () => _setFreq(f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(
                      color: active ? AppColors.teal : context.borderCol),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0,
                    color: active ? AppColors.teal : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (_freq != 'prn') ...[
          const SizedBox(height: 20),
          const Text('Dose times',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textHint)),
          const SizedBox(height: 10),
          ..._times.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 16, color: AppColors.teal),
                      const SizedBox(width: 10),
                      AppText.labelMd(t, color: AppColors.teal),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 20),
          _FieldRow(
              label: AppStrings.doseAmount,
              controller: _doseCtrl,
              hint: AppStrings.doseAmountHint),

          const SizedBox(height: 16),

          const Text(AppStrings.foodRelation,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textHint)),
          const SizedBox(height: 10),
          Row(
            children: _foodOptions.map((f) {
              final active = _food == f.$1;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: f.$1 != 'after' ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _food = f.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.teal.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: AppBorderRadius.mdAll,
                        border: Border.all(
                            color: active ? AppColors.teal : context.borderCol),
                      ),
                      child: Center(
                        child: Text(
                          f.$2,
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0,
                            color: active ? AppColors.teal : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.07),
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.2)),
            ),
            child: AppText.bodyMd(AppStrings.scheduleOptional, color: AppColors.purple.withValues(alpha: 0.9)),
          ),
        ],
      ],
    );
  }

  // ── Step 3: Stock ────────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodySm(AppStrings.stockOptional),
        const SizedBox(height: 20),
        _FieldRow(
          label: AppStrings.quantityLabel,
          controller: _qtyCtrl,
          hint: AppStrings.stockQtyHint,
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        _FieldRow(
          label: AppStrings.expiryLabel,
          controller: _expiryCtrl,
          hint: 'e.g. Dec 2026',
        ),
      ],
    );
  }
}

// ─── Reusable field widget ────────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? inputType;

  const _FieldRow({
    required this.label,
    required this.controller,
    required this.hint,
    this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: context.borderCol),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            style: TextStyle(fontSize: 14, color: context.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

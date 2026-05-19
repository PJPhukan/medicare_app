import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Local catalog model ──────────────────────────────────────────────────────

class _CatalogItem {
  final String name, genericName, strength, form;
  const _CatalogItem(this.name, this.genericName, this.strength, this.form);
}

const _catalog = [
  _CatalogItem('Paracetamol', 'Paracetamol', '500 mg', 'Tablet'),
  _CatalogItem('Metformin', 'Metformin HCl', '500 mg', 'Tablet'),
  _CatalogItem('Amlodipine', 'Amlodipine Besylate', '5 mg', 'Tablet'),
  _CatalogItem('Omeprazole', 'Omeprazole', '20 mg', 'Capsule'),
  _CatalogItem('Cetirizine', 'Cetirizine HCl', '10 mg', 'Tablet'),
  _CatalogItem('Azithromycin', 'Azithromycin', '500 mg', 'Tablet'),
  _CatalogItem('Aspirin', 'Acetylsalicylic Acid', '75 mg', 'Tablet'),
  _CatalogItem('Pantoprazole', 'Pantoprazole Sodium', '40 mg', 'Tablet'),
  _CatalogItem('Atorvastatin', 'Atorvastatin Calcium', '20 mg', 'Tablet'),
  _CatalogItem('Lisinopril', 'Lisinopril', '10 mg', 'Tablet'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
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
  _CatalogItem? _selected;
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

  List<_CatalogItem> get _catalogResults {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _catalog.take(5).toList();
    return _catalog
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.genericName.toLowerCase().contains(q))
        .toList();
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

  void _save() {
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medicine saved successfully.'),
            backgroundColor: context.inputBg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
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
          title: Text(AppStrings.addMedicine, style: AppTypography.h3),
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
                                          style: AppTypography.labelXs.copyWith(
                                            color: active
                                                ? AppColors.teal
                                                : AppColors.textHint,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.value,
                                style: AppTypography.labelXs.copyWith(
                                  color: active || done
                                      ? AppColors.teal
                                      : AppColors.textHint,
                                  letterSpacing: 0,
                                  fontSize: 9,
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
                        child: Text(
                          AppStrings.back,
                          style: AppTypography.buttonMd
                              .copyWith(color: AppColors.textSecondary),
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
                        style: AppTypography.buttonLg
                            .copyWith(color: AppColors.textInverse),
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
                  style: AppTypography.bodyMd,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchMedicines,
                    hintStyle: AppTypography.bodyMd
                        .copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => setState(() {
                    _searchQuery = v;
                    _showRequest = false;
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          _catalogResults.isEmpty
              ? AppStrings.noMatchesLabel
              : _searchQuery.isEmpty
                  ? AppStrings.popularLabel
                  : AppStrings.resultsLabel,
          style: AppTypography.overline.copyWith(color: AppColors.textHint),
        ),

        const SizedBox(height: 10),

        ..._catalogResults.map((item) {
          final active = _selected?.name == item.name;
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
                          Text(item.name, style: AppTypography.labelMd),
                          Text(
                            [item.genericName, item.strength, item.form]
                                .join(' · '),
                            style: AppTypography.bodySm,
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
              child: Text(
                AppStrings.cantFindIt,
                style:
                    AppTypography.bodySm.copyWith(color: AppColors.teal),
              ),
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
                    Expanded(
                        child: Text(AppStrings.requestMedicine,
                            style: AppTypography.labelMd)),
                    GestureDetector(
                      onTap: () => setState(() => _showRequest = false),
                      child: Text(AppStrings.cancel,
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(AppStrings.requestDesc, style: AppTypography.bodySm),
                const SizedBox(height: 14),
                _FieldRow(
                    label: AppStrings.medicineNameLabel,
                    controller: _reqNameCtrl,
                    hint: 'e.g. 3 Mix Cream'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.requestSubmitted,
                            style: AppTypography.bodySm),
                        backgroundColor: context.inputBg,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.teal),
                  child: Text(AppStrings.submitRequest,
                      style: AppTypography.buttonMd
                          .copyWith(color: AppColors.textInverse)),
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
                        Text(opt.$3,
                            style: AppTypography.labelMd
                                .copyWith(color: active ? opt.$5 : null)),
                        Text(opt.$4, style: AppTypography.bodySm),
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
        Text('Frequency',
            style: AppTypography.overline.copyWith(color: AppColors.textHint)),
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
                  style: AppTypography.labelSm.copyWith(
                    color: active ? AppColors.teal : AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (_freq != 'prn') ...[
          const SizedBox(height: 20),
          Text('Dose times',
              style:
                  AppTypography.overline.copyWith(color: AppColors.textHint)),
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
                      Text(t,
                          style: AppTypography.labelMd
                              .copyWith(color: AppColors.teal)),
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

          Text(AppStrings.foodRelation,
              style:
                  AppTypography.overline.copyWith(color: AppColors.textHint)),
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
                          style: AppTypography.labelSm.copyWith(
                            color: active
                                ? AppColors.teal
                                : AppColors.textSecondary,
                            letterSpacing: 0,
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
            child: Text(
              AppStrings.scheduleOptional,
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.purple.withValues(alpha: 0.9)),
            ),
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
        Text(AppStrings.stockOptional, style: AppTypography.bodySm),
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
            style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
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
            style: AppTypography.bodyMd,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
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

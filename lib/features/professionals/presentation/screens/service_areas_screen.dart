import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/service_area_provider.dart';

class ServiceAreasScreen extends ConsumerStatefulWidget {
  const ServiceAreasScreen({super.key});

  @override
  ConsumerState<ServiceAreasScreen> createState() => _ServiceAreasScreenState();
}

class _ServiceAreasScreenState extends ConsumerState<ServiceAreasScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _pincodeMode = false;
  bool _showRequestModal = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final notifier = ref.read(serviceAreaProvider.notifier);

    if (_pincodeMode) {
      final clean = value.replaceAll(RegExp(r'\D'), '');
      if (clean.length == 6) {
        notifier.search(pincode: clean);
      } else {
        notifier.clearSearch();
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      notifier.search(query: value);
    });
  }

  void _editRates(MyArea area) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RateSheet(
        title: area.name,
        subtitle: '${area.district}, ${area.state}',
        hourly: area.hourlyRate,
        daily: area.dailyRate,
        monthly: area.monthlyRate,
        onSave: (h, d, m) => ref
            .read(serviceAreaProvider.notifier)
            .setAreaRates(area.id, hourlyRate: h, dailyRate: d, monthlyRate: m),
      ),
    );
  }

  void _addArea(SelectableArea area) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAreaSheet(
        areaName: area.name,
        subtitle: '${area.district}, ${area.state}',
        onConfirm: (useDefault, h, d, m) =>
            ref.read(serviceAreaProvider.notifier).addArea(
                  area,
                  hourlyRate: useDefault ? null : h,
                  dailyRate: useDefault ? null : d,
                  monthlyRate: useDefault ? null : m,
                ),
      ),
    );
  }

  void _addDistrict() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DistrictSheet(
        onSave: (state, district, h, d, m) => ref
            .read(serviceAreaProvider.notifier)
            .addDistrict(
              state_: state,
              district: district,
              hourlyRate: h,
              dailyRate: d,
              monthlyRate: m,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceAreaProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Stack(
        children: [
          Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.primaryText),
            onPressed: () => context.pop(),
          ),
          title: AppText.h3('Service Areas'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => setState(() => _showRequestModal = true),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 18, color: AppColors.teal),
                      const SizedBox(width: 4),
                      AppText.labelSm('Request', color: AppColors.teal),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Intro ──────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.teal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText.bodySm(
                        'Patients in these areas will see your profile. Add the localities you serve.',
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search toggle + field ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            _pincodeMode ? Icons.pin_drop_rounded : Icons.search_rounded,
                            size: 18, color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              keyboardType: _pincodeMode ? TextInputType.number : TextInputType.text,
                              maxLength: _pincodeMode ? 6 : null,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: _pincodeMode ? 'Enter 6-digit pincode' : 'Search area or district',
                                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _pincodeMode = !_pincodeMode);
                      _searchCtrl.clear();
                      ref.read(serviceAreaProvider.notifier).clearSearch();
                    },
                    child: Container(
                      height: 48, width: 48,
                      decoration: BoxDecoration(
                        color: _pincodeMode ? AppColors.teal.withValues(alpha: 0.12) : context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(
                          color: _pincodeMode ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                        ),
                      ),
                      child: Icon(
                        Icons.pin_drop_rounded,
                        size: 18,
                        color: _pincodeMode ? AppColors.teal : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // Search results
                  if (state.isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
                    )
                  else if (state.searchResults.isNotEmpty) ...[
                    _SectionLabel('Search Results'),
                    const SizedBox(height: 8),
                    ...state.searchResults.map((area) {
                      final selected = state.isSelected(area.id);
                      return _AreaResultTile(
                        name: area.name,
                        subtitle: '${area.district}, ${area.state} · ${area.pincodeCount} pincodes',
                        selected: selected,
                        onTap: () {
                          if (selected) {
                            ref.read(serviceAreaProvider.notifier).removeArea(area.id);
                          } else {
                            _addArea(area);
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // My areas
                  _SectionLabel('My Service Areas (${state.myAreas.length})'),
                  const SizedBox(height: 8),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
                    )
                  else if (state.myAreas.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.location_off_rounded, size: 28, color: AppColors.textHint),
                          const SizedBox(height: 8),
                          AppText.bodySm('No areas added yet', color: context.secondaryText),
                          AppText.bodyXs('Search above to add areas you serve', color: AppColors.textHint),
                        ],
                      ),
                    )
                  else
                    ...state.myAreas.map((area) => _MyAreaTile(
                          area: area,
                          onEditRates: () => _editRates(area),
                          onRemove: () => ref.read(serviceAreaProvider.notifier).removeArea(area.id),
                        )),

                  // Whole-district coverage
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel('Whole Districts (${state.myDistricts.length})'),
                      GestureDetector(
                        onTap: _addDistrict,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.add_rounded, size: 16, color: AppColors.teal),
                          const SizedBox(width: 2),
                          AppText.labelSm('Add', color: AppColors.teal),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText.bodyXs(
                    'Cover every locality in a district with one rate set.',
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  if (state.myDistricts.isEmpty)
                    AppText.bodyXs('No districts added.', color: AppColors.textHint)
                  else
                    ...state.myDistricts.map((d) => _MyDistrictTile(
                          district: d,
                          onRemove: () =>
                              ref.read(serviceAreaProvider.notifier).removeDistrict(d.id),
                        )),

                  // Requested areas (localities the pro asked us to add)
                  if (state.myRequests.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _SectionLabel('Requested Areas (${state.myRequests.length})'),
                    const SizedBox(height: 4),
                    AppText.bodyXs(
                      'New localities you submitted. We review and add them — '
                      'once approved they become selectable above.',
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 8),
                    ...state.myRequests.map((r) => _RequestedAreaTile(request: r)),
                  ],
                ],
              ),
            ),
          ],
        ),
          ),
          if (_showRequestModal)
            _RequestAreaModal(
              onClose: () => setState(() => _showRequestModal = false),
              onSubmit: (name, pincodes, stateName, district) async {
                try {
                  await ref.read(serviceAreaProvider.notifier).requestNewArea(
                    name: name,
                    pincodes: pincodes,
                    stateName: stateName,
                    district: district,
                  );
                  if (mounted && context.mounted) {
                    setState(() => _showRequestModal = false);
                    AppSnackbar.success(
                        context, 'Area request submitted for admin review');
                  }
                } catch (e) {
                  if (mounted && context.mounted) {
                    AppSnackbar.error(context, 'Error: ${e.toString()}');
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}

// ─── Request Area Modal ───────────────────────────────────────────────────────

class _RequestAreaModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String name, String pincodes, String state, String district) onSubmit;
  const _RequestAreaModal({required this.onClose, required this.onSubmit});

  @override
  State<_RequestAreaModal> createState() => _RequestAreaModalState();
}

class _RequestAreaModalState extends State<_RequestAreaModal> {
  late final _nameCtrl = TextEditingController();
  late final _pincodesCtrl = TextEditingController();
  late final _stateCtrl = TextEditingController();
  late final _districtCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pincodesCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _pincodesCtrl.text.trim().isEmpty ||
        _stateCtrl.text.trim().isEmpty ||
        _districtCtrl.text.trim().isEmpty) {
      AppSnackbar.warning(context, 'Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(
        _nameCtrl.text.trim(),
        _pincodesCtrl.text.trim(),
        _stateCtrl.text.trim(),
        _districtCtrl.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: c.borderCol),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.h3('Request New Area'),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Icon(Icons.close_rounded, color: c.primaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppText.bodySm('Fill in the details of the area you want to serve', color: c.secondaryText),
                const SizedBox(height: 20),
                _TextField(
                  label: 'Area Name',
                  hint: 'e.g., Ganeshguri',
                  controller: _nameCtrl,
                  maxLength: 200,
                ),
                const SizedBox(height: 12),
                _TextField(
                  label: 'Pincodes',
                  hint: 'e.g., 781006,781007',
                  controller: _pincodesCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _TextField(
                  label: 'State',
                  hint: 'e.g., Assam',
                  controller: _stateCtrl,
                ),
                const SizedBox(height: 12),
                _TextField(
                  label: 'District',
                  hint: 'e.g., Kamrup Metropolitan',
                  controller: _districtCtrl,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : widget.onClose,
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.inputBg,
                            border: Border.all(color: c.borderCol),
                            borderRadius: AppBorderRadius.mdAll,
                          ),
                          child: AppText.labelMd('Cancel', color: c.primaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isLoading ? AppColors.teal.withValues(alpha: 0.5) : AppColors.teal,
                            borderRadius: AppBorderRadius.mdAll,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : AppText.labelMd('Submit', color: Colors.white),
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
    );
  }
}

class _TextField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.labelSm(label, color: context.primaryText),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: AppBorderRadius.mdAll),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.borderCol),
              borderRadius: AppBorderRadius.mdAll,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: AppColors.textHint, letterSpacing: 1,
        ),
      );
}

class _AreaResultTile extends StatelessWidget {
  final String name, subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _AreaResultTile({
    required this.name, required this.subtitle,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal.withValues(alpha: 0.08) : context.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(
              color: selected ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMd(name, color: context.primaryText),
                    const SizedBox(height: 2),
                    AppText.bodyXs(subtitle, color: context.secondaryText),
                  ],
                ),
              ),
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: selected ? AppColors.teal : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.teal : context.borderCol, width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                    : const Icon(Icons.add_rounded, size: 15, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Format optional per-area/district rates into a short summary line.
String _rateSummary(int? hourly, int? daily, int? monthly) {
  final parts = <String>[
    if (hourly != null) '₹$hourly/hr',
    if (daily != null) '₹$daily/day',
    if (monthly != null) '₹$monthly/mo',
  ];
  return parts.isEmpty ? 'Using your default rates' : parts.join('  ·  ');
}

class _MyAreaTile extends StatelessWidget {
  final MyArea area;
  final VoidCallback onEditRates;
  final VoidCallback onRemove;
  const _MyAreaTile({
    required this.area,
    required this.onEditRates,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final custom = area.hasRates;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onEditRates,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Row(
            children: [
              AppContainer.tinted(
                color: AppColors.teal,
                borderRadius: AppBorderRadius.smAll,
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.labelMd(area.name, color: context.primaryText),
                    const SizedBox(height: 2),
                    AppText.bodyXs('${area.district}, ${area.state}',
                        color: context.secondaryText),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.payments_rounded,
                          size: 12,
                          color: custom ? AppColors.teal : AppColors.textHint),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AppText.bodyXs(
                          _rateSummary(area.hourlyRate, area.dailyRate, area.monthlyRate),
                          color: custom ? AppColors.teal : AppColors.textHint,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.edit_rounded, size: 15, color: AppColors.textHint),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 18, color: AppColors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyDistrictTile extends StatelessWidget {
  final MyDistrict district;
  final VoidCallback onRemove;
  const _MyDistrictTile({required this.district, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            AppContainer.tinted(
              color: AppColors.blue,
              borderRadius: AppBorderRadius.smAll,
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.map_rounded, size: 16, color: AppColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelMd('${district.district} (whole district)',
                      color: context.primaryText),
                  const SizedBox(height: 2),
                  AppText.bodyXs(district.state, color: context.secondaryText),
                  const SizedBox(height: 4),
                  AppText.bodyXs(
                    _rateSummary(district.hourlyRate, district.dailyRate, district.monthlyRate),
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 18, color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rate editor sheet (per-area or per-district) ─────────────────────────────

class _RateSheet extends StatefulWidget {
  final String title, subtitle;
  final int? hourly, daily, monthly;
  final Future<void> Function(int? hourly, int? daily, int? monthly) onSave;
  const _RateSheet({
    required this.title,
    required this.subtitle,
    required this.hourly,
    required this.daily,
    required this.monthly,
    required this.onSave,
  });

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  late final _h = TextEditingController(text: widget.hourly?.toString() ?? '');
  late final _d = TextEditingController(text: widget.daily?.toString() ?? '');
  late final _m = TextEditingController(text: widget.monthly?.toString() ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _h.dispose();
    _d.dispose();
    _m.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_parse(_h), _parse(_d), _parse(_m));
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not save rates');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Rates · ${widget.title}',
      subtitle: widget.subtitle,
      saving: _saving,
      onSave: _save,
      children: [
        AppText.bodyXs('Leave a field blank to use your profile default rate.',
            color: AppColors.textHint),
        const SizedBox(height: 12),
        _RateField(label: 'Per hour (₹)', controller: _h),
        const SizedBox(height: 10),
        _RateField(label: 'Per day (₹)', controller: _d),
        const SizedBox(height: 10),
        _RateField(label: 'Per month (₹)', controller: _m),
      ],
    );
  }
}

// ─── Add-district sheet ───────────────────────────────────────────────────────

class _DistrictSheet extends StatefulWidget {
  final Future<void> Function(String state, String district, int? h, int? d, int? m) onSave;
  const _DistrictSheet({required this.onSave});

  @override
  State<_DistrictSheet> createState() => _DistrictSheetState();
}

class _DistrictSheetState extends State<_DistrictSheet> {
  final _state = TextEditingController();
  final _district = TextEditingController();
  final _h = TextEditingController();
  final _d = TextEditingController();
  final _m = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _state.dispose();
    _district.dispose();
    _h.dispose();
    _d.dispose();
    _m.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  Future<void> _save() async {
    if (_state.text.trim().isEmpty || _district.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Enter both state and district');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _state.text.trim(),
        _district.text.trim(),
        _parse(_h),
        _parse(_d),
        _parse(_m),
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'District not found in our system');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Serve a whole district',
      subtitle: 'Covers every locality in the district.',
      saving: _saving,
      onSave: _save,
      children: [
        _RateField(label: 'State', controller: _state, number: false),
        const SizedBox(height: 10),
        _RateField(label: 'District', controller: _district, number: false),
        const SizedBox(height: 14),
        AppText.bodyXs('Optional rates — blank uses your profile default.',
            color: AppColors.textHint),
        const SizedBox(height: 10),
        _RateField(label: 'Per hour (₹)', controller: _h),
        const SizedBox(height: 10),
        _RateField(label: 'Per day (₹)', controller: _d),
        const SizedBox(height: 10),
        _RateField(label: 'Per month (₹)', controller: _m),
      ],
    );
  }
}

// Shared bottom-sheet chrome.
class _SheetScaffold extends StatelessWidget {
  final String title, subtitle;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget> children;
  final String saveLabel;
  const _SheetScaffold({
    required this.title,
    required this.subtitle,
    required this.saving,
    required this.onSave,
    required this.children,
    this.saveLabel = 'Save',
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderCol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppText.h3(title),
            const SizedBox(height: 2),
            AppText.bodyXs(subtitle, color: context.secondaryText),
            const SizedBox(height: 16),
            ...children,
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                variant: AppButtonVariant.primary,
                label: saveLabel,
                onPressed: saving ? null : onSave,
                isLoading: saving,
                size: AppButtonSize.lg,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool number;
  const _RateField({required this.label, required this.controller, this.number = true});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
    );
  }
}

class _RequestedAreaTile extends StatelessWidget {
  final AreaRequest request;
  const _RequestedAreaTile({required this.request});

  ({Color color, IconData icon, String label}) get _status {
    switch (request.status) {
      case 'APPROVED':
        return (color: AppColors.green, icon: Icons.check_circle_rounded, label: 'Approved');
      case 'REJECTED':
        return (color: AppColors.red, icon: Icons.cancel_rounded, label: 'Rejected');
      default:
        return (color: AppColors.amber, icon: Icons.hourglass_top_rounded, label: 'Pending review');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                AppContainer.tinted(
                  color: s.color,
                  borderRadius: AppBorderRadius.smAll,
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.add_location_alt_rounded, size: 16, color: s.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.labelMd(request.name, color: context.primaryText),
                      const SizedBox(height: 2),
                      AppText.bodyXs('${request.district}, ${request.state}',
                          color: context.secondaryText),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.smAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 12, color: s.color),
                      const SizedBox(width: 4),
                      AppText.labelSm(s.label, color: s.color),
                    ],
                  ),
                ),
              ],
            ),
            if (request.status == 'REJECTED' &&
                (request.adminNotes?.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.06),
                  borderRadius: AppBorderRadius.smAll,
                ),
                child: AppText.bodyXs('Reason: ${request.adminNotes!.trim()}',
                    color: context.secondaryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Add-area sheet: choose default vs custom price, then confirm ──────────────

class _AddAreaSheet extends StatefulWidget {
  final String areaName;
  final String subtitle;
  // useDefault=true → fall back to profile rates; else the per-area rates given.
  final Future<void> Function(bool useDefault, int? hourly, int? daily, int? monthly)
      onConfirm;
  const _AddAreaSheet({
    required this.areaName,
    required this.subtitle,
    required this.onConfirm,
  });

  @override
  State<_AddAreaSheet> createState() => _AddAreaSheetState();
}

class _AddAreaSheetState extends State<_AddAreaSheet> {
  bool _custom = false;
  bool _saving = false;
  final _h = TextEditingController();
  final _d = TextEditingController();
  final _m = TextEditingController();

  @override
  void dispose() {
    _h.dispose();
    _d.dispose();
    _m.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  Future<void> _confirm() async {
    if (_custom && _parse(_h) == null && _parse(_d) == null && _parse(_m) == null) {
      AppSnackbar.error(context, 'Enter at least one custom rate, or use the base price');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onConfirm(
        !_custom,
        _custom ? _parse(_h) : null,
        _custom ? _parse(_d) : null,
        _custom ? _parse(_m) : null,
      );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not add area');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Add ${widget.areaName}',
      subtitle: widget.subtitle,
      saveLabel: 'Confirm & Add',
      saving: _saving,
      onSave: _confirm,
      children: [
        AppText.labelSm('Pricing for this area', color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _PriceChoiceChip(
              label: 'Base price',
              hint: 'Use your default rates',
              selected: !_custom,
              onTap: () => setState(() => _custom = false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PriceChoiceChip(
              label: 'New price',
              hint: 'Set rates for this area',
              selected: _custom,
              onTap: () => setState(() => _custom = true),
            ),
          ),
        ]),
        if (_custom) ...[
          const SizedBox(height: 14),
          AppText.bodyXs('Leave a field blank to use your profile default.',
              color: AppColors.textHint),
          const SizedBox(height: 10),
          _RateField(label: 'Per hour (₹)', controller: _h),
          const SizedBox(height: 10),
          _RateField(label: 'Per day (₹)', controller: _d),
          const SizedBox(height: 10),
          _RateField(label: 'Per month (₹)', controller: _m),
        ] else ...[
          const SizedBox(height: 10),
          AppText.bodyXs("Patients here will see your profile's default rates.",
              color: AppColors.textHint),
        ],
      ],
    );
  }
}

class _PriceChoiceChip extends StatelessWidget {
  final String label, hint;
  final bool selected;
  final VoidCallback onTap;
  const _PriceChoiceChip({
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withValues(alpha: 0.10) : context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: selected ? AppColors.teal : context.borderCol,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                size: 16,
                color: selected ? AppColors.teal : AppColors.textHint,
              ),
              const SizedBox(width: 6),
              AppText.labelMd(label,
                  color: selected ? AppColors.teal : context.primaryText),
            ]),
            const SizedBox(height: 4),
            AppText.bodyXs(hint, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

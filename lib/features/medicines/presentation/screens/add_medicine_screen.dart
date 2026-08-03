import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../../patients/presentation/providers/patient_profiles_provider.dart';
import '../providers/medicines_provider.dart';
import '../widgets/widgets.dart';

/// Four-step add flow: pick from the catalog, choose who it's for, set the
/// schedule, record stock. Every step's input is submitted — the schedule
/// becomes a real DoseSchedule and the quantity a real stock entry.
class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  static const _steps = [
    AppStrings.addMedicineStep1,
    AppStrings.addMedicineStep2,
    AppStrings.addMedicineStep3,
    AppStrings.addMedicineStep4,
  ];

  int _step = 0;

  // ── Step 0: catalog ────────────────────────────────────────────────────────
  /// One request covers roughly two screens of rows, so the next page is
  /// already in flight before the user reaches the bottom.
  static const _pageSize = 20;

  /// Distance from the bottom at which the next page starts loading.
  static const _prefetchExtent = 400.0;

  final _searchCtrl = TextEditingController();
  final _catalogScrollCtrl = ScrollController();
  Timer? _searchDebounce;

  String _searchQuery = '';
  CatalogMedicineEntity? _selected;
  final List<CatalogMedicineEntity> _catalogItems = [];
  int _catalogPage = 0;
  int _catalogTotal = 0;
  bool _catalogHasMore = true;

  /// Bumped on every reset so a slow response from a superseded search can be
  /// recognised and discarded.
  int _catalogSeq = 0;

  /// First page of a (re)search — the list is replaced, so show a spinner
  /// instead of the rows.
  bool _catalogLoading = false;

  /// A follow-up page — the existing rows stay put under a footer spinner.
  bool _catalogLoadingMore = false;

  String? _catalogError;
  bool _showRequest = false;
  bool _requesting = false;
  final _reqNameCtrl = TextEditingController();

  // ── Step 1: who for ────────────────────────────────────────────────────────
  String _whoMode = 'self';
  String? _patientProfileId;

  /// Members of a shared bottle. Multi-select — the endpoint creates one
  /// member entry per profile.
  final Set<String> _sharedProfileIds = {};

  bool get _isShared => _whoMode == 'shared';

  // ── Step 2: schedule ───────────────────────────────────────────────────────
  static const _freqOptions = <(String, String, List<String>)>[
    ('once', AppStrings.onceDaily, ['09:00']),
    ('twice', AppStrings.twiceDaily, ['09:00', '21:00']),
    ('three', AppStrings.threeDaily, ['08:00', '14:00', '21:00']),
    ('prn', AppStrings.asNeeded, <String>[]),
  ];
  static const _foodOptions = <(String, String)>[
    ('BEFORE', AppStrings.beforeFood),
    ('WITH', AppStrings.withFood),
    ('AFTER', AppStrings.afterFood),
  ];

  String _freq = 'twice';
  List<String> _times = ['09:00', '21:00'];
  String _food = 'WITH';
  final _doseCtrl = TextEditingController(text: '1 tablet');

  /// Null = ongoing, the default and what every schedule did before duration
  /// existed. A number is a fixed course in days, counting today.
  int? _durationDays;
  static const _durationOptions = <int?>[null, 3, 5, 7, 14, 30];

  bool get _isPrn => _freq == 'prn';

  /// Inclusive last day of the course — the backend treats endDate as covering
  /// that whole local day, so a 5-day course ends 4 days from today.
  DateTime? get _endDate {
    if (_durationDays == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: _durationDays! - 1));
  }

  // ── Step 3: stock ──────────────────────────────────────────────────────────
  final _qtyCtrl = TextEditingController(text: '30');
  DateTime? _expiry;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _catalogScrollCtrl.addListener(_onCatalogScroll);
    _loadNextPage(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _catalogScrollCtrl.dispose();
    _searchCtrl.dispose();
    _reqNameCtrl.dispose();
    _doseCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  // ── Catalog ────────────────────────────────────────────────────────────────

  void _onCatalogScroll() {
    if (!_catalogScrollCtrl.hasClients) return;
    final remaining = _catalogScrollCtrl.position.maxScrollExtent -
        _catalogScrollCtrl.position.pixels;
    if (remaining <= _prefetchExtent) _loadNextPage();
  }

  /// Loads the page after the last one held. [reset] starts over from page 1 —
  /// used on mount, on retry, and whenever the query changes.
  Future<void> _loadNextPage({bool reset = false}) async {
    // A reset must never be dropped: it carries a new query, and the in-flight
    // request it supersedes is invalidated by the sequence check below.
    if (!reset && (_catalogLoading || _catalogLoadingMore)) return;
    if (!reset && !_catalogHasMore) return;

    final query = _searchQuery;
    final nextPage = reset ? 1 : _catalogPage + 1;
    final seq = reset ? ++_catalogSeq : _catalogSeq;

    setState(() {
      _catalogError = null;
      if (reset) {
        _catalogLoading = true;
        _catalogLoadingMore = false;
      } else {
        _catalogLoadingMore = true;
      }
    });

    try {
      final result = await ref
          .read(medicinesRepositoryProvider)
          .searchCatalog(query, page: nextPage, limit: _pageSize);
      // A newer search started while this was in flight — appending its rows
      // would mix results from two different queries into one list.
      if (!mounted || seq != _catalogSeq) return;
      setState(() {
        if (reset) _catalogItems.clear();
        _catalogItems.addAll(result.items);
        _catalogPage = result.page;
        _catalogTotal = result.total;
        _catalogHasMore = result.hasMore;
        _catalogLoading = false;
        _catalogLoadingMore = false;
      });
      _prefetchIfViewportUnfilled();
    } on Exception catch (e) {
      if (!mounted || seq != _catalogSeq) return;
      setState(() {
        _catalogLoading = false;
        _catalogLoadingMore = false;
        _catalogError = e.toString();
      });
    }
  }

  /// The scroll listener can only fire once there is something to scroll. When
  /// a page doesn't fill the viewport (few results, or a tall screen) nothing
  /// would ever request the next one, so top up until it does.
  void _prefetchIfViewportUnfilled() {
    if (!_catalogHasMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_catalogScrollCtrl.hasClients) return;
      if (_catalogScrollCtrl.position.maxScrollExtent <= 0) _loadNextPage();
    });
  }

  /// Debounced so typing a word issues one request, not one per character.
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _showRequest = false;
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadNextPage(reset: true),
    );
  }

  Future<void> _submitRequest() async {
    final name = _reqNameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _requesting = true);
    try {
      await ref
          .read(medicinesRepositoryProvider)
          .requestMedicine(medicineName: name);
      if (!mounted) return;
      setState(() {
        _requesting = false;
        _showRequest = false;
        _reqNameCtrl.clear();
      });
      AppSnackbar.success(context, AppStrings.requestSubmitted);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _requesting = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  // ── Schedule editing ───────────────────────────────────────────────────────

  void _setFreq(String f) {
    final opt = _freqOptions.firstWhere((x) => x.$1 == f);
    setState(() {
      _freq = f;
      _times = List<String>.from(opt.$3);
    });
  }

  /// Picking a time keeps the list sorted so the review step, the reminders,
  /// and the cabinet card all read in chronological order.
  Future<void> _editTime(int index) async {
    final current = _times[index].split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(current.first) ?? 9,
        minute: int.tryParse(current.last) ?? 0,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _times[index] = _formatTime(picked);
      _times.sort();
      // Editing onto an existing slot is a duplicate reminder, not a second
      // dose — the backend would happily store both.
      _times = _times.toSet().toList()..sort();
      _freq = 'custom';
    });
  }

  Future<void> _addTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null || !mounted) return;
    final value = _formatTime(picked);
    if (_times.contains(value)) return;
    setState(() {
      _times = [..._times, value]..sort();
      _freq = 'custom';
    });
  }

  void _removeTime(int index) => setState(() {
        _times = [..._times]..removeAt(index);
        _freq = 'custom';
      });

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? DateTime(now.year + 1, now.month),
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null && mounted) setState(() => _expiry = picked);
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  bool get _canProceed {
    if (_saving) return false;
    if (_step == 0) return _selected != null;
    // Choosing a mode without naming anyone would silently add the medicine
    // to your own cabinet.
    if (_step == 1) {
      if (_whoMode == 'patient') return _patientProfileId != null;
      if (_isShared) return _sharedProfileIds.isNotEmpty;
    }
    // A non-PRN schedule with no times would silently produce no reminders.
    if (_step == 2) return _isPrn || _times.isNotEmpty;
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
    final selected = _selected;
    if (selected == null) return;
    setState(() => _saving = true);
    try {
      if (_isShared) {
        await ref.read(medicinesProvider.notifier).addSharedMedicine(
              medicineId: selected.isProduct ? null : selected.id,
              productId: selected.isProduct ? selected.id : null,
              memberPatientProfileIds: _sharedProfileIds.toList(),
            );
        if (!mounted) return;
        context.pop();
        // The shared endpoint takes neither a schedule nor stock — each member
        // gets its own schedule, and stock lives on the master. Say so rather
        // than silently dropping what was typed in the later steps.
        AppSnackbar.success(context,
            'Shared medicine added. Set doses and stock from the medicine.');
        return;
      }

      final quantity = int.tryParse(_qtyCtrl.text.trim());
      final warnings =
          await ref.read(medicinesProvider.notifier).addMedicine(
                // The catalog merges two tables — sending a product's id as
                // medicineId fails the foreign key and nothing is created.
                medicineId: selected.isProduct ? null : selected.id,
                productId: selected.isProduct ? selected.id : null,
                patientProfileId:
                    _whoMode == 'patient' ? _patientProfileId : null,
                doseTimes: _isPrn ? const [] : _times,
                isPrn: _isPrn,
                doseAmount: _doseCtrl.text,
                foodTiming: _food,
                stockQuantity: quantity,
                expiryDate: _expiry?.toIso8601String(),
                endDate: _endDate,
              );
      if (!mounted) return;
      context.pop();
      if (warnings.isEmpty) {
        AppSnackbar.success(context, 'Medicine added successfully.');
      } else {
        AppSnackbar.error(context, warnings.join(' '));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close_rounded, color: context.primaryText),
          ),
          title: AppText.h3(AppStrings.addMedicine),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.borderCol),
          ),
        ),
        body: Column(
          children: [
            _StepIndicator(steps: _steps, current: _step),
            Container(height: 1, color: context.borderCol),
            Expanded(
              child: SingleChildScrollView(
                // Step 0 pages the catalog, so it needs a controller to know
                // when the bottom is near. The other steps are short forms.
                controller: _step == 0 ? _catalogScrollCtrl : null,
                key: ValueKey(_step),
                padding: const EdgeInsets.all(20),
                child: switch (_step) {
                  0 => _buildCatalogStep(),
                  1 => _buildWhoStep(),
                  2 => _buildScheduleStep(),
                  _ => _buildStockStep(),
                },
              ),
            ),
            _BottomBar(
              showBack: _step > 0,
              onBack: () => setState(() => _step--),
              onNext: _canProceed ? _next : null,
              label: _saving
                  ? AppStrings.saving
                  : _step == _steps.length - 1
                      ? AppStrings.save
                      : AppStrings.next,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 0: find medicine ──────────────────────────────────────────────────

  Widget _buildCatalogStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchTextInput(
          controller: _searchCtrl,
          hint: AppStrings.searchMedicines,
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 16),
        if (_catalogLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: AppLoadingSpinner()),
          )
        else if (_catalogError != null && _catalogItems.isEmpty)
          AppEmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load the catalog',
            subtitle: _catalogError,
            action: () => _loadNextPage(reset: true),
            actionLabel: 'Retry',
          )
        else ...[
          AppSectionHeaderText(
            title: _catalogItems.isEmpty
                ? AppStrings.noMatchesLabel
                : _searchQuery.isEmpty
                    ? AppStrings.popularLabel
                    : AppStrings.resultsLabel,
            // Total across all pages, not just what's loaded — otherwise the
            // count would climb as the user scrolls.
            subtitle: _catalogTotal > 0 ? '$_catalogTotal available' : null,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 10),
          for (final item in _catalogItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CatalogRow(
                item: item,
                selected: _selected?.id == item.id,
                onTap: () => setState(() => _selected = item),
              ),
            ),
          if (_catalogLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: AppLoadingSpinner(size: 20)),
            )
          else if (_catalogError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: TextButton(
                  onPressed: () => _loadNextPage(),
                  child: AppText.bodySm('Couldn\'t load more — retry',
                      color: AppColors.teal),
                ),
              ),
            ),
        ],
        const SizedBox(height: 8),
        if (!_showRequest)
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _showRequest = true;
                _reqNameCtrl.text = _searchQuery;
              }),
              child:
                  AppText.bodySm(AppStrings.cantFindIt, color: AppColors.teal),
            ),
          )
        else
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: AppText.labelMd(AppStrings.requestMedicine)),
                    GestureDetector(
                      onTap: () => setState(() => _showRequest = false),
                      child: AppText.bodySm(AppStrings.cancel,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AppText.bodySm(AppStrings.requestDesc),
                const SizedBox(height: 14),
                AppTextField(
                  label: AppStrings.medicineNameLabel,
                  controller: _reqNameCtrl,
                  hint: 'e.g. 3 Mix Cream',
                ),
                const SizedBox(height: 12),
                AppButton(
                  variant: AppButtonVariant.primary,
                  label: AppStrings.submitRequest,
                  isFullWidth: true,
                  isLoading: _requesting,
                  onPressed: _requesting ? null : _submitRequest,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Step 1: who for ────────────────────────────────────────────────────────

  Widget _buildWhoStep() {
    final profiles = ref.watch(patientProfilesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectableTile(
          selected: _whoMode == 'self',
          enabled: true,
          color: AppColors.teal,
          leading: const Icon(Icons.person_rounded, size: 20),
          title: AppStrings.whoForYou,
          subtitle: AppStrings.whoForYouDesc,
          onTap: () => setState(() {
            _whoMode = 'self';
            _patientProfileId = null;
          }),
        ),
        const SizedBox(height: 12),
        _SelectableTile(
          selected: _whoMode == 'patient',
          // Without a patient profile there is nobody to add it for, so the
          // option stays closed rather than silently falling back to "self".
          enabled: profiles.valueOrNull?.isNotEmpty ?? false,
          color: AppColors.blue,
          leading: const Icon(Icons.people_rounded, size: 20),
          title: AppStrings.whoForPatient,
          subtitle: switch (profiles) {
            AsyncLoading() => 'Loading your patients…',
            AsyncError() => 'Could not load your patients',
            _ => (profiles.valueOrNull?.isEmpty ?? true)
                ? 'Add a patient first to use this'
                : AppStrings.whoForPatientDesc,
          },
          onTap: () => setState(() => _whoMode = 'patient'),
        ),
        // The picker only appears once this mode is chosen — showing every
        // patient up front would bury the two common cases.
        if (_whoMode == 'patient') ...[
          const SizedBox(height: 12),
          for (final p in profiles.valueOrNull ?? const [])
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 12),
              child: _SelectableTile(
                selected: _patientProfileId == p.id,
                enabled: true,
                color: AppColors.blue,
                leading: const Icon(Icons.account_circle_rounded, size: 20),
                title: p.name,
                subtitle: [
                  if (p.age != null) '${p.age} yrs',
                  if (p.bloodGroup != null) p.bloodGroup!,
                ].join(' · '),
                onTap: () => setState(() => _patientProfileId = p.id),
              ),
            ),
        ],
        const SizedBox(height: 12),
        _SelectableTile(
          selected: _isShared,
          // One bottle split across several patients, so it needs at least
          // one profile to share with.
          enabled: profiles.valueOrNull?.isNotEmpty ?? false,
          color: AppColors.purple,
          leading: const Icon(Icons.share_rounded, size: 20),
          title: AppStrings.whoShared,
          subtitle: (profiles.valueOrNull?.isEmpty ?? true)
              ? 'Add a patient first to use this'
              : AppStrings.whoSharedDesc,
          onTap: () => setState(() {
            _whoMode = 'shared';
            _patientProfileId = null;
          }),
        ),
        if (_isShared) ...[
          const SizedBox(height: 12),
          for (final p in profiles.valueOrNull ?? const [])
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 12),
              child: _SelectableTile(
                selected: _sharedProfileIds.contains(p.id),
                enabled: true,
                color: AppColors.purple,
                leading: const Icon(Icons.account_circle_rounded, size: 20),
                title: p.name,
                subtitle: [
                  if (p.age != null) '${p.age} yrs',
                  if (p.bloodGroup != null) p.bloodGroup!,
                ].join(' · '),
                onTap: () => setState(() {
                  if (!_sharedProfileIds.remove(p.id)) {
                    _sharedProfileIds.add(p.id);
                  }
                }),
              ),
            ),
          AppText.bodyXs(
            'Everyone selected shares one bottle, so the stock is counted once.',
            color: AppColors.textHint,
          ),
        ],
      ],
    );
  }

  // ── Step 2: schedule ───────────────────────────────────────────────────────

  Widget _buildScheduleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeaderText(
            title: 'Frequency', padding: EdgeInsets.zero),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (key, label, _) in _freqOptions)
              AppFilterChip(
                label: label,
                selected: _freq == key,
                onTap: () => _setFreq(key),
              ),
            if (_freq == 'custom')
              AppFilterChip(
                  label: 'Custom', selected: true, onTap: () {}),
          ],
        ),
        if (_isPrn) ...[
          const SizedBox(height: 20),
          AppCard(
            color: AppColors.purple.withValues(alpha: 0.07),
            borderColor: AppColors.purple.withValues(alpha: 0.2),
            effectColor: AppColors.purple,
            child: AppText.bodyMd(AppStrings.scheduleOptional),
          ),
        ] else ...[
          const SizedBox(height: 20),
          AppSectionHeaderText(
            title: 'Dose times',
            padding: EdgeInsets.zero,
            actionLabel: 'Add time',
            actionIcon: Icons.add_rounded,
            onAction: _addTime,
          ),
          const SizedBox(height: 10),
          if (_times.isEmpty)
            AppText.bodySm('Add at least one time to get reminders.',
                color: AppColors.amber)
          else
            for (final (i, time) in _times.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TimeRow(
                  time: time,
                  onTap: () => _editTime(i),
                  // Removing the last time would leave a schedule that
                  // never fires — keep one.
                  onRemove: _times.length > 1 ? () => _removeTime(i) : null,
                ),
              ),
          const SizedBox(height: 20),
          AppTextField(
            label: AppStrings.doseAmount,
            controller: _doseCtrl,
            hint: AppStrings.doseAmountHint,
          ),
          const SizedBox(height: 16),
          const AppSectionHeaderText(
              title: AppStrings.foodRelation, padding: EdgeInsets.zero),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (key, label) in _foodOptions)
                AppFilterChip(
                  label: label,
                  selected: _food == key,
                  onTap: () => setState(() => _food = key),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const AppSectionHeaderText(
              title: 'Duration', padding: EdgeInsets.zero),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final days in _durationOptions)
                AppFilterChip(
                  label: days == null ? 'Ongoing' : '$days days',
                  selected: _durationDays == days,
                  onTap: () => setState(() => _durationDays = days),
                ),
            ],
          ),
          if (_endDate != null) ...[
            const SizedBox(height: 8),
            AppText.bodyXs(
              'Reminders stop after ${_endDate!.toIso8601String().split('T').first}.',
              color: AppColors.teal,
            ),
          ],
        ],
      ],
    );
  }

  // ── Step 3: stock ──────────────────────────────────────────────────────────

  Widget _buildStockStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodySm(AppStrings.stockOptional),
        const SizedBox(height: 20),
        AppTextField(
          label: AppStrings.quantityLabel,
          controller: _qtyCtrl,
          hint: AppStrings.stockQtyHint,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 14),
        // A typed "Dec 2026" can't be sent as a date — the picker guarantees
        // something the stock endpoint accepts.
        AppInfoLabelText(
          icon: Icons.event_busy_rounded,
          label: AppStrings.expiryLabel,
          value: _expiry == null
              ? 'Not set'
              : '${_expiry!.year}-${_expiry!.month.toString().padLeft(2, '0')}-${_expiry!.day.toString().padLeft(2, '0')}',
          onTap: _pickExpiry,
        ),
      ],
    );
  }
}

// ─── Step indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          for (final (i, label) in steps.indexed) ...[
            Expanded(
              child: Column(
                children: [
                  _StepDot(index: i, current: current),
                  const SizedBox(height: 4),
                  AppText.bodyXs(
                    label,
                    fontWeight: FontWeight.w700,
                    color: i <= current ? AppColors.teal : AppColors.textHint,
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1)
              Container(
                width: 20,
                height: 1,
                color: i < current ? AppColors.teal : context.borderCol,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    return AnimatedContainer(
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
          color: done || active ? AppColors.teal : context.borderCol,
          width: active ? 2 : 1,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded,
                size: 12, color: AppColors.textInverse)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  color: active ? AppColors.teal : AppColors.textHint,
                ),
              ),
      ),
    );
  }
}

// ─── Bottom bar ──────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.showBack,
    required this.onBack,
    required this.onNext,
    required this.label,
    required this.isLoading,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.viewInsetsOf(context).bottom),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              child: AppButton(
                variant: AppButtonVariant.secondary,
                label: AppStrings.back,
                isFullWidth: true,
                onPressed: onBack,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: AppButton(
              variant: AppButtonVariant.primary,
              label: label,
              isFullWidth: true,
              isLoading: isLoading,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Catalog row ─────────────────────────────────────────────────────────────

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CatalogMedicineEntity item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      color: selected ? AppColors.teal.withValues(alpha: 0.08) : null,
      borderColor: selected ? AppColors.teal.withValues(alpha: 0.4) : null,
      effectColor: selected ? AppColors.teal : null,
      child: AppListTile(
        color: Colors.transparent,
        leading: MedicineTypeIcon(
          type: item.dosageForm ?? '',
          size: 36,
          color: selected ? AppColors.teal : AppColors.textSecondary,
        ),
        title: item.name,
        subtitle: item.subtitle.isEmpty ? null : item.subtitle,
        trailing: selected
            ? const Icon(Icons.check_circle_rounded,
                color: AppColors.teal, size: 20)
            // Products and medicines look alike in the list but resolve to
            // different catalogs — worth saying which one this is.
            : item.isProduct
                ? const AppBadge(
                    label: 'Product', variant: AppBadgeVariant.neutral)
                : null,
        onTap: onTap,
      ),
    );
  }
}

// ─── Selectable tile ─────────────────────────────────────────────────────────

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.enabled,
    required this.color,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final Color color;
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected && enabled;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AppCard(
        onTap: enabled ? onTap : null,
        padding: EdgeInsets.zero,
        color: active ? color.withValues(alpha: 0.07) : null,
        borderColor: active ? color.withValues(alpha: 0.4) : null,
        effectColor: active ? color : null,
        child: AppListTile(
          color: Colors.transparent,
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.15)
                  : context.inputBg,
              borderRadius: AppBorderRadius.mdAll,
            ),
            child: IconTheme(
              data: IconThemeData(
                  color: active ? color : AppColors.textSecondary),
              child: leading,
            ),
          ),
          title: title,
          subtitle: subtitle,
          trailing: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : Colors.transparent,
              border: Border.all(
                  color: active ? color : context.borderCol, width: 2),
            ),
            child: active
                ? const Icon(Icons.check_rounded,
                    size: 11, color: AppColors.textInverse)
                : null,
          ),
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }
}

// ─── Dose time row ───────────────────────────────────────────────────────────

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.time, required this.onTap, this.onRemove});

  final String time;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            isNightDose(time) ? Icons.nightlight_round : Icons.wb_sunny_rounded,
            size: 16,
            color: isNightDose(time) ? AppColors.purple : AppColors.amber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.labelMd(formatDoseTime(time), color: AppColors.teal),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.textHint),
            ),
        ],
      ),
    );
  }
}

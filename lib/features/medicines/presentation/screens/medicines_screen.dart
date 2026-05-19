import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Mock data model ──────────────────────────────────────────────────────────

enum _MedScope { personal, sharedMaster, sharedMember }
enum _MedStatus { active, lowStock, prn }

class _Med {
  final String id, name, genericName, strength, form, usedFor, description;
  final List<String> times;
  final String food;
  final int stock;
  final String? expiry;
  final _MedScope scope;
  final _MedStatus status;

  const _Med({
    required this.id,
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
    this.scope = _MedScope.personal,
    this.status = _MedStatus.active,
  });
}

const _mockMeds = [
  _Med(
    id: '1',
    name: 'Metformin',
    genericName: 'Metformin HCl',
    strength: '500 mg',
    form: 'Tablet',
    usedFor: 'Type 2 Diabetes management',
    description: 'Helps control blood sugar levels. Take with meals to reduce GI side effects.',
    times: ['09:00', '21:00'],
    food: 'With food',
    stock: 42,
    expiry: 'Dec 2026',
  ),
  _Med(
    id: '2',
    name: 'Lisinopril',
    genericName: 'Lisinopril',
    strength: '10 mg',
    form: 'Tablet',
    usedFor: 'Hypertension & heart failure',
    description: 'ACE inhibitor that relaxes blood vessels. Avoid potassium-rich foods.',
    times: ['08:00'],
    food: 'Before food',
    stock: 5,
    expiry: 'Mar 2026',
    status: _MedStatus.lowStock,
  ),
  _Med(
    id: '3',
    name: 'Ibuprofen',
    genericName: 'Ibuprofen',
    strength: '400 mg',
    form: 'Tablet',
    usedFor: 'Pain & inflammation relief',
    description: 'NSAID for pain, fever, and inflammation. Take as needed with food.',
    times: [],
    food: 'With food',
    stock: 18,
    status: _MedStatus.prn,
    scope: _MedScope.personal,
  ),
  _Med(
    id: '4',
    name: 'Atorvastatin',
    genericName: 'Atorvastatin Calcium',
    strength: '20 mg',
    form: 'Tablet',
    usedFor: 'Cholesterol management',
    description: 'Statin that reduces LDL cholesterol. Take at night for best effect.',
    times: ['22:00'],
    food: 'After food',
    stock: 28,
    expiry: 'Aug 2026',
    scope: _MedScope.sharedMaster,
  ),
  _Med(
    id: '5',
    name: 'Amoxicillin',
    genericName: 'Amoxicillin Trihydrate',
    strength: '250 mg',
    form: 'Capsule',
    usedFor: 'Bacterial infections',
    description: 'Broad-spectrum antibiotic. Complete the full course even if you feel better.',
    times: ['08:00', '14:00', '21:00'],
    food: 'With food',
    stock: 3,
    expiry: 'Jun 2026',
    status: _MedStatus.lowStock,
    scope: _MedScope.sharedMember,
  ),
];

// ─── Catalog mock ─────────────────────────────────────────────────────────────

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
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _isGrid = true;
  int _statusFilter = 0; // 0=All, 1=Active, 2=LowStock, 3=PRN
  String _scopeFilter = 'all';
  String _search = '';
  final _speech = SpeechToText();
  bool _isListening = false;

  final _statusLabels = [
    AppStrings.filterAll,
    AppStrings.filterActive,
    AppStrings.filterLowStock,
    AppStrings.filterPrn,
  ];

  final _scopeOptions = [
    ('all', AppStrings.scopeAll),
    ('mine', AppStrings.scopeMine),
    ('shared', AppStrings.scopeShared),
    ('assigned', AppStrings.scopeAssigned),
  ];

  List<_Med> get _visible {
    final q = _search.trim().toLowerCase();
    return _mockMeds.where((m) {
      if (_scopeFilter == 'mine' && m.scope != _MedScope.personal) return false;
      if (_scopeFilter == 'shared' && m.scope != _MedScope.sharedMaster) return false;
      if (_scopeFilter == 'assigned' && m.scope != _MedScope.sharedMember) return false;
      if (_statusFilter == 1 && m.status != _MedStatus.active) return false;
      if (_statusFilter == 2 && m.status != _MedStatus.lowStock) return false;
      if (_statusFilter == 3 && m.status != _MedStatus.prn) return false;
      if (q.isNotEmpty) {
        return m.name.toLowerCase().contains(q) || m.genericName.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _speech.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize(
      onError: (_) { if (mounted) setState(() => _isListening = false); },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (!available || !mounted) return;
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      if (!mounted) return;
      _searchCtrl.text = result.recognizedWords;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
      setState(() => _search = result.recognizedWords);
    });
  }

  // ─── Detail sheet ─────────────────────────────────────────────────────────

  void _openDetail(_Med med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(med: med),
    );
  }

  // ─── Add medicine sheet ───────────────────────────────────────────────────

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMedicineSheet(),
    );
  }

  // ─── Filter helpers ───────────────────────────────────────────────────────

  int get _activeFilterCount {
    int n = 0;
    if (_statusFilter != 0) n++;
    if (_scopeFilter != 'all') n++;
    return n;
  }

  void _openFilters() {
    int tempStatus = _statusFilter;
    String tempScope = _scopeFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setLocal) {
          final isDark    = Theme.of(context).brightness == Brightness.dark;
          final bg        = isDark ? context.cardBg : Colors.white;
          final border    = isDark ? context.borderCol : AppColors.light300;
          final bottomPad = MediaQuery.paddingOf(context).bottom;

          Widget filterChip(String label, bool selected, VoidCallback onTap) =>
              GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal : Colors.transparent,
                    borderRadius: AppBorderRadius.pill,
                    border: Border.all(
                      color: selected ? AppColors.teal : border,
                    ),
                  ),
                  child: Text(label,
                      style: AppTypography.labelSm.copyWith(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        letterSpacing: 0,
                      )),
                ),
              );

          return Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: border, borderRadius: AppBorderRadius.pill,
                    ),
                  ),
                ),
                // Header row
                Row(
                  children: [
                    Text('Filters',
                        style: AppTypography.h3.copyWith(fontSize: 18)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setLocal(() {
                        tempStatus = 0;
                        tempScope = 'all';
                      }),
                      child: Text('Reset',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.teal, letterSpacing: 0,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Status section
                Text('STATUS',
                    style: AppTypography.labelXs.copyWith(
                      color: AppColors.textHint, letterSpacing: 1,
                    )),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _statusLabels.asMap().entries.map((e) =>
                    filterChip(e.value, tempStatus == e.key, () =>
                        setLocal(() => tempStatus = e.key)),
                  ).toList(),
                ),
                const SizedBox(height: 22),

                // Scope section
                Text('MEDICINES',
                    style: AppTypography.labelXs.copyWith(
                      color: AppColors.textHint, letterSpacing: 1,
                    )),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _scopeOptions.map((opt) =>
                    filterChip(opt.$2, tempScope == opt.$1, () =>
                        setLocal(() => tempScope = opt.$1)),
                  ).toList(),
                ),
                const SizedBox(height: 28),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _statusFilter = tempStatus;
                        _scopeFilter  = tempScope;
                      });
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Apply Filters',
                        style: AppTypography.buttonLg.copyWith(
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.bg : AppColors.light100;
    final border = isDark ? context.borderCol : AppColors.light300;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 68,
            leading: IconButton(
              icon: Icon(Icons.menu_rounded, size: 22,
                  color: isDark ? context.primaryText : const Color(0xFF1A202C)),
              onPressed: openAppSidebar,
              tooltip: 'Menu',
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.myMedicines,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800, fontSize: 20,
                      color: isDark ? context.primaryText : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                Text('Manage all your medicines in one place',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary,
                    )),
              ],
            ),
            actions: [
              // Grid / List toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isGrid = !_isGrid);
                },
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isDark ? context.inputBg : Colors.white,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: border),
                  ),
                  child: Icon(
                    _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    size: 18,
                    color: isDark ? context.primaryText : const Color(0xFF1A202C),
                  ),
                ),
              ),
              // Add button
              GestureDetector(
                onTap: _openAdd,
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search + Filters ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isDark ? context.inputBg : Colors.white,
                            borderRadius: AppBorderRadius.pill,
                            border: Border.all(
                              color: _isListening ? AppColors.teal : border,
                              width: _isListening ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(Icons.search_rounded, size: 18,
                                  color: _isListening ? AppColors.teal : AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  style: AppTypography.bodyMd,
                                  decoration: InputDecoration(
                                    hintText: _isListening
                                        ? AppStrings.listeningHint
                                        : AppStrings.searchMedicines,
                                    hintStyle: AppTypography.bodyMd.copyWith(
                                      color: _isListening
                                          ? AppColors.teal.withValues(alpha: 0.8)
                                          : AppColors.textSecondary,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 13),
                                  ),
                                ),
                              ),
                              if (_search.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(Icons.close_rounded, size: 16,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              GestureDetector(
                                onTap: _toggleListen,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: _isListening
                                          ? AppColors.teal.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                                      size: 16,
                                      color: _isListening ? AppColors.teal : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filters button with active-count badge
                      GestureDetector(
                        onTap: _openFilters,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: _activeFilterCount > 0
                                    ? AppColors.teal.withValues(alpha: 0.10)
                                    : (isDark ? context.inputBg : Colors.white),
                                borderRadius: AppBorderRadius.pill,
                                border: Border.all(
                                  color: _activeFilterCount > 0 ? AppColors.teal : border,
                                  width: _activeFilterCount > 0 ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tune_rounded, size: 14, color: AppColors.teal),
                                  const SizedBox(width: 6),
                                  Text('Filters',
                                      style: GoogleFonts.inter(
                                        fontSize: 13, fontWeight: FontWeight.w600,
                                        color: AppColors.teal,
                                      )),
                                ],
                              ),
                            ),
                            if (_activeFilterCount > 0)
                              Positioned(
                                top: -5, right: -5,
                                child: Container(
                                  width: 17, height: 17,
                                  decoration: const BoxDecoration(
                                    color: AppColors.teal, shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('$_activeFilterCount',
                                        style: GoogleFonts.inter(
                                          fontSize: 9, fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Medicine list / grid ──────────────────────────────────────────
          if (_visible.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(onAdd: _openAdd),
            )
          else if (_isGrid)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _MedCard(med: _visible[i], onTap: () => _openDetail(_visible[i])),
                  childCount: _visible.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MedListRow(med: _visible[i], onTap: () => _openDetail(_visible[i])),
                  ),
                  childCount: _visible.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: _openAdd,
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.textInverse,
          icon: const Icon(Icons.add_rounded),
          label: Text(AppStrings.addMedicine, style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse)),
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _MedStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      _MedStatus.active => _badge(
          AppColors.green,
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(AppStrings.activeStatus,
                style: AppTypography.labelXs.copyWith(
                    color: AppColors.green, letterSpacing: 0.3)),
          ]),
        ),
      _MedStatus.lowStock => _badge(
          AppColors.amber,
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.amber),
            const SizedBox(width: 4),
            Text(AppStrings.lowStockStatus,
                style: AppTypography.labelXs.copyWith(
                    color: AppColors.amber, letterSpacing: 0.3)),
          ]),
        ),
      _MedStatus.prn => _badge(
          AppColors.purple,
          Text(AppStrings.prnLabel,
              style: AppTypography.labelXs.copyWith(
                  color: AppColors.purple, letterSpacing: 0.3)),
        ),
    };
  }

  Widget _badge(Color color, Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppBorderRadius.pill,
        ),
        child: child,
      );
}

// ─── Scope badge ──────────────────────────────────────────────────────────────

class _ScopeBadge extends StatelessWidget {
  final _MedScope scope;
  const _ScopeBadge(this.scope);

  @override
  Widget build(BuildContext context) {
    if (scope == _MedScope.personal) return const SizedBox.shrink();
    final (color, icon, label) = scope == _MedScope.sharedMaster
        ? (AppColors.teal, Icons.share_rounded, 'Shared')
        : (AppColors.blue, Icons.person_add_rounded, 'Caretaker');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.pill,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 9, color: color),
        const SizedBox(width: 3),
        Text(label, style: AppTypography.labelXs.copyWith(color: color, letterSpacing: 0.3)),
      ]),
    );
  }
}

// ─── Medicine card (grid) ─────────────────────────────────────────────────────

class _MedCard extends StatelessWidget {
  final _Med med;
  final VoidCallback onTap;
  _MedCard({required this.med, required this.onTap});

  Color get _statusColor => switch (med.status) {
        _MedStatus.active   => AppColors.teal,
        _MedStatus.lowStock => AppColors.amber,
        _MedStatus.prn      => AppColors.purple,
      };

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final cardBg    = isDark ? context.cardBg : Colors.white;
    final border    = isDark ? context.borderCol : AppColors.light300;
    final textColor = isDark ? context.primaryText : const Color(0xFF1A202C);
    final stockFill = (med.stock / 60).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card body ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: icon | spacer | status badge | more
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: AppBorderRadius.mdAll,
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: _statusColor, size: 22,
                          ),
                        ),
                        const Spacer(),
                        _StatusBadge(med.status),
                        const SizedBox(width: 4),
                        // Icon(Icons.more_horiz_rounded,
                        //     size: 16, color: const Color.fromARGB(255, 10, 92, 233)),
                     
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(med.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: textColor, letterSpacing: -0.2,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),

                    // Strength · Form
                    Text('${med.strength} · ${med.form}',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textSecondary,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),

                    // Schedule chips or PRN chip
                    if (med.status == _MedStatus.prn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.10),
                          borderRadius: AppBorderRadius.pill,
                        ),
                        child: Text(AppStrings.prnNote,
                            style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: AppColors.purple,
                            )),
                      )
                    else if (med.times.isNotEmpty)
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: med.times.map((t) {
                          final hour = int.tryParse(t.split(':')[0]) ?? 0;
                          final isNight = hour >= 18;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? context.inputBg : AppColors.light200,
                              borderRadius: AppBorderRadius.pill,
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isNight
                                      ? Icons.nightlight_round
                                      : Icons.wb_sunny_rounded,
                                  size: 10,
                                  color: isNight
                                      ? AppColors.purple.withValues(alpha: 0.8)
                                      : AppColors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(t,
                                    style: GoogleFonts.inter(
                                      fontSize: 10, fontWeight: FontWeight.w600,
                                      color: isDark ? context.primaryText : const Color(0xFF334155),
                                      letterSpacing: 0.3,
                                    )),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const Spacer(),

                    // Stock count + scope badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${med.stock}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20, fontWeight: FontWeight.w800,
                                  color: _statusColor, height: 1,
                                ),
                              ),
                              TextSpan(
                                text: '  Units',
                                style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _ScopeBadge(med.scope),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Stock progress bar flush to bottom ───────────────────────
            LinearProgressIndicator(
              value: stockFill,
              minHeight: 5,
              backgroundColor: _statusColor.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Medicine list row ────────────────────────────────────────────────────────

class _MedListRow extends StatelessWidget {
  final _Med med;
  final VoidCallback onTap;
  _MedListRow({required this.med, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: border),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              borderRadius: AppBorderRadius.mdAll,
            ),
            child: const Icon(Icons.medication_rounded, color: AppColors.teal, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(med.name,
                      style: AppTypography.labelMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                _StatusBadge(med.status),
              ]),
              const SizedBox(height: 2),
              Text('${med.strength} · ${med.form}',
                  style: AppTypography.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${med.stock} units', style: AppTypography.bodyXs),
                const SizedBox(width: 12),
                if (med.times.isNotEmpty) ...[
                  Icon(Icons.schedule_rounded, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(med.times.join(' · '), style: AppTypography.bodyXs),
                ] else
                  Text(AppStrings.prnNote, style: AppTypography.bodyXs.copyWith(color: AppColors.purple)),
                const Spacer(),
                _ScopeBadge(med.scope),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
        ]),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.10),
            ),
            child: const Icon(Icons.medication_rounded, size: 34, color: AppColors.teal),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.noMedicinesInView,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onAdd,
            child: Text('+ ${AppStrings.addMedicine}',
                style: AppTypography.labelMd.copyWith(color: AppColors.teal)),
          ),
        ]),
      ),
    );
  }
}

// ─── Detail bottom sheet ─────────────────────────────────────────────────────

class _DetailSheet extends StatefulWidget {
  final _Med med;
  const _DetailSheet({required this.med});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> with SingleTickerProviderStateMixin {
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

  void _openAddStock() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddStockSheet(med: widget.med),
    );
  }

  void _confirmRemove() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.removeMedicineTitle,
            style: AppTypography.h3.copyWith(fontSize: 16)),
        content: Text(AppStrings.removeMedicineDesc,
            style: AppTypography.bodyMd),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.medicineDeleted),
                  backgroundColor: context.inputBg,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.remove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;
    final m = widget.med;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppBorderRadius.topXxl,
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: AppBorderRadius.pill)),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                child: Text(m.name,
                    style: AppTypography.h2.copyWith(fontSize: 20),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              TextButton(
                onPressed: () {},
                child: Text(AppStrings.edit,
                    style: AppTypography.labelSm.copyWith(color: AppColors.teal, letterSpacing: 0)),
              ),
            ]),
          ),

          // Scope banner
          if (m.scope != _MedScope.personal)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (m.scope == _MedScope.sharedMaster ? AppColors.teal : AppColors.blue)
                      .withValues(alpha: 0.10),
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(
                    color: (m.scope == _MedScope.sharedMaster ? AppColors.teal : AppColors.blue)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(children: [
                  Icon(
                    m.scope == _MedScope.sharedMaster ? Icons.share_rounded : Icons.person_add_rounded,
                    size: 13,
                    color: m.scope == _MedScope.sharedMaster ? AppColors.teal : AppColors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.scope == _MedScope.sharedMaster
                          ? 'Shared bottle — stock split with other patients'
                          : 'Stock is managed by your caretaker.',
                      style: AppTypography.bodySm.copyWith(
                        color: m.scope == _MedScope.sharedMaster ? AppColors.teal : AppColors.blue,
                      ),
                    ),
                  ),
                ]),
              ),
            ),

          // Hero
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: const Icon(Icons.medication_rounded, color: AppColors.teal, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.genericName, style: AppTypography.bodyMd),
                Text('${m.strength} · ${m.form}', style: AppTypography.bodySm),
              ])),
              _StatusBadge(m.status),
            ]),
          ),

          const SizedBox(height: 16),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: AppTypography.labelSm.copyWith(color: AppColors.teal, letterSpacing: 0),
              unselectedLabelStyle: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0),
              indicatorColor: AppColors.teal,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: AppStrings.overviewTab),
                Tab(text: AppStrings.scheduleTab),
                Tab(text: AppStrings.stockTab),
                Tab(text: AppStrings.infoTab),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(med: m, controller: ctrl, onRestock: _openAddStock, onRemove: _confirmRemove),
                _ScheduleTab(med: m, controller: ctrl),
                _StockTab(med: m, controller: ctrl, onAddStock: _openAddStock),
                _InfoTab(med: m, controller: ctrl),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  final VoidCallback onRestock, onRemove;

  _OverviewTab({required this.med, required this.controller, required this.onRestock, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.inputBg : AppColors.light100;
    final border = isDark ? context.borderCol : AppColors.light300;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        // Primary use
        _Section(
          label: AppStrings.primaryUseLabel,
          child: Text(med.usedFor, style: AppTypography.bodyMd),
        ),
        const SizedBox(height: 20),

        // Schedule
        _Section(
          label: AppStrings.scheduleLabel,
          child: med.status == _MedStatus.prn
              ? Text(AppStrings.prnNote, style: AppTypography.bodyMd.copyWith(color: AppColors.purple))
              : med.times.isEmpty
                  ? Text(AppStrings.noScheduleSet, style: AppTypography.bodySm)
                  : Column(
                      children: med.times.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: cardBg, borderRadius: AppBorderRadius.mdAll),
                          child: Row(children: [
                            Text(t, style: AppTypography.labelMd.copyWith(color: AppColors.teal)),
                            const SizedBox(width: 12),
                            Expanded(child: Text('1 dose', style: AppTypography.bodySm)),
                            Text(med.food, style: AppTypography.bodySm),
                          ]),
                        ),
                      )).toList(),
                    ),
        ),
        const SizedBox(height: 20),

        // Adherence mini calendar (last 7 days)
        _Section(
          label: AppStrings.adherenceLabel,
          child: Row(
            children: ['M','T','W','T','F','S','S'].asMap().entries.map((e) {
              final i = e.key;
              final todayIdx = DateTime.now().weekday - 1; // Mon=0
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
                        ? Border.all(color: border, width: 1, style: BorderStyle.solid)
                        : null,
                  ),
                  child: Center(
                    child: Text(e.value,
                        style: AppTypography.labelXs.copyWith(
                          color: isFuture
                              ? AppColors.textHint
                              : isToday
                                  ? AppColors.teal
                                  : AppColors.teal.withValues(alpha: 0.6),
                          letterSpacing: 0,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Instructions
        _Section(
          label: AppStrings.instructionsLabel,
          child: Text(med.description,
              style: AppTypography.bodyMd.copyWith(height: 1.7)),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(children: [
          if (med.status != _MedStatus.prn)
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                child: Text(AppStrings.markTaken,
                    style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse)),
              ),
            ),
          if (med.status != _MedStatus.prn) const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onRestock,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.teal),
              child: Text(AppStrings.restock, style: AppTypography.buttonMd.copyWith(color: AppColors.teal)),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Icon(Icons.delete_outline_rounded, size: 18),
          ),
        ]),
      ],
    );
  }
}

// ─── Schedule tab ─────────────────────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  _ScheduleTab({required this.med, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? context.inputBg : AppColors.light100;
    final border = isDark ? context.borderCol : AppColors.light300;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        Text(AppStrings.fullScheduleLabel,
            style: AppTypography.overline.copyWith(color: AppColors.textHint)),
        const SizedBox(height: 12),
        if (med.status == _MedStatus.prn || med.times.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.purple),
              const SizedBox(width: 10),
              Text(AppStrings.prnNote,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.purple)),
            ]),
          )
        else
          ...med.times.asMap().entries.map((e) {
            final labels = {1: ['Morning'], 2: ['Morning', 'Evening'], 3: ['Morning', 'Afternoon', 'Evening'], 4: ['Morning', 'Noon', 'Evening', 'Night']};
            final label = (labels[med.times.length] ?? [])[e.key];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: border),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.smAll,
                    ),
                    child: Text(e.value,
                        style: AppTypography.labelMd.copyWith(color: AppColors.teal, fontFamily: 'monospace')),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(label, style: AppTypography.labelSm.copyWith(letterSpacing: 0)),
                    Text('1 dose · ${med.food}', style: AppTypography.bodySm),
                  ])),
                ]),
              ),
            );
          }),
      ],
    );
  }
}

// ─── Stock tab ────────────────────────────────────────────────────────────────

class _StockTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  final VoidCallback onAddStock;
  _StockTab({required this.med, required this.controller, required this.onAddStock});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? context.borderCol : AppColors.light300;
    final stockColor = med.status == _MedStatus.lowStock ? AppColors.warning : AppColors.teal;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        // Big stock count
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: stockColor.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: stockColor.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${med.stock}',
                  style: AppTypography.statLg.copyWith(color: context.primaryText, fontSize: 42)),
              Text(AppStrings.unitsRemaining, style: AppTypography.bodySm),
              if (med.expiry != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Expires: ${med.expiry}', style: AppTypography.bodyXs),
                ),
            ]),
            const Spacer(),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: stockColor.withValues(alpha: 0.4), width: 4),
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
          ]),
        ),

        const SizedBox(height: 20),

        // History label
        Text(AppStrings.stockHistoryLabel,
            style: AppTypography.overline.copyWith(color: AppColors.textHint)),
        const SizedBox(height: 12),

        // Mock history rows
        ...[
          ('+', 'Restocked', '30 units added', 'May 2026'),
          ('-', 'Daily usage', '12 units consumed', 'Apr–May 2026'),
          ('+', 'Initial stock', '42 units added', 'Apr 2026'),
        ].map((h) => Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border.withValues(alpha: 0.5))),
          ),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: h.$1 == '+'
                    ? AppColors.teal.withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.10),
                borderRadius: AppBorderRadius.smAll,
                border: Border.all(
                  color: h.$1 == '+'
                      ? AppColors.teal.withValues(alpha: 0.25)
                      : AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(h.$1,
                    style: AppTypography.labelMd.copyWith(
                      color: h.$1 == '+' ? AppColors.teal : AppColors.error,
                    )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.$2, style: AppTypography.bodyMd),
              Text(h.$3, style: AppTypography.bodySm),
            ])),
            Text(h.$4, style: AppTypography.bodyXs),
          ]),
        )),

        const SizedBox(height: 20),

        if (med.scope != _MedScope.sharedMember)
          OutlinedButton.icon(
            onPressed: onAddStock,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.teal,
              side: const BorderSide(color: AppColors.teal),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(AppStrings.addStock, style: AppTypography.buttonMd.copyWith(color: AppColors.teal)),
          ),
      ],
    );
  }
}

// ─── Info tab ─────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final _Med med;
  final ScrollController controller;
  const _InfoTab({required this.med, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      children: [
        _AccordionItem(title: 'What is it used for?', body: med.usedFor),
        _AccordionItem(title: 'How to take', body: med.description),
        _AccordionItem(title: 'Side effects', body: 'Common side effects may include nausea, dizziness, or stomach upset. Contact your doctor if symptoms persist.'),
        _AccordionItem(title: 'Precautions', body: 'Inform your doctor of all medications you are taking. Do not stop without consulting your healthcare provider.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Text(AppStrings.infoDisclaimer,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.warning.withValues(alpha: 0.85),
                height: 1.6,
              )),
        ),
      ],
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? context.borderCol : AppColors.light300;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: border),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              Expanded(child: Text(widget.title, style: AppTypography.labelMd)),
              Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20, color: AppColors.textSecondary),
            ]),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(widget.body,
                style: AppTypography.bodyMd.copyWith(height: 1.65)),
          ),
      ]),
    );
  }
}

// ─── Section label helper ─────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.overline.copyWith(color: AppColors.textHint)),
      const SizedBox(height: 8),
      child,
    ],
  );
}

// ─── Add stock sheet ──────────────────────────────────────────────────────────

class _AddStockSheet extends StatefulWidget {
  final _Med med;
  const _AddStockSheet({required this.med});

  @override
  State<_AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends State<_AddStockSheet> {
  final _qtyCtrl = TextEditingController(text: '30');
  final _expiryCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.cardBg : Colors.white;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.topXxl),
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? context.borderCol : AppColors.light300,
                  borderRadius: AppBorderRadius.pill)),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.addStockTitle, style: AppTypography.h2.copyWith(fontSize: 20)),
          Text('for ${widget.med.name}', style: AppTypography.bodySm),
          const SizedBox(height: 24),
          _SheetField(label: AppStrings.quantityLabel, controller: _qtyCtrl,
              hint: AppStrings.stockQtyHint, inputType: TextInputType.number),
          const SizedBox(height: 14),
          _SheetField(label: AppStrings.expiryLabel, controller: _expiryCtrl,
              hint: 'e.g. Dec 2026'),
          const SizedBox(height: 8),
          Text(AppStrings.stockOptional, style: AppTypography.bodySm),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : () {
                setState(() => _saving = true);
                final nav       = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final snackBg   = context.inputBg;
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (!mounted) return;
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Stock updated'),
                      backgroundColor: snackBg,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                });
              },
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(_saving ? AppStrings.saving : AppStrings.addStock,
                  style: AppTypography.buttonLg.copyWith(color: AppColors.textInverse)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Add Medicine sheet (4 steps) ────────────────────────────────────────────

class _AddMedicineSheet extends StatefulWidget {
  const _AddMedicineSheet();

  @override
  State<_AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<_AddMedicineSheet> {
  int _step = 0;
  final _steps = [
    AppStrings.addMedicineStep1,
    AppStrings.addMedicineStep2,
    AppStrings.addMedicineStep3,
    AppStrings.addMedicineStep4,
  ];

  // Step 0
  final _medSearchCtrl = TextEditingController();
  String _medSearch = '';
  _CatalogItem? _selected;
  bool _showRequest = false;
  final _reqNameCtrl = TextEditingController();
  final _speech = SpeechToText();
  bool _isListening = false;

  // Step 1
  String _whoMode = 'self';

  // Step 2
  String _freq = 'twice';
  final _freqOptions = [
    ('once', AppStrings.onceDaily, ['09:00']),
    ('twice', AppStrings.twiceDaily, ['09:00', '21:00']),
    ('three', AppStrings.threeDaily, ['08:00', '14:00', '21:00']),
    ('prn', AppStrings.asNeeded, <String>[]),
  ];
  List<String> _times = ['09:00', '21:00'];
  String _food = 'with';
  final _doseCtrl = TextEditingController(text: '1 tablet');
  final _foodOptions = [('before', AppStrings.beforeFood), ('with', AppStrings.withFood), ('after', AppStrings.afterFood)];

  // Step 3
  final _qtyCtrl = TextEditingController(text: '30');
  final _expiryCtrl = TextEditingController();

  bool _saving = false;

  List<_CatalogItem> get _catalogResults {
    final q = _medSearch.trim().toLowerCase();
    if (q.isEmpty) return _catalog.take(4).toList();
    return _catalog.where((c) =>
        c.name.toLowerCase().contains(q) || c.genericName.toLowerCase().contains(q)).toList();
  }

  void _setFreq(String f) {
    final opt = _freqOptions.firstWhere((x) => x.$1 == f);
    setState(() { _freq = f; _times = List<String>.from(opt.$3); });
  }

  bool get _canProceed {
    if (_step == 0) return _selected != null;
    if (_step == 1) return true;
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
    _speech.cancel();
    _medSearchCtrl.dispose();
    _reqNameCtrl.dispose();
    _doseCtrl.dispose();
    _qtyCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize(
      onError: (_) { if (mounted) setState(() => _isListening = false); },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (!available || !mounted) return;
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      if (!mounted) return;
      _medSearchCtrl.text = result.recognizedWords;
      _medSearchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _medSearchCtrl.text.length),
      );
      setState(() => _medSearch = result.recognizedWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? context.cardBg : Colors.white;
    final border = isDark ? context.borderCol : AppColors.light300;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.topXxl),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: AppBorderRadius.pill)),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text(AppStrings.addMedicine, style: AppTypography.h2.copyWith(fontSize: 20))),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.close, style: AppTypography.labelSm.copyWith(letterSpacing: 0)),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _steps.asMap().entries.map((e) {
                final i = e.key;
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Row(children: [
                    Expanded(
                      child: Column(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? AppColors.teal
                                : active
                                    ? AppColors.teal.withValues(alpha: 0.15)
                                    : Colors.transparent,
                            border: Border.all(
                              color: done || active ? AppColors.teal : border,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check_rounded, size: 12, color: Colors.black)
                                : Text('${i + 1}',
                                    style: AppTypography.labelXs.copyWith(
                                      color: active ? AppColors.teal : AppColors.textHint,
                                      letterSpacing: 0,
                                    )),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(e.value,
                            style: AppTypography.labelXs.copyWith(
                              color: active || done ? AppColors.teal : AppColors.textHint,
                              letterSpacing: 0,
                              fontSize: 9,
                            )),
                      ]),
                    ),
                    if (i < _steps.length - 1)
                      Container(width: 20, height: 1,
                          color: i < _step ? AppColors.teal : border),
                  ]),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: border),

          // Step content
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                if (_step == 0) _buildStep0(isDark, border),
                if (_step == 1) _buildStep1(isDark, border),
                if (_step == 2) _buildStep2(isDark, border),
                if (_step == 3) _buildStep3(isDark, border),
              ],
            ),
          ),

          // Bottom nav
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Row(children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: border),
                    ),
                    child: Text(AppStrings.back,
                        style: AppTypography.buttonMd.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: (_canProceed && !_saving) ? _next : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _saving ? AppStrings.saving : (_step == _steps.length - 1 ? AppStrings.save : AppStrings.next),
                    style: AppTypography.buttonLg.copyWith(color: AppColors.textInverse),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildStep0(bool isDark, Color border) {
    final cardBg = isDark ? context.inputBg : AppColors.light100;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Search
      AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? context.inputBg : AppColors.light200,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: _isListening ? AppColors.teal : border,
            width: _isListening ? 1.5 : 1.0,
          ),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, size: 18,
              color: _isListening ? AppColors.teal : AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _medSearchCtrl,
              style: AppTypography.bodyMd,
              decoration: InputDecoration(
                hintText: _isListening
                    ? AppStrings.listeningHint
                    : AppStrings.searchMedicines,
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: _isListening
                      ? AppColors.teal.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 12),
              ),
              onChanged: (v) => setState(() { _medSearch = v; _showRequest = false; }),
            ),
          ),
          if (_medSearch.isNotEmpty)
            GestureDetector(
              onTap: () {
                _medSearchCtrl.clear();
                setState(() { _medSearch = ''; _showRequest = false; });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
              ),
            ),
          GestureDetector(
            onTap: _toggleListen,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.teal.withValues(alpha: 0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                  size: 16,
                  color: _isListening ? AppColors.teal : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ]),
      ),

      const SizedBox(height: 16),

      Text(
        _catalogResults.isEmpty ? AppStrings.noMatchesLabel
            : _medSearch.isEmpty ? AppStrings.popularLabel
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
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: active ? AppColors.teal.withValues(alpha: 0.08) : cardBg,
                borderRadius: AppBorderRadius.lgAll,
                border: Border.all(
                  color: active ? AppColors.teal.withValues(alpha: 0.4) : border,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal.withValues(alpha: 0.15) : (isDark ? context.borderCol : AppColors.light200),
                    borderRadius: AppBorderRadius.smAll,
                  ),
                  child: Icon(Icons.medication_rounded, size: 18,
                      color: active ? AppColors.teal : AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: AppTypography.labelMd),
                  Text([item.genericName, item.strength, item.form].join(' · '),
                      style: AppTypography.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                if (active)
                  const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20),
              ]),
            ),
          ),
        );
      }),

      const SizedBox(height: 8),

      if (!_showRequest)
        Center(
          child: TextButton(
            onPressed: () => setState(() { _showRequest = true; _reqNameCtrl.text = _medSearch; }),
            child: Text(AppStrings.cantFindIt,
                style: AppTypography.bodySm.copyWith(color: AppColors.teal)),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(AppStrings.requestMedicine, style: AppTypography.labelMd)),
              GestureDetector(
                onTap: () => setState(() => _showRequest = false),
                child: Text(AppStrings.cancel, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(AppStrings.requestDesc, style: AppTypography.bodySm),
            const SizedBox(height: 14),
            _SheetField(label: AppStrings.medicineNameLabel, controller: _reqNameCtrl, hint: 'e.g. 3 Mix Cream'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
              child: Text(AppStrings.submitRequest,
                  style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse)),
            ),
          ]),
        ),
    ]);
  }

  Widget _buildStep1(bool isDark, Color border) {
    final options = [
      ('self', Icons.person_rounded, AppStrings.whoForYou, AppStrings.whoForYouDesc, AppColors.teal),
      ('patient', Icons.people_rounded, AppStrings.whoForPatient, AppStrings.whoForPatientDesc, AppColors.blue),
      ('shared', Icons.share_rounded, AppStrings.whoShared, AppStrings.whoSharedDesc, AppColors.purple),
    ];
    return Column(children: options.map((opt) {
      final active = _whoMode == opt.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => setState(() => _whoMode = opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: active ? opt.$5.withValues(alpha: 0.07) : Colors.transparent,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: active ? opt.$5.withValues(alpha: 0.4) : border),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: active ? opt.$5.withValues(alpha: 0.15) : (isDark ? context.inputBg : AppColors.light200),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: Icon(opt.$2, color: active ? opt.$5 : AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(opt.$3, style: AppTypography.labelMd.copyWith(color: active ? opt.$5 : null)),
                Text(opt.$4, style: AppTypography.bodySm),
              ])),
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? opt.$5 : Colors.transparent,
                  border: Border.all(color: active ? opt.$5 : border, width: 2),
                ),
                child: active ? const Icon(Icons.check_rounded, size: 11, color: Colors.black) : null,
              ),
            ]),
          ),
        ),
      );
    }).toList());
  }

  Widget _buildStep2(bool isDark, Color border) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Frequency', style: AppTypography.overline.copyWith(color: AppColors.textHint)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _freqOptions.map((f) {
          final active = _freq == f.$1;
          return GestureDetector(
            onTap: () => _setFreq(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: AppBorderRadius.pill,
                border: Border.all(color: active ? AppColors.teal : border),
              ),
              child: Text(f.$2, style: AppTypography.labelSm.copyWith(
                color: active ? AppColors.teal : AppColors.textSecondary, letterSpacing: 0)),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),

      if (_freq != 'prn') ...[
        Text('Dose times', style: AppTypography.overline.copyWith(color: AppColors.textHint)),
        const SizedBox(height: 10),
        ..._times.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? context.inputBg : AppColors.light100,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: border),
            ),
            child: Row(children: [
              Icon(Icons.schedule_rounded, size: 16, color: AppColors.teal),
              const SizedBox(width: 10),
              Text(e.value, style: AppTypography.labelMd.copyWith(color: AppColors.teal)),
            ]),
          ),
        )),

        const SizedBox(height: 20),

        _SheetField(label: AppStrings.doseAmount, controller: _doseCtrl, hint: AppStrings.doseAmountHint),

        const SizedBox(height: 16),

        Text(AppStrings.foodRelation, style: AppTypography.overline.copyWith(color: AppColors.textHint)),
        const SizedBox(height: 10),
        Row(children: _foodOptions.map((f) {
          final active = _food == f.$1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: f.$1 != 'after' ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _food = f.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: active ? AppColors.teal : border),
                  ),
                  child: Center(
                    child: Text(f.$2, style: AppTypography.labelSm.copyWith(
                      color: active ? AppColors.teal : AppColors.textSecondary, letterSpacing: 0)),
                  ),
                ),
              ),
            ),
          );
        }).toList()),
      ] else
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.07),
            borderRadius: AppBorderRadius.mdAll,
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
          ),
          child: Text(AppStrings.scheduleOptional,
              style: AppTypography.bodyMd.copyWith(color: AppColors.purple.withValues(alpha: 0.9))),
        ),
    ]);
  }

  Widget _buildStep3(bool isDark, Color border) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppStrings.stockOptional, style: AppTypography.bodySm),
      const SizedBox(height: 20),
      _SheetField(label: AppStrings.quantityLabel, controller: _qtyCtrl,
          hint: AppStrings.stockQtyHint, inputType: TextInputType.number),
      const SizedBox(height: 14),
      _SheetField(label: AppStrings.expiryLabel, controller: _expiryCtrl, hint: 'e.g. Dec 2026'),
    ]);
  }
}

// ─── Sheet text field ─────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? inputType;

  _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? context.borderCol : AppColors.light300;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelSm.copyWith(letterSpacing: 0.2)),
      SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: isDark ? context.inputBg : AppColors.light100,
          borderRadius: AppBorderRadius.mdAll,
          border: Border.all(color: border),
        ),
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          style: AppTypography.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ),
    ]);
  }
}

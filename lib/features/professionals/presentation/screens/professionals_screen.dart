import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'professional_detail_screen.dart';
import '../../../professional_profile/presentation/screens/become_professional_screen.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum ProConnState { none, pending, connected }

enum ProPlanType { hourly, daily, monthly }

// ─── Shared data class (imported by professional_detail_screen) ───────────────

class ProData {
  final String id;
  final String name;
  final String categoryName;
  final Color categoryColor;
  final String bio;
  final String address;
  final List<String> certifications;
  final int experienceYrs;
  final bool isVerified;
  final double averageRating;
  final int ratingCount;
  final int? hourlyRate;
  final int? dailyRate;
  final int? monthlyRate;
  final ProConnState connectionState;

  const ProData({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.categoryColor,
    required this.bio,
    required this.address,
    required this.certifications,
    required this.experienceYrs,
    required this.isVerified,
    required this.averageRating,
    required this.ratingCount,
    this.hourlyRate,
    this.dailyRate,
    this.monthlyRate,
    required this.connectionState,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

class _Category {
  final String name;
  final Color color;
  const _Category(this.name, this.color);
}

const _kCategories = [
  _Category('Doctor', AppColors.teal),
  _Category('Nurse', AppColors.blue),
  _Category('Therapist', AppColors.purple),
  _Category('Dietitian', AppColors.amber),
  _Category('Caregiver', AppColors.red),
  _Category('Physiotherapist', AppColors.green),
];

const _kProfessionals = [
  ProData(
    id: 'p1',
    name: 'Dr. Arjun Sharma',
    categoryName: 'Doctor',
    categoryColor: AppColors.teal,
    bio: 'Senior cardiologist with 12 years of experience in heart disease management, preventive care, and minimally invasive procedures.',
    address: 'Mumbai, MH',
    certifications: ['MBBS', 'MD Cardiology', 'FACC'],
    experienceYrs: 12,
    isVerified: true,
    averageRating: 4.8,
    ratingCount: 142,
    hourlyRate: 500,
    dailyRate: 3000,
    monthlyRate: 45000,
    connectionState: ProConnState.none,
  ),
  ProData(
    id: 'p2',
    name: 'Meena Patel',
    categoryName: 'Nurse',
    categoryColor: AppColors.blue,
    bio: 'Registered nurse specialising in home care and post-operative recovery. Compassionate, punctual, and experienced with elderly patients.',
    address: 'Delhi, DL',
    certifications: ['RN', 'B.Sc Nursing', 'ACLS'],
    experienceYrs: 8,
    isVerified: true,
    averageRating: 4.6,
    ratingCount: 88,
    hourlyRate: 300,
    dailyRate: 1800,
    monthlyRate: 28000,
    connectionState: ProConnState.pending,
  ),
  ProData(
    id: 'p3',
    name: 'Dr. Priya Rajan',
    categoryName: 'Therapist',
    categoryColor: AppColors.purple,
    bio: 'Licensed clinical psychologist offering CBT, mindfulness-based therapy, and anxiety management. Creates a safe, non-judgemental space.',
    address: 'Bangalore, KA',
    certifications: ['PhD Psychology', 'CBT Certified'],
    experienceYrs: 5,
    isVerified: false,
    averageRating: 4.5,
    ratingCount: 61,
    hourlyRate: 800,
    dailyRate: 4000,
    monthlyRate: 60000,
    connectionState: ProConnState.none,
  ),
  ProData(
    id: 'p4',
    name: 'Ravi Shankar',
    categoryName: 'Dietitian',
    categoryColor: AppColors.amber,
    bio: 'Clinical dietitian with expertise in diabetes nutrition, weight management, and sports nutrition. Evidence-based, personalised plans.',
    address: 'Hyderabad, TS',
    certifications: ['M.Sc Dietetics', 'Certified Diabetes Educator'],
    experienceYrs: 10,
    isVerified: true,
    averageRating: 4.7,
    ratingCount: 103,
    hourlyRate: 400,
    dailyRate: 2500,
    monthlyRate: 38000,
    connectionState: ProConnState.none,
  ),
  ProData(
    id: 'p5',
    name: 'Sunita Devi',
    categoryName: 'Caregiver',
    categoryColor: AppColors.red,
    bio: 'Dedicated caregiver for elderly and bedridden patients. Experienced in bathing, mobility assistance, feeding, and medication reminders.',
    address: 'Chennai, TN',
    certifications: ['Home Health Aide', 'CPR Certified'],
    experienceYrs: 6,
    isVerified: true,
    averageRating: 4.9,
    ratingCount: 54,
    hourlyRate: 200,
    dailyRate: 1200,
    monthlyRate: 18000,
    connectionState: ProConnState.connected,
  ),
  ProData(
    id: 'p6',
    name: 'Dr. Vikram Nair',
    categoryName: 'Physiotherapist',
    categoryColor: AppColors.green,
    bio: 'Sports physiotherapist and rehabilitation specialist. Expert in post-surgery recovery, musculoskeletal pain, and sports injury management.',
    address: 'Pune, MH',
    certifications: ['BPT', 'MPT Orthopaedics', 'MCPA'],
    experienceYrs: 15,
    isVerified: true,
    averageRating: 4.9,
    ratingCount: 187,
    hourlyRate: 600,
    dailyRate: 3500,
    monthlyRate: 52000,
    connectionState: ProConnState.none,
  ),
  ProData(
    id: 'p7',
    name: 'Aisha Khan',
    categoryName: 'Nurse',
    categoryColor: AppColors.blue,
    bio: 'ICU-trained nurse offering private nursing care. Skilled in IV therapy, wound dressing, catheter care, and patient monitoring.',
    address: 'Kolkata, WB',
    certifications: ['RN', 'Critical Care Nursing'],
    experienceYrs: 4,
    isVerified: true,
    averageRating: 4.4,
    ratingCount: 32,
    hourlyRate: 280,
    dailyRate: 1500,
    monthlyRate: 22000,
    connectionState: ProConnState.none,
  ),
  ProData(
    id: 'p8',
    name: 'Dr. Sanjay Mehta',
    categoryName: 'Doctor',
    categoryColor: AppColors.teal,
    bio: 'General physician and internal medicine specialist. Expert in chronic disease management, diabetes, hypertension, and preventive health.',
    address: 'Mumbai, MH',
    certifications: ['MBBS', 'MD Internal Medicine'],
    experienceYrs: 20,
    isVerified: true,
    averageRating: 4.8,
    ratingCount: 231,
    hourlyRate: 1000,
    dailyRate: 6000,
    monthlyRate: 90000,
    connectionState: ProConnState.none,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

// ─── Filter state ─────────────────────────────────────────────────────────────

class _ProFilter {
  final int? maxHourlyRate;   // null = any
  final String? location;     // null = any
  final double? minRating;    // null = any

  const _ProFilter({this.maxHourlyRate, this.location, this.minRating});

  bool get isActive => maxHourlyRate != null || location != null || minRating != null;

  int get activeCount =>
      (maxHourlyRate != null ? 1 : 0) +
      (location != null ? 1 : 0) +
      (minRating != null ? 1 : 0);

  _ProFilter copyWith({
    Object? maxHourlyRate = _sentinel,
    Object? location = _sentinel,
    Object? minRating = _sentinel,
  }) =>
      _ProFilter(
        maxHourlyRate: maxHourlyRate == _sentinel ? this.maxHourlyRate : maxHourlyRate as int?,
        location: location == _sentinel ? this.location : location as String?,
        minRating: minRating == _sentinel ? this.minRating : minRating as double?,
      );
}

const _sentinel = Object();

// ─── Screen ───────────────────────────────────────────────────────────────────

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  String _query = '';
  _ProFilter _filter = const _ProFilter();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProData> get _filtered {
    var list = _kProfessionals.toList();
    if (_selectedCategory != null) {
      list = list.where((p) => p.categoryName == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      list = list.where((p) =>
        p.name.toLowerCase().contains(_query) ||
        p.categoryName.toLowerCase().contains(_query) ||
        p.bio.toLowerCase().contains(_query) ||
        p.address.toLowerCase().contains(_query),
      ).toList();
    }
    if (_filter.maxHourlyRate != null) {
      list = list.where((p) => (p.hourlyRate ?? 0) <= _filter.maxHourlyRate!).toList();
    }
    if (_filter.location != null) {
      list = list.where((p) => p.address.contains(_filter.location!)).toList();
    }
    if (_filter.minRating != null) {
      list = list.where((p) => p.averageRating >= _filter.minRating!).toList();
    }
    return list;
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<_ProFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(current: _filter),
    );
    if (result != null) setState(() => _filter = result);
  }

  void _showConnect(ProData pro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProConnectSheet(pro: pro),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                onPressed: openAppSidebar,
                tooltip: 'Menu',
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: Text(AppStrings.browseProfessionals, style: AppTypography.h3),
              ),
            ),

            // Search + filter button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Expanded(child: _SearchBar(controller: _searchCtrl)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _filter.isActive
                              ? AppColors.teal.withValues(alpha: 0.12)
                              : context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(
                            color: _filter.isActive
                                ? AppColors.teal.withValues(alpha: 0.4)
                                : context.borderCol,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: _filter.isActive
                                  ? AppColors.teal
                                  : AppColors.textHint,
                            ),
                            if (_filter.isActive) ...[
                              const SizedBox(width: 5),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${_filter.activeCount}',
                                  style: AppTypography.labelXs.copyWith(
                                    fontSize: 9,
                                    color: context.bg,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: _CategoryChips(
                selected: _selectedCategory,
                onSelect: (c) => setState(
                  () => _selectedCategory = _selectedCategory == c ? null : c,
                ),
              ),
            ),

            // Become a professional banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BecomeProfessionalScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.teal.withValues(alpha: 0.18),
                          AppColors.blue.withValues(alpha: 0.12),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: AppBorderRadius.lgAll,
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.35)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.becomeProfessional,
                                style: AppTypography.labelMd.copyWith(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(AppStrings.earnMoney,
                                style: AppTypography.bodyXs.copyWith(
                                    color: AppColors.teal
                                        .withValues(alpha: 0.75))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.teal.withValues(alpha: 0.7)),
                    ]),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Results or empty
            filtered.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.noProfessionalsFound,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.tryDifferentSearch,
                            style: AppTypography.bodySm.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProCard(
                            pro: filtered[i],
                            onViewProfile: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfessionalDetailScreen(pro: filtered[i]),
                              ),
                            ),
                            onConnect: () => _showConnect(filtered[i]),
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

// ─── Filter bottom sheet ──────────────────────────────────────────────────────

const _kLocations = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Pune', 'Kolkata'];

class _FilterSheet extends StatefulWidget {
  final _ProFilter current;
  const _FilterSheet({required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? _maxRate;
  late String? _location;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _maxRate   = widget.current.maxHourlyRate;
    _location  = widget.current.location;
    _minRating = widget.current.minRating;
  }

  bool get _isActive => _maxRate != null || _location != null || _minRating != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, 20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.dividerCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: AppColors.teal),
              const SizedBox(width: 8),
              Text('Filter Professionals', style: AppTypography.h3),
              const Spacer(),
              if (_isActive)
                GestureDetector(
                  onTap: () => setState(() {
                    _maxRate = null; _location = null; _minRating = null;
                  }),
                  child: Text(
                    'Clear all',
                    style: AppTypography.labelSm.copyWith(color: AppColors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Pricing ──────────────────────────────────────────────────────
          _FilterSectionLabel('Pricing (Hourly Rate)'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _FilterChip(label: 'Any',        active: _maxRate == null,  onTap: () => setState(() => _maxRate = null)),
              _FilterChip(label: 'Under ₹300', active: _maxRate == 300,   onTap: () => setState(() => _maxRate = _maxRate == 300   ? null : 300)),
              _FilterChip(label: '₹300–600',   active: _maxRate == 600,   onTap: () => setState(() => _maxRate = _maxRate == 600   ? null : 600)),
              _FilterChip(label: '₹600–1000',  active: _maxRate == 1000,  onTap: () => setState(() => _maxRate = _maxRate == 1000  ? null : 1000)),
              _FilterChip(label: '₹1000+',     active: _maxRate == 99999, onTap: () => setState(() => _maxRate = _maxRate == 99999 ? null : 99999)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Location ─────────────────────────────────────────────────────
          _FilterSectionLabel('Location'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _FilterChip(label: 'Any', active: _location == null, onTap: () => setState(() => _location = null)),
              ..._kLocations.map((loc) => _FilterChip(
                label: loc,
                active: _location == loc,
                onTap: () => setState(() => _location = _location == loc ? null : loc),
              )),
            ],
          ),
          const SizedBox(height: 20),

          // ── Rating ───────────────────────────────────────────────────────
          _FilterSectionLabel('Minimum Rating'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _FilterChip(label: 'Any',  active: _minRating == null, onTap: () => setState(() => _minRating = null)),
              _FilterChip(label: '4.0+', active: _minRating == 4.0,  onTap: () => setState(() => _minRating = _minRating == 4.0 ? null : 4.0), icon: Icons.star_rounded),
              _FilterChip(label: '4.5+', active: _minRating == 4.5,  onTap: () => setState(() => _minRating = _minRating == 4.5 ? null : 4.5), icon: Icons.star_rounded),
              _FilterChip(label: '4.8+', active: _minRating == 4.8,  onTap: () => setState(() => _minRating = _minRating == 4.8 ? null : 4.8), icon: Icons.star_rounded),
            ],
          ),
          SizedBox(height: 24),

          // ── Apply button ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                _ProFilter(
                  maxHourlyRate: _maxRate,
                  location: _location,
                  minRating: _minRating,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: context.bg,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                elevation: 0,
              ),
              child: Text(
                _isActive ? 'Apply Filters' : 'Done',
                style: AppTypography.buttonMd.copyWith(
                  color: context.bg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSectionLabel extends StatelessWidget {
  final String label;
  const _FilterSectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: AppTypography.overline.copyWith(
          color: AppColors.textHint,
          fontSize: 10,
          letterSpacing: 1.0,
        ),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  const _FilterChip({required this.label, required this.active, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.teal.withValues(alpha: 0.12) : context.inputBg,
            borderRadius: AppBorderRadius.pill,
            border: Border.all(
              color: active ? AppColors.teal.withValues(alpha: 0.45) : context.borderCol,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: active ? AppColors.teal : AppColors.textHint),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: active ? AppColors.teal : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search_rounded, color: AppColors.textHint, size: 18),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: AppStrings.searchProfessionals,
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clear,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.close_rounded, color: AppColors.textHint, size: 16),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;
  const _CategoryChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All chip
          _Chip(
            label: AppStrings.filterAll,
            color: AppColors.teal,
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ..._kCategories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Chip(
                  label: c.name,
                  color: c.color,
                  isSelected: selected == c.name,
                  onTap: () => onSelect(c.name),
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : context.cardBg,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(
            color: isSelected ? color : context.borderCol,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Professional card ────────────────────────────────────────────────────────

class _ProCard extends StatelessWidget {
  final ProData pro;
  final VoidCallback onViewProfile;
  final VoidCallback onConnect;
  _ProCard({required this.pro, required this.onViewProfile, required this.onConnect});

  String get _initials {
    final parts = pro.name.replaceAll(RegExp(r'^Dr\.\s*'), '').split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.xlAll,
        border: Border.all(color: context.borderCol),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured top bar with gradient
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [pro.categoryColor, pro.categoryColor.withValues(alpha: 0.4)]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar circle
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: pro.categoryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: pro.categoryColor.withValues(alpha: 0.4), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: pro.categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pro.name,
                                  style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (pro.isVerified) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.verified_rounded, size: 15, color: AppColors.teal),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: pro.categoryColor.withValues(alpha: 0.12),
                              borderRadius: AppBorderRadius.pill,
                            ),
                            child: Text(
                              pro.categoryName,
                              style: AppTypography.labelXs.copyWith(
                                color: pro.categoryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Rating
                          Row(
                            children: [
                              Icon(Icons.star_rounded, size: 13, color: AppColors.amber),
                              const SizedBox(width: 3),
                              Text(
                                '${pro.averageRating.toStringAsFixed(1)} (${pro.ratingCount})',
                                style: AppTypography.labelXs.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Rate
                    if (pro.hourlyRate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStrings.from,
                            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint),
                          ),
                          Text(
                            '₹${pro.hourlyRate}',
                            style: AppTypography.statMd.copyWith(color: pro.categoryColor, fontSize: 16),
                          ),
                          Text(
                            AppStrings.perHour,
                            style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 9),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bio
                Text(
                  pro.bio,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Meta chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MetaChip(icon: Icons.work_outline_rounded, label: '${pro.experienceYrs} yrs'),
                    _MetaChip(icon: Icons.location_on_outlined, label: pro.address),
                  ],
                ),

                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _OutlineBtn(label: AppStrings.viewProfile, onTap: onViewProfile),
                    ),
                    const SizedBox(width: 8),
                    _ConnStateButton(state: pro.connectionState, color: pro.categoryColor, onTap: onConnect),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.smAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelXs.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Text(label, style: AppTypography.buttonSm.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}

class _ConnStateButton extends StatelessWidget {
  final ProConnState state;
  final Color color;
  final VoidCallback onTap;
  const _ConnStateButton({required this.state, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ProConnState.connected => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.12),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.teal),
              const SizedBox(width: 6),
              Text(AppStrings.message, style: AppTypography.buttonSm.copyWith(color: AppColors.teal)),
            ],
          ),
        ),
      ProConnState.pending => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded, size: 13, color: AppColors.amber),
              const SizedBox(width: 6),
              Text(AppStrings.pending, style: AppTypography.buttonSm.copyWith(color: AppColors.amber)),
            ],
          ),
        ),
      ProConnState.none => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppBorderRadius.lgAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 14, color: AppColors.textInverse),
                const SizedBox(width: 4),
                Text(AppStrings.connect, style: AppTypography.buttonSm.copyWith(color: context.bg)),
              ],
            ),
          ),
        ),
    };
  }
}

// ─── Connect sheet ────────────────────────────────────────────────────────────

class ProConnectSheet extends StatefulWidget {
  final ProData pro;
  final ProPlanType? initialPlan;
  const ProConnectSheet({super.key, required this.pro, this.initialPlan});

  @override
  State<ProConnectSheet> createState() => _ProConnectSheetState();
}

class _ProConnectSheetState extends State<ProConnectSheet> {
  late ProPlanType _selected;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPlan ?? ProPlanType.hourly;
  }

  ({String label, int? rate, Color color, IconData icon}) _planMeta(ProPlanType t) {
    return switch (t) {
      ProPlanType.hourly => (
          label: AppStrings.hourlyPlan,
          rate: widget.pro.hourlyRate,
          color: AppColors.teal,
          icon: Icons.schedule_rounded,
        ),
      ProPlanType.daily => (
          label: AppStrings.dailyPlan,
          rate: widget.pro.dailyRate,
          color: AppColors.blue,
          icon: Icons.calendar_today_rounded,
        ),
      ProPlanType.monthly => (
          label: AppStrings.monthlyPlan,
          rate: widget.pro.monthlyRate,
          color: AppColors.purple,
          icon: Icons.date_range_rounded,
        ),
    };
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.connectionRequestSent),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: context.dividerCol, borderRadius: AppBorderRadius.pill),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.selectPlanTitle, style: AppTypography.h3),
                          const SizedBox(height: 2),
                          Text(
                            widget.pro.name,
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Plan cards
                ...ProPlanType.values.map((t) {
                  final meta = _planMeta(t);
                  final isSelected = _selected == t;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = t),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? meta.color.withValues(alpha: 0.08) : context.inputBg,
                          borderRadius: AppBorderRadius.lgAll,
                          border: Border.all(
                            color: isSelected ? meta.color : context.borderCol,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: meta.color.withValues(alpha: 0.12),
                                borderRadius: AppBorderRadius.mdAll,
                              ),
                              alignment: Alignment.center,
                              child: Icon(meta.icon, size: 18, color: meta.color),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(meta.label, style: AppTypography.labelMd.copyWith(color: context.primaryText)),
                                  const SizedBox(height: 2),
                                  Text(
                                    meta.rate != null ? '₹${meta.rate} ${_rateLabel(t)}' : 'Not available',
                                    style: AppTypography.bodySm.copyWith(
                                      color: meta.rate != null ? meta.color : AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected ? meta.color : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? meta.color : context.borderCol,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check_rounded, size: 12, color: AppColors.textInverse)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),

                // Connect button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _sending ? null : _submit,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _planMeta(_selected).color,
                        borderRadius: AppBorderRadius.lgAll,
                      ),
                      alignment: Alignment.center,
                      child: _sending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: context.bg,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppStrings.connectNow,
                              style: AppTypography.buttonMd.copyWith(color: context.bg),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rateLabel(ProPlanType t) => switch (t) {
        ProPlanType.hourly => '/ hr',
        ProPlanType.daily => '/ day',
        ProPlanType.monthly => '/ month',
      };
}

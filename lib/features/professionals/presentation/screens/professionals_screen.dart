import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_shell_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../presentation/providers/professionals_provider.dart';
import '../../data/models/professional_model.dart' as pro_model;
import 'professional_detail_screen.dart';
import '../../../professional_profile/presentation/screens/become_professional_screen.dart';
import '../../../connections/presentation/providers/connections_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/connectivity_monitor.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum ProConnState { none, pending, connected }

enum ProPlanType { hourly, daily, monthly }

// ─── Shared data class (imported by professional_detail_screen) ───────────────

class ProData {
  final String id;
  final String userId;
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
    required this.userId,
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _categoryColor(String name) {
  final n = name.toLowerCase();
  if (n.contains('doctor') || n.contains('physician')) return AppColors.teal;
  if (n.contains('nurse')) return AppColors.blue;
  if (n.contains('therapist') || n.contains('psycholog')) return AppColors.purple;
  if (n.contains('diet') || n.contains('nutrition')) return AppColors.amber;
  if (n.contains('caregiver') || n.contains('care')) return AppColors.red;
  if (n.contains('physio')) return AppColors.green;
  return AppColors.teal;
}

// ─── Adapter ──────────────────────────────────────────────────────────────────

ProData _toPro(pro_model.Professional p) => ProData(
      id: p.id,
      userId: p.user.id,
      name: p.name,
      categoryName: p.category.name,
      categoryColor: _categoryColor(p.category.name),
      bio: p.bio ?? '',
      address: p.address ?? '',
      certifications: p.certifications,
      experienceYrs: p.experienceYrs ?? 0,
      isVerified: p.isVerified,
      averageRating: p.averageRating ?? 0.0,
      ratingCount: p.ratingCount ?? 0,
      hourlyRate: p.hourlyRate?.toInt(),
      dailyRate: p.dailyRate?.toInt(),
      monthlyRate: p.monthlyRate?.toInt(),
      connectionState: ProConnState.none,
    );

// ─── Filter state ─────────────────────────────────────────────────────────────

class _ProFilter {
  final int? maxHourlyRate;
  final String? location;
  final double? minRating;

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

class ProfessionalsScreen extends ConsumerStatefulWidget {
  const ProfessionalsScreen({super.key});

  @override
  ConsumerState<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends ConsumerState<ProfessionalsScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategoryId;
  _ProFilter _filter = const _ProFilter();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(professionalsProvider.notifier).setSearch(_searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProData> get _filtered {
    List<ProData> list =
        ref.watch(professionalsProvider).professionals.map(_toPro).toList();
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
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Professionals', showAppBar: false);
    }
    final filtered = _filtered;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          onRefresh: () => ref.read(professionalsProvider.notifier).load(),
          child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 68,
              automaticallyImplyLeading: false,
              leading: AppIconButton(
                icon: Icon(Icons.menu_rounded, size: 22, color: context.primaryText),
                tooltip: 'Menu',
                onPressed: openAppSidebar,
                backgroundColor: Colors.transparent,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h3(AppStrings.browseProfessionals, color: context.primaryText),
                  AppText.bodySm('Find and connect with professionals', color: context.secondaryText),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BecomeProfessionalScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.pill,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.teal),
                        const SizedBox(width: 5),
                        AppText.labelSm('Become Pro', color: AppColors.teal, fontWeight: FontWeight.w700),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Search + filter button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        controller: _searchCtrl,
                        hint: AppStrings.searchProfessionals,
                        onClear: _searchCtrl.clear,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                              color: _filter.isActive ? AppColors.teal : AppColors.textHint,
                            ),
                            if (_filter.isActive) ...[
                              const SizedBox(width: 5),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.teal,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${_filter.activeCount}',
                                  style: TextStyle(
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
                categories: ref.watch(professionalsProvider).categories
                    .map((c) => (id: c.id, name: c.name, color: _categoryColor(c.name)))
                    .toList(),
                selectedId: _selectedCategoryId,
                onSelect: (id) {
                  final newId = _selectedCategoryId == id ? null : id;
                  setState(() => _selectedCategoryId = newId);
                  ref.read(professionalsProvider.notifier).filterByCategory(newId);
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Results or empty
            if (ref.watch(professionalsProvider).isLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppSkeleton(
                        child: Container(
                          height: 130,
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: AppBorderRadius.lgAll,
                          ),
                        ),
                      ),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: AppStrings.noProfessionalsFound,
                    subtitle: AppStrings.tryDifferentSearch,
                  ),
                ),
              )
            else
              SliverPadding(
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
      ),
    );
  }
}

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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
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
              AppText.h3('Filter Professionals'),
              const Spacer(),
              if (_isActive)
                GestureDetector(
                  onTap: () => setState(() {
                    _maxRate = null; _location = null; _minRating = null;
                  }),
                  child: AppText.labelSm('Clear all', color: AppColors.red),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Pricing ────────────────────────────────────────────────────────
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

          // ── Location ───────────────────────────────────────────────────────
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

          // ── Rating ─────────────────────────────────────────────────────────
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
          const SizedBox(height: 24),

          // ── Apply button ───────────────────────────────────────────────────
          AppButton.primary(
            label: _isActive ? 'Apply Filters' : 'Done',
            isFullWidth: true,
            onPressed: () => Navigator.pop(
              context,
              _ProFilter(maxHourlyRate: _maxRate, location: _location, minRating: _minRating),
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
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              AppText.labelSm(
                label,
                color: active ? AppColors.teal : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ],
          ),
        ),
      );
}

// ─── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final List<({String id, String name, Color color})> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: AppStrings.filterAll,
            color: AppColors.teal,
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...categories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Chip(
                  label: c.name,
                  color: c.color,
                  isSelected: selectedId == c.id,
                  onTap: () => onSelect(c.id),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : context.cardBg,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(
            color: isSelected ? color : context.borderCol,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: AppText.labelSm(
          label,
          color: isSelected ? color : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
  const _ProCard({required this.pro, required this.onViewProfile, required this.onConnect});

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
          // Coloured top bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pro.categoryColor, pro.categoryColor.withValues(alpha: 0.4)],
              ),
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
                    AppAvatar(name: pro.name, size: AppAvatarSize.md),
                    const SizedBox(width: 12),

                    // Name + badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppText.labelMd(
                                  pro.name,
                                  fontWeight: FontWeight.w700,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (pro.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 15, color: AppColors.teal),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          AppContainer.tinted(
                            color: pro.categoryColor,
                            borderRadius: AppBorderRadius.pill,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: AppText.labelXs(
                              pro.categoryName,
                              color: pro.categoryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 13, color: AppColors.amber),
                              const SizedBox(width: 3),
                              AppText.labelXs(
                                '${pro.averageRating.toStringAsFixed(1)} (${pro.ratingCount})',
                                color: context.secondaryText,
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
                          AppText.bodyXs(AppStrings.from, color: AppColors.textHint),
                          Text(
                            '₹${pro.hourlyRate}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: pro.categoryColor,
                            ),
                          ),
                          Text(
                            AppStrings.perHour,
                            style: const TextStyle(fontSize: 9, color: AppColors.textHint),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                AppText.bodySm(
                  pro.bio,
                  color: context.secondaryText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MetaChip(icon: Icons.work_outline_rounded, label: '${pro.experienceYrs} yrs'),
                    _MetaChip(icon: Icons.location_on_outlined, label: pro.address),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        label: AppStrings.viewProfile,
                        isFullWidth: true,
                        onPressed: onViewProfile,
                      ),
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
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          AppText.labelXs(label, color: context.secondaryText),
        ],
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
      ProConnState.connected => AppContainer.tinted(
          color: AppColors.teal,
          borderRadius: AppBorderRadius.lgAll,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.teal),
              const SizedBox(width: 6),
              AppText.labelSm(AppStrings.message, color: AppColors.teal, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ProConnState.pending => AppContainer.tinted(
          color: AppColors.amber,
          borderRadius: AppBorderRadius.lgAll,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 13, color: AppColors.amber),
              const SizedBox(width: 6),
              AppText.labelSm(AppStrings.pending, color: AppColors.amber, fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ProConnState.none => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: color, borderRadius: AppBorderRadius.lgAll),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                AppText.labelSm(AppStrings.connect, color: Colors.white, fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ),
    };
  }
}

// ─── Connect sheet ────────────────────────────────────────────────────────────

class ProConnectSheet extends ConsumerStatefulWidget {
  final ProData pro;
  final ProPlanType? initialPlan;
  const ProConnectSheet({super.key, required this.pro, this.initialPlan});

  @override
  ConsumerState<ProConnectSheet> createState() => _ProConnectSheetState();
}

class _ProConnectSheetState extends ConsumerState<ProConnectSheet> {
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
    AppLogger.i('Connection request send → userId:${widget.pro.userId}', tag: 'Professionals');
    setState(() => _sending = true);
    try {
      await ref.read(sendConnectionRequestProvider).call(widget.pro.userId);
      AppLogger.i('Connection request sent ✓', tag: 'Professionals');
      AppLogger.track('connection.request_sent');
      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.success(context, AppStrings.connectionRequestSent);
    } on Exception catch (e) {
      AppLogger.e('Connection request failed', tag: 'Professionals', error: e);
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                          AppText.h3(AppStrings.selectPlanTitle),
                          const SizedBox(height: 2),
                          AppText.bodySm(widget.pro.name, color: context.secondaryText),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
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
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
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
                            AppContainer.tinted(
                              color: meta.color,
                              borderRadius: AppBorderRadius.mdAll,
                              padding: const EdgeInsets.all(11),
                              child: Icon(meta.icon, size: 18, color: meta.color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.labelMd(meta.label, color: context.primaryText),
                                  const SizedBox(height: 2),
                                  AppText.bodySm(
                                    meta.rate != null ? '₹${meta.rate} ${_rateLabel(t)}' : 'Not available',
                                    color: meta.rate != null ? meta.color : AppColors.textHint,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
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
                                  ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
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
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _planMeta(_selected).color,
                        borderRadius: AppBorderRadius.lgAll,
                      ),
                      alignment: Alignment.center,
                      child: _sending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: context.bg, strokeWidth: 2),
                            )
                          : AppText.labelMd(AppStrings.connectNow, color: context.bg, fontWeight: FontWeight.w700),
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

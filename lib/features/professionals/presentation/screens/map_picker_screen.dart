import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/models/location_models.dart';
import '../providers/location_provider.dart';

/// Free, no-API-key map picker backed by OpenStreetMap tiles.
/// User drags the map to position the centre pin, then confirms — the dropped
/// point is reverse-geocoded to a pincode → area via [locationProvider].
class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();

  // Default centre — India (roughly geographic centre).
  static const _fallbackCentre = LatLng(22.5937, 78.9629);
  LatLng _centre = _fallbackCentre;
  bool _resolving = false;
  bool _locating = false;
  List<AreaInfo> _searchResults = [];
  bool _showSearchResults = false;
  // The 6-digit pincode the user searched with, if any — carried onto the
  // selected area so professionals load with pincode context.
  String? _searchedPincode;
  Timer? _debounce;
  // Live address preview for the current pin position (no persistence).
  SavedLocation? _preview;
  bool _resolvingPreview = false;
  Timer? _moveDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _gotoMyLocation(initial: true));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _moveDebounce?.cancel();
    _mapController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Re-resolve the centre pin to an address shortly after the map settles.
  void _onMapMoved() {
    _moveDebounce?.cancel();
    _moveDebounce = Timer(const Duration(milliseconds: 600), _resolvePreview);
  }

  Future<void> _resolvePreview() async {
    setState(() => _resolvingPreview = true);
    final result = await ref
        .read(locationProvider.notifier)
        .previewCoordinates(_centre.latitude, _centre.longitude);
    if (!mounted) return;
    setState(() {
      _preview = result;
      _resolvingPreview = false;
    });
  }

  // Live search as the user types, debounced to avoid spamming the backend.
  void _onSearchChanged(String value) {
    setState(() {}); // refresh clear button / hint state
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _showSearchResults = false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), _runSearch);
  }

  Future<void> _gotoMyLocation({bool initial = false}) async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      _mapController.move(target, 15);
      setState(() => _centre = target);
      _resolvePreview();
    } catch (_) {
      // Stay on fallback; user can still pan manually.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirm() async {
    setState(() => _resolving = true);
    await ref.read(locationProvider.notifier).resolveFromCoordinates(
          _centre.latitude,
          _centre.longitude,
        );
    if (!mounted) return;
    setState(() => _resolving = false);

    final state = ref.read(locationProvider);
    if (state.hasLocation) {
      context.pop(true);
    } else {
      AppSnackbar.error(context, state.error ?? 'Could not resolve that location');
    }
  }

  Future<void> _runSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() => _showSearchResults = false);
      return;
    }
    // Remember a 6-digit pincode so it can be carried onto the selected area.
    final digits = query.replaceAll(RegExp(r'\D'), '');
    _searchedPincode = digits.length == 6 ? digits : null;

    try {
      final results =
          await ref.read(locationProvider.notifier).searchAreas(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _showSearchResults = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _showSearchResults = true;
      });
    }
  }

  Future<void> _selectSearchResult(AreaInfo area) async {
    await ref
        .read(locationProvider.notifier)
        .selectArea(area, pincode: _searchedPincode);
    if (!mounted) return;
    context.pop(true);
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.primaryText),
            onPressed: () => context.pop(),
          ),
          title: AppText.h3('Select on map'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // ── Map ────────────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centre,
                initialZoom: 5,
                minZoom: 3,
                maxZoom: 18,
                onPositionChanged: (camera, _) {
                  _centre = camera.center;
                  _onMapMoved();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hopes.app_medicare',
                ),
                // OSM attribution (required by their tile usage policy)
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),

            // ── Centre pin (fixed, map moves under it) ─────────────────────────
            if (!_showSearchResults)
              const Padding(
                padding: EdgeInsets.only(bottom: 36), // tip sits at exact centre
                child: Icon(Icons.place, size: 44, color: AppColors.teal),
              ),

            // ── Search field (top) — reusable search input ─────────────────────
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: AppSearchTextInput(
                controller: _searchCtrl,
                hint: 'Search pincode or area',
                prefixIcon: Icons.search_rounded,
                backgroundColor: context.isDark
                    ? Color.alphaBlend(
                        AppColors.teal.withValues(alpha: 0.12), context.cardBg)
                    : context.cardBg,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _runSearch(),
                onClear: () => setState(() => _showSearchResults = false),
              ),
            ),

            // ── Search results overlay ──────────────────────────────────────────
            if (_showSearchResults)
              Positioned(
                top: 64,
                left: 16,
                right: 16,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: _searchResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: AppText.bodySm(
                            'No results found for "${_searchCtrl.text}"',
                            color: context.secondaryText,
                            textAlign: TextAlign.left,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          itemBuilder: (_, i) {
                            final area = _searchResults[i];
                            return GestureDetector(
                              onTap: () => _selectSearchResult(area),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: context.borderCol),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.labelMd(area.name, fontWeight: FontWeight.w600),
                                    const SizedBox(height: 4),
                                    AppText.bodySm('${area.district}, ${area.state}',
                                        color: context.secondaryText),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),

            // ── Hint chip (when no search) ──────────────────────────────────────
            if (!_showSearchResults)
              Positioned(
                top: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: AppBorderRadius.pill,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: AppText.bodySm(
                    'Drag the map to position the pin',
                    color: context.secondaryText,
                  ),
                ),
              ),

            // ── My-location FAB ────────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 96,
              child: GestureDetector(
                onTap: _locating ? null : () => _gotoMyLocation(),
                child: Container(
                  height: 46, width: 46,
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: _locating
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                        )
                      : const Icon(Icons.my_location_rounded, size: 20, color: AppColors.teal),
                ),
              ),
            ),

            // ── Selected address + Confirm button ──────────────────────────────
            if (!_showSearchResults)
              Positioned(
                left: 16, right: 16, bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live address for the current pin position.
                    // Fixed height so the box doesn't grow/shrink as the
                    // content swaps between the loading / resolved / hint states.
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Color.alphaBlend(
                                AppColors.teal.withValues(alpha: 0.12), context.cardBg)
                            : context.cardBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place_rounded, size: 18, color: AppColors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _resolvingPreview
                                ? AppText.bodySm('Finding address…', color: context.secondaryText)
                                : _preview != null
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText.labelMd(
                                            _preview!.area.name,
                                            fontWeight: FontWeight.w700,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          AppText.bodyXs(
                                            _preview!.pincode != null
                                                ? '${_preview!.area.district} · ${_preview!.pincode}'
                                                : '${_preview!.area.district}, ${_preview!.area.state}',
                                            color: context.secondaryText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                    : AppText.bodySm(
                                        'Move the map to a serviceable area',
                                        color: context.secondaryText,
                                      ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _resolving ? null : _confirm,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: _resolving
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : AppText.labelMd('Confirm this location',
                                color: Colors.white, fontWeight: FontWeight.w700),
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
}

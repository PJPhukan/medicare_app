import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/country_codes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/inputs/email_phone_input.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../providers/caretakers_provider.dart';

enum _DurationPreset { forever, days30, days90, year1 }

extension on _DurationPreset {
  String get label => switch (this) {
        _DurationPreset.forever => 'No expiry',
        _DurationPreset.days30 => '30 days',
        _DurationPreset.days90 => '90 days',
        _DurationPreset.year1 => '1 year',
      };

  DateTime? expiresAtFromNow() => switch (this) {
        _DurationPreset.forever => null,
        _DurationPreset.days30 => DateTime.now().add(const Duration(days: 30)),
        _DurationPreset.days90 => DateTime.now().add(const Duration(days: 90)),
        _DurationPreset.year1 => DateTime.now().add(const Duration(days: 365)),
      };
}

class InviteCaretakerScreen extends ConsumerStatefulWidget {
  const InviteCaretakerScreen({super.key});

  @override
  ConsumerState<InviteCaretakerScreen> createState() => _InviteCaretakerScreenState();
}

class _InviteCaretakerScreenState extends ConsumerState<InviteCaretakerScreen> {
  final _nameCtrl    = TextEditingController();
  final _contactCtrl = TextEditingController();
  CountryCode _country = kDefaultCountry;
  final Set<String> _selectedPatientIds = {};
  _DurationPreset _duration = _DurationPreset.forever;
  bool _sending = false;
  String? _nameError;
  String? _contactError;
  String? _patientsError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  /// Same composition rule as the login identifier: a bare phone number gets
  /// the picked country's dial code prepended; an email (or anything already
  /// carrying '+') passes through untouched.
  String get _identifier {
    final raw = _contactCtrl.text.trim();
    if (!raw.contains('@') && !raw.startsWith('+')) return '${_country.code}$raw';
    return raw;
  }

  void _toggleAll(List<ManageablePatientEntity> all) {
    setState(() {
      if (_selectedPatientIds.length == all.length) {
        _selectedPatientIds.clear();
      } else {
        _selectedPatientIds
          ..clear()
          ..addAll(all.map((p) => p.id));
      }
      _patientsError = null;
    });
  }

  Future<void> _sendInvite() async {
    final name = _nameCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final nameErr = name.length < 2 ? AppStrings.nameTooShort : null;
    final contactErr = Validators.emailOrPhone(contact);
    final patientsErr = _selectedPatientIds.isEmpty ? 'Select at least one patient' : null;
    if (nameErr != null || contactErr != null || patientsErr != null) {
      setState(() {
        _nameError = nameErr;
        _contactError = contactErr;
        _patientsError = patientsErr;
      });
      return;
    }

    final id = _identifier;
    final isEmail = id.contains('@');
    AppLogger.i('Caretaker invite → patients:${_selectedPatientIds.length}', tag: 'Caretakers');
    setState(() => _sending = true);
    try {
      final result = await ref.read(inviteCaretakerProvider).call(
        name: name,
        phone: isEmail ? null : id,
        email: isEmail ? id : null,
        role: GranteeRole.caretaker,
        patientIds: _selectedPatientIds.toList(),
        expiresAt: _duration.expiresAtFromNow(),
      );
      AppLogger.i(
        'Caretaker invite sent ✓ added:${result.addedCount} pending:${result.pendingCount}',
        tag: 'Caretakers',
      );
      if (!mounted) return;
      final message = result.addedCount > 0 && result.pendingCount > 0
          ? 'Added for ${result.addedCount}, invite sent for ${result.pendingCount}'
          : result.addedCount > 0
              ? AppStrings.caretakerAdded
              : AppStrings.inviteSent;
      AppSnackbar.success(context, message);
      context.pop(true);
    } catch (e) {
      AppLogger.e('Caretaker invite failed', tag: 'Caretakers', error: e);
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(manageablePatientsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: AppStrings.inviteCaretakerTitle,
                leading: AppBarLeading.back,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── 1. Full name ──────────────────────────────────────────────
                  AppText.labelXs('FULL NAME', color: AppColors.textHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _nameCtrl,
                    hint: 'e.g. Priya Mehta',
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 24),

                  // ── 2. Phone or email (same widget as login) ────────────────────
                  AppText.labelXs('PHONE OR EMAIL', color: AppColors.textHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 10),
                  AppEmailPhoneInput(
                    controller: _contactCtrl,
                    hint: AppStrings.emailOrMobileHint,
                    error: _contactError,
                    onChanged: (_) => setState(() => _contactError = null),
                    onCountryChanged: (c) => setState(() => _country = c),
                  ),
                  const SizedBox(height: 24),

                  // ── 3. For which patient + duration ──────────────────────────────
                  AppText.labelXs('FOR WHICH PATIENT', color: AppColors.textHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 4),
                  AppText.bodyXs(
                    'Grant this caretaker access to one or more patients you manage.',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 10),

                  patientsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: AppLoadingSpinner(size: 24, strokeWidth: 2)),
                    ),
                    error: (e, __) => AppErrorState(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(manageablePatientsProvider),
                    ),
                    data: (patients) {
                      final allSelected = patients.isNotEmpty && _selectedPatientIds.length == patients.length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              AppFilterChip(
                                label: 'All',
                                selected: allSelected,
                                color: AppColors.teal,
                                onTap: () => _toggleAll(patients),
                              ),
                              ...patients.map((p) => AppFilterChip(
                                    label: p.isSelf ? 'Myself' : p.name,
                                    selected: _selectedPatientIds.contains(p.id),
                                    color: AppColors.teal,
                                    onTap: () => setState(() {
                                      if (_selectedPatientIds.contains(p.id)) {
                                        _selectedPatientIds.remove(p.id);
                                      } else {
                                        _selectedPatientIds.add(p.id);
                                      }
                                      _patientsError = null;
                                    }),
                                  )),
                            ],
                          ),
                          if (_patientsError != null) ...[
                            const SizedBox(height: 6),
                            AppText.bodyXs(_patientsError!, color: AppColors.error),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  AppText.labelXs('DURATION', color: AppColors.textHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 4),
                  AppText.bodyXs(
                    'How long this caretaker keeps access — renew or revoke anytime from the caretakers list.',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _DurationPreset.values
                        .map((d) => AppFilterChip(
                              label: d.label,
                              selected: _duration == d,
                              color: AppColors.blue,
                              onTap: () => setState(() => _duration = d),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    label: AppStrings.sendInvite,
                    isFullWidth: true,
                    isLoading: _sending,
                    variant: AppButtonVariant.primary,
                    onPressed: _sending ? null : _sendInvite,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

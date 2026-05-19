import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Profile data model ───────────────────────────────────────────────────────

class _ProfileData {
  String name;
  String email;
  String phone;
  String dob;
  String gender;
  String location;
  String bloodGroup;
  String weight;
  String height;
  String conditions;
  String allergies;
  String emergencyName;
  String emergencyRelation;
  String emergencyPhone;

  _ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.location,
    required this.bloodGroup,
    required this.weight,
    required this.height,
    required this.conditions,
    required this.allergies,
    required this.emergencyName,
    required this.emergencyRelation,
    required this.emergencyPhone,
  });

  _ProfileData copyWith({
    String? name, String? email, String? phone, String? dob,
    String? gender, String? location, String? bloodGroup,
    String? weight, String? height, String? conditions, String? allergies,
    String? emergencyName, String? emergencyRelation, String? emergencyPhone,
  }) => _ProfileData(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    dob: dob ?? this.dob,
    gender: gender ?? this.gender,
    location: location ?? this.location,
    bloodGroup: bloodGroup ?? this.bloodGroup,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    conditions: conditions ?? this.conditions,
    allergies: allergies ?? this.allergies,
    emergencyName: emergencyName ?? this.emergencyName,
    emergencyRelation: emergencyRelation ?? this.emergencyRelation,
    emergencyPhone: emergencyPhone ?? this.emergencyPhone,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late _ProfileData _data;

  @override
  void initState() {
    super.initState();
    _data = _ProfileData(
      name: 'Arjun Kumar',
      email: 'arjun.kumar@email.com',
      phone: '+91 98765 43210',
      dob: '14 March 1988',
      gender: 'Male',
      location: 'Mumbai, Maharashtra',
      bloodGroup: 'B+',
      weight: '72 kg',
      height: '5\'9"  (175 cm)',
      conditions: 'Hypertension, Type 2 Diabetes',
      allergies: 'Penicillin',
      emergencyName: 'Priya Kumar',
      emergencyRelation: 'Spouse',
      emergencyPhone: '+91 98765 00001',
    );
  }

  String get _initials {
    final parts = _data.name.split(' ');
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  void _openEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        data: _data,
        onSave: (updated) => setState(() => _data = updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                title: Text(AppStrings.myProfile, style: AppTypography.h3),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.teal),
                    label: Text(AppStrings.edit,
                        style: AppTypography.labelSm.copyWith(color: AppColors.teal)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.mdAll,
                        side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar hero ──────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppColors.teal.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.teal.withValues(alpha: 0.35),
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _initials,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _openEdit,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: context.bg, width: 2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.camera_alt_rounded,
                                        size: 13, color: context.bg),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Text(
                            _data.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _data.email,
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          _Badge(label: 'Member since Jan 2024', color: AppColors.textHint, dim: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Personal details ─────────────────────────────────────
                    _SectionHeader(label: 'Personal Details'),
                    const SizedBox(height: 10),
                    _InfoCard(rows: [
                      _InfoRow(icon: Icons.phone_rounded, color: AppColors.teal, label: AppStrings.phone, value: _data.phone),
                      _InfoRow(icon: Icons.cake_rounded, color: AppColors.blue, label: 'Date of Birth', value: _data.dob),
                      _InfoRow(icon: Icons.person_rounded, color: AppColors.purple, label: AppStrings.gender, value: _data.gender),
                      _InfoRow(icon: Icons.location_on_rounded, color: AppColors.green, label: 'Location', value: _data.location, isLast: true),
                    ]),
                    const SizedBox(height: 20),

                    // ── Health details ───────────────────────────────────────
                    _SectionHeader(label: 'Health Details'),
                    const SizedBox(height: 10),
                    _InfoCard(rows: [
                      _InfoRow(icon: Icons.bloodtype_rounded, color: AppColors.red, label: AppStrings.bloodGroup, value: _data.bloodGroup),
                      _InfoRow(icon: Icons.monitor_weight_rounded, color: AppColors.blue, label: AppStrings.weight, value: _data.weight),
                      _InfoRow(icon: Icons.straighten_rounded, color: AppColors.teal, label: AppStrings.height, value: _data.height),
                      _InfoRow(icon: Icons.medical_information_rounded, color: AppColors.amber, label: 'Conditions', value: _data.conditions),
                      _InfoRow(icon: Icons.warning_amber_rounded, color: AppColors.red, label: AppStrings.knownAllergies, value: _data.allergies, isLast: true),
                    ]),
                    const SizedBox(height: 20),

                    // ── Emergency contact ────────────────────────────────────
                    _SectionHeader(label: AppStrings.emergencyContact, danger: true),
                    const SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.emergency_rounded, size: 20, color: AppColors.red),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_data.emergencyName,
                                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('${_data.emergencyRelation}  ·  ${_data.emergencyPhone}',
                                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _openEdit,
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textHint),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit profile bottom sheet ────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final _ProfileData data;
  final void Function(_ProfileData) onSave;
  const _EditProfileSheet({required this.data, required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Personal
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _locationCtrl;
  String _gender = 'Male';

  // Health
  late final TextEditingController _bloodCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _conditionsCtrl;
  late final TextEditingController _allergiesCtrl;

  // Emergency
  late final TextEditingController _emNameCtrl;
  late final TextEditingController _emRelCtrl;
  late final TextEditingController _emPhoneCtrl;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final d = widget.data;
    _nameCtrl       = TextEditingController(text: d.name);
    _phoneCtrl      = TextEditingController(text: d.phone);
    _dobCtrl        = TextEditingController(text: d.dob);
    _locationCtrl   = TextEditingController(text: d.location);
    _gender         = d.gender;
    _bloodCtrl      = TextEditingController(text: d.bloodGroup);
    _weightCtrl     = TextEditingController(text: d.weight);
    _heightCtrl     = TextEditingController(text: d.height);
    _conditionsCtrl = TextEditingController(text: d.conditions);
    _allergiesCtrl  = TextEditingController(text: d.allergies);
    _emNameCtrl     = TextEditingController(text: d.emergencyName);
    _emRelCtrl      = TextEditingController(text: d.emergencyRelation);
    _emPhoneCtrl    = TextEditingController(text: d.emergencyPhone);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_nameCtrl, _phoneCtrl, _dobCtrl, _locationCtrl,
      _bloodCtrl, _weightCtrl, _heightCtrl, _conditionsCtrl, _allergiesCtrl,
      _emNameCtrl, _emRelCtrl, _emPhoneCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final updated = widget.data.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      gender: _gender,
      location: _locationCtrl.text.trim(),
      bloodGroup: _bloodCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
      height: _heightCtrl.text.trim(),
      conditions: _conditionsCtrl.text.trim(),
      allergies: _allergiesCtrl.text.trim(),
      emergencyName: _emNameCtrl.text.trim(),
      emergencyRelation: _emRelCtrl.text.trim(),
      emergencyPhone: _emPhoneCtrl.text.trim(),
    );
    Navigator.pop(context);
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPad),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.85,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle + header
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profile', style: AppTypography.h3.copyWith(fontSize: 17)),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: AppBorderRadius.lgAll),
                      child: Text(AppStrings.save, style: AppTypography.buttonSm.copyWith(color: context.bg)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Tab bar
            TabBar(
              controller: _tabs,
              indicatorColor: AppColors.teal,
              labelColor: AppColors.teal,
              unselectedLabelColor: AppColors.textHint,
              labelStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
              dividerColor: context.borderCol,
              tabs: const [Tab(text: 'Personal'), Tab(text: 'Health'), Tab(text: 'Emergency')],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _personalTab(),
                  _healthTab(),
                  _emergencyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personalTab() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    children: [
      _EField(label: 'Full Name', controller: _nameCtrl, icon: Icons.person_rounded),
      _EField(label: AppStrings.phone, controller: _phoneCtrl, icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
      _EField(label: 'Date of Birth', controller: _dobCtrl, icon: Icons.cake_rounded, hint: 'e.g. 14 March 1988'),
      _EField(label: 'Location', controller: _locationCtrl, icon: Icons.location_on_rounded),
      const SizedBox(height: 4),
      Text('Gender', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(
        children: ['Male', 'Female', 'Other'].map((g) {
          final sel = _gender == g;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.teal.withValues(alpha: 0.15) : context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.5) : context.borderCol),
                  ),
                  alignment: Alignment.center,
                  child: Text(g, style: AppTypography.labelSm.copyWith(
                    color: sel ? AppColors.teal : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  )),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );

  Widget _healthTab() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    children: [
      _EField(label: AppStrings.bloodGroup, controller: _bloodCtrl, icon: Icons.bloodtype_rounded, hint: 'e.g. B+'),
      _EField(label: AppStrings.weight, controller: _weightCtrl, icon: Icons.monitor_weight_rounded, hint: 'e.g. 72 kg'),
      _EField(label: AppStrings.height, controller: _heightCtrl, icon: Icons.straighten_rounded, hint: 'e.g. 5\'9"'),
      _EField(label: 'Conditions', controller: _conditionsCtrl, icon: Icons.medical_information_rounded, hint: 'Comma-separated', maxLines: 2),
      _EField(label: AppStrings.knownAllergies, controller: _allergiesCtrl, icon: Icons.warning_amber_rounded, hint: 'Comma-separated', maxLines: 2),
    ],
  );

  Widget _emergencyTab() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.08),
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.red),
          const SizedBox(width: 8),
          Expanded(child: Text('This person will be contacted in an emergency.',
              style: AppTypography.bodyXs.copyWith(color: AppColors.red))),
        ]),
      ),
      _EField(label: 'Contact Name', controller: _emNameCtrl, icon: Icons.person_rounded),
      _EField(label: 'Relationship', controller: _emRelCtrl, icon: Icons.favorite_rounded, hint: 'e.g. Spouse, Parent'),
      _EField(label: AppStrings.phone, controller: _emPhoneCtrl, icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
    ],
  );
}

// ─── Edit field ───────────────────────────────────────────────────────────────

class _EField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;

  const _EField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.inputBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(icon, size: 16, color: AppColors.textHint),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: AppTypography.bodyMd.copyWith(color: context.primaryText),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool danger;
  const _SectionHeader({required this.label, this.danger = false});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (danger) ...[
        const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.red),
        const SizedBox(width: 5),
      ],
      Text(label.toUpperCase(), style: AppTypography.overline.copyWith(
        color: danger ? AppColors.red : AppColors.textHint,
        letterSpacing: 1.0, fontSize: 10,
      )),
    ],
  );
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.cardBg,
      borderRadius: AppBorderRadius.lgAll,
      border: Border.all(color: context.borderCol),
    ),
    child: Column(children: rows),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: AppBorderRadius.smAll,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: color),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary))),
            Flexible(
              child: Text(value, style: AppTypography.labelSm.copyWith(
                color: context.primaryText, fontWeight: FontWeight.w600,
              ), textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
      if (!isLast) Divider(height: 1, color: context.borderCol, indent: 58, endIndent: 14),
    ],
  );
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool dim;
  const _Badge({required this.label, required this.color, this.dim = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: dim ? 0.06 : 0.10),
      borderRadius: AppBorderRadius.pill,
      border: Border.all(color: color.withValues(alpha: dim ? 0.12 : 0.25)),
    ),
    child: Text(label, style: AppTypography.labelXs.copyWith(
      color: dim ? AppColors.textHint : color,
      fontWeight: FontWeight.w600, letterSpacing: 0,
    )),
  );
}

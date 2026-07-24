
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

// ── Models ────────────────────────────────────────────────────────────────

enum ModifiedField {
  name,
  email,
  phone,
  occupation,
  mailing,
  emergencyPhone,
  dob,
  gender,
  relationship,
  avatar,
  additionalEmergencyContacts,
}

class EmergencyContact {
  final String relationship;
  final String phone;

  EmergencyContact({
    required this.relationship,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
    'relationship': relationship,
    'phone': phone,
  };
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _mailingCtrl;
  late final TextEditingController _emergencyPhoneCtrl;

  // Original values for dirty state tracking
  String _originalName = '';
  String _originalEmail = '';
  String _originalPhone = '';
  String _originalOccupation = '';
  String _originalMailing = '';
  String _originalEmergencyPhone = '';
  DateTime? _originalDob;
  String? _originalGender;
  String? _originalRelationship;

  DateTime? _dob;
  String? _gender;
  String? _relationship;

  // Additional emergency contacts
  final List<EmergencyContact> _additionalEmergencyContacts = [];
  final Map<int, TextEditingController> _additionalPhoneControllers = {};

  bool _saving = false;
  final Set<ModifiedField> _modifiedFields = {};

  Uint8List? _avatarBytes;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _occupationCtrl = TextEditingController();
    _mailingCtrl = TextEditingController();
    _emergencyPhoneCtrl = TextEditingController();

    _trackModifications();
    _loadProfileData();
  }

  void _trackModifications() {
    _nameCtrl.addListener(() => _checkModified(ModifiedField.name, _nameCtrl.text, _originalName));
    _emailCtrl.addListener(() => _checkModified(ModifiedField.email, _emailCtrl.text, _originalEmail));
    _phoneCtrl.addListener(() => _checkModified(ModifiedField.phone, _phoneCtrl.text, _originalPhone));
    _occupationCtrl.addListener(() => _checkModified(ModifiedField.occupation, _occupationCtrl.text, _originalOccupation));
    _mailingCtrl.addListener(() => _checkModified(ModifiedField.mailing, _mailingCtrl.text, _originalMailing));
    _emergencyPhoneCtrl.addListener(() => _checkModified(ModifiedField.emergencyPhone, _emergencyPhoneCtrl.text, _originalEmergencyPhone));
  }

  void _checkModified(ModifiedField field, String currentValue, String originalValue) {
    if (currentValue != originalValue) {
      setState(() => _modifiedFields.add(field));
    } else {
      setState(() => _modifiedFields.remove(field));
    }
  }

  void _onDobChanged(DateTime date) {
    if (date != _originalDob) {
      setState(() => _modifiedFields.add(ModifiedField.dob));
    } else {
      setState(() => _modifiedFields.remove(ModifiedField.dob));
    }
  }

  void _onGenderChanged(String value) {
    if (value != _originalGender) {
      setState(() => _modifiedFields.add(ModifiedField.gender));
    } else {
      setState(() => _modifiedFields.remove(ModifiedField.gender));
    }
  }

  void _onRelationshipChanged(String value) {
    if (value != _originalRelationship) {
      setState(() => _modifiedFields.add(ModifiedField.relationship));
    } else {
      setState(() => _modifiedFields.remove(ModifiedField.relationship));
    }
  }

  Future<void> _loadProfileData() async {
    // TODO: Load from user profile state/API
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _occupationCtrl.dispose();
    _mailingCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    for (final controller in _additionalPhoneControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_modifiedFields.isEmpty) {
      AppSnackbar.info(context, 'No changes to save');
      return;
    }

    final validationError = _validateForm();
    if (validationError != null) {
      AppSnackbar.error(context, validationError);
      return;
    }

    AppLogger.i('Profile update: ${_modifiedFields.join(', ')}',
        tag: 'Profile');
    setState(() => _saving = true);
    try {
      // TODO: Call backend API to update profile with modified fields only
      // final updateData = _buildUpdatePayload();
      // await profileService.updateProfile(updateData);

      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.i('Profile updated ✓', tag: 'Profile');
      if (!mounted) return;

      // Reset modified fields after successful save
      _modifiedFields.clear();
      _updateOriginalValues();
      setState(() => _saving = false);

      AppSnackbar.success(context, 'Profile updated successfully');
    } on Exception catch (e) {
      AppLogger.e('Profile update failed', tag: 'Profile', error: e);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, 'Failed to update profile');
    }
  }

  void _updateOriginalValues() {
    _originalName = _nameCtrl.text;
    _originalEmail = _emailCtrl.text;
    _originalPhone = _phoneCtrl.text;
    _originalOccupation = _occupationCtrl.text;
    _originalMailing = _mailingCtrl.text;
    _originalEmergencyPhone = _emergencyPhoneCtrl.text;
    _originalDob = _dob;
    _originalGender = _gender;
    _originalRelationship = _relationship;
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _addEmergencyContact() {
    setState(() {
      final newIndex = _additionalEmergencyContacts.length;
      _additionalEmergencyContacts.add(
        EmergencyContact(
          relationship: '',
          phone: '',
        ),
      );
      _additionalPhoneControllers[newIndex] = TextEditingController();
      _modifiedFields.add(ModifiedField.additionalEmergencyContacts);
    });
  }

  String? _validateForm() {
    if (_nameCtrl.text.trim().isEmpty) {
      return 'Full Name is required';
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      return 'Phone Number is required';
    }
    if (_dob == null) {
      return 'Date of Birth is required';
    }
    if (_gender == null) {
      return 'Gender is required';
    }
    if (_mailingCtrl.text.trim().isEmpty) {
      return 'Mailing Address is required';
    }
    if (_emergencyPhoneCtrl.text.trim().isEmpty) {
      return 'Emergency Phone is required';
    }
    if (_relationship == null) {
      return 'Relationship is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _modifiedFields.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _modifiedFields.isNotEmpty) {
          _showUnsavedChangesDialog();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: context.overlayStyle,
        child: Scaffold(
          backgroundColor: context.bg,
          body: CustomScrollView(
          slivers: [
            AppSliverAppBar(
              config: AppBarConfig(
                title: 'Edit Profile',
                leading: AppBarLeading.back,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar section ────────────────────────────────────
                      Center(
                        child: AppImagePickerInput(
                          size: 100,
                          shape: BoxShape.circle,
                          imageUrl: _avatarUrl,
                          imageBytes: _avatarBytes,
                          hint: 'Upload photo',
                          onTap: () {
                            AppLogger.i('Avatar picker tapped', tag: 'Profile');
                            // TODO: Wire up image picker when available
                          },
                          onClear: () {
                            setState(() {
                              _avatarBytes = null;
                              _avatarUrl = null;
                              _modifiedFields.add(ModifiedField.avatar);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── PERSONAL INFORMATION SECTION ──────────────────────
                      AppSectionHeaderText(
                        title: 'Personal Information',
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.teal),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Full Name',
                              hint: 'Name',
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _emailCtrl,
                              label: 'Email Address',
                              hint: 'email@example.com',
                              readOnly: true,
                            ),
                            const SizedBox(height: 16),
                            AppDobPicker(
                              label: 'Date of Birth',
                              date: _dob,
                              onChanged: (date) {
                                setState(() => _dob = date);
                                _onDobChanged(date);
                              },
                            ),
                            const SizedBox(height: 16),
                            AppDropdownInput<String>(
                              label: 'Gender Identity',
                              options: const ['Male', 'Female', 'Other'],
                              labels: const ['Male', 'Female', 'Other'],
                              value: _gender,
                              onChanged: (value) {
                                setState(() => _gender = value);
                                _onGenderChanged(value);
                              },
                              hint: 'Select gender',
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _occupationCtrl,
                              label: 'Occupation (Optional)',
                              hint: 'Occupation',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── CONTACT DETAILS SECTION ────────────────────────────
                      AppSectionHeaderText(
                        title: 'Contact Details',
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.phone_outlined, size: 16, color: AppColors.teal),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            AppPhoneInput(
                              controller: _phoneCtrl,
                              label: 'Phone Number',
                              initialCountryCode: 'IN',
                            ),
                            const SizedBox(height: 16),
                            AppTextArea(
                              controller: _mailingCtrl,
                              label: "Address",
                              hint: 'Address',
                              maxLines: 4,
                              minLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── EMERGENCY CONTACT SECTION ──────────────────────────
                      AppSectionHeaderText(
                        title: 'Emergency Contact',
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.phone_in_talk_outlined, size: 16, color: AppColors.teal),
                        ),
                        trailing: GestureDetector(
                          onTap: _addEmergencyContact,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: AppColors.teal),
                              const SizedBox(width: 4),
                              AppText.labelSm(
                                'Add More',
                                color: AppColors.teal,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            AppDropdownInput<String>(
                              label: 'Relationship',
                              options: const [
                                'Spouse',
                                'Parent',
                                'Sibling',
                                'Friend',
                                'Other'
                              ],
                              labels: const [
                                'Spouse',
                                'Parent',
                                'Sibling',
                                'Friend',
                                'Other'
                              ],
                              value: _relationship,
                              onChanged: (value) {
                                setState(() => _relationship = value);
                                _onRelationshipChanged(value);
                              },
                              hint: 'Select relationship',
                            ),
                            const SizedBox(height: 16),
                            AppPhoneInput(
                              controller: _emergencyPhoneCtrl,
                              label: 'Emergency Contact Number',
                              initialCountryCode: 'IN',
                            ),
                          ],
                        ),
                      ),
                      if (_additionalEmergencyContacts.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ..._additionalEmergencyContacts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final contact = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText.bodyMd(
                                        'Emergency Contact ${index + 2}',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _additionalPhoneControllers[index]?.dispose();
                                            _additionalPhoneControllers.remove(index);
                                            _additionalEmergencyContacts.removeAt(index);
                                            if (_additionalEmergencyContacts.isEmpty) {
                                              _modifiedFields.remove(ModifiedField.additionalEmergencyContacts);
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  AppDropdownInput<String>(
                                    label: 'Relationship',
                                    options: const [
                                      'Spouse',
                                      'Parent',
                                      'Sibling',
                                      'Friend',
                                      'Other'
                                    ],
                                    labels: const [
                                      'Spouse',
                                      'Parent',
                                      'Sibling',
                                      'Friend',
                                      'Other'
                                    ],
                                    value: contact.relationship.isEmpty ? null : contact.relationship,
                                    onChanged: (value) {
                                      setState(() {
                                        _additionalEmergencyContacts[index] = EmergencyContact(
                                          relationship: value,
                                          phone: contact.phone,
                                        );
                                        _modifiedFields.add(ModifiedField.additionalEmergencyContacts);
                                      });
                                    },
                                    hint: 'Select relationship',
                                  ),
                                  const SizedBox(height: 16),
                                  AppPhoneInput(
                                    controller: _additionalPhoneControllers[index] ?? TextEditingController(text: contact.phone),
                                    label: 'Emergency Phone',
                                    initialCountryCode: 'IN',
                                    onChanged: (value) {
                                      setState(() {
                                        _additionalEmergencyContacts[index] = EmergencyContact(
                                          relationship: contact.relationship,
                                          phone: value,
                                        );
                                        _modifiedFields.add(ModifiedField.additionalEmergencyContacts);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 32),

                      // ── SAVE BUTTON ───────────────────────────────────────
                      AppButton(
                        label: 'Save Changes',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.lg,
                        isFullWidth: true,
                        isLoading: _saving,
                        onPressed: _saving ? null : _save,
                        leading: const Icon(Icons.check_rounded, size: 18),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

}

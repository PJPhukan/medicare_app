import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/payout_details_provider.dart';

class PayoutDetailsScreen extends ConsumerStatefulWidget {
  const PayoutDetailsScreen({super.key});

  @override
  ConsumerState<PayoutDetailsScreen> createState() => _PayoutDetailsScreenState();
}

class _PayoutDetailsScreenState extends ConsumerState<PayoutDetailsScreen> {
  final _name = TextEditingController();
  final _account = TextEditingController();
  final _ifsc = TextEditingController();
  final _upi = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _name.dispose();
    _account.dispose();
    _ifsc.dispose();
    _upi.dispose();
    super.dispose();
  }

  void _prefill(PayoutDetails d) {
    _prefilled = true;
    _name.text = d.bankAccountName ?? '';
    _account.text = d.bankAccountNumber ?? '';
    _ifsc.text = d.bankIfsc ?? '';
    _upi.text = d.upiId ?? '';
  }

  Future<void> _save() async {
    final account = _account.text.trim();
    final ifsc = _ifsc.text.trim().toUpperCase();
    final upi = _upi.text.trim();

    final hasBank = account.isNotEmpty || ifsc.isNotEmpty;
    if (hasBank && (account.isEmpty || ifsc.isEmpty)) {
      AppSnackbar.error(context, 'Enter both account number and IFSC');
      return;
    }
    if (!hasBank && upi.isEmpty) {
      AppSnackbar.error(context, 'Add a bank account or a UPI ID');
      return;
    }

    try {
      await ref.read(payoutDetailsProvider.notifier).save(
            bankAccountName: _name.text.trim(),
            bankAccountNumber: account,
            bankIfsc: ifsc,
            upiId: upi,
          );
      if (!mounted) return;
      AppSnackbar.success(context, 'Payout details saved');
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Could not save. Check the details and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(payoutDetailsProvider);
    if (!_prefilled && state.details != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_prefilled) setState(() => _prefill(state.details!));
      });
    }

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
            onPressed: () => Navigator.pop(context),
          ),
          title: AppText.h3('Payout Details'),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: AppBorderRadius.mdAll,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText.bodySm(
                          'Where we send your earnings. Add a bank account or a UPI ID — '
                          'whichever you prefer.',
                          color: context.secondaryText,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  AppText.labelMd('Bank Account', color: AppColors.textSecondary),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _name,
                    label: 'Account holder name',
                    hint: 'As per bank records',
                    prefix: const Icon(Icons.person_rounded),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _account,
                    label: 'Account number',
                    hint: '6–18 digits',
                    prefix: const Icon(Icons.account_balance_rounded),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(18),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _ifsc,
                    label: 'IFSC code',
                    hint: 'e.g. HDFC0001234',
                    prefix: const Icon(Icons.numbers_rounded),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(11),
                      _UpperCaseFormatter(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: Divider(color: context.dividerCol)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AppText.bodyXs('OR', color: AppColors.textHint),
                    ),
                    Expanded(child: Divider(color: context.dividerCol)),
                  ]),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _upi,
                    label: 'UPI ID',
                    hint: 'e.g. name@bank',
                    prefix: const Icon(Icons.qr_code_rounded),
                  ),
                  const SizedBox(height: 28),
                  AppButton.primary(
                    label: 'Save Payout Details',
                    onPressed: state.isSaving ? null : _save,
                    isLoading: state.isSaving,
                    size: AppButtonSize.lg,
                    isFullWidth: true,
                  ),
                ],
              ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

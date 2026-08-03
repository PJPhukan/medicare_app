import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicines_provider.dart';

/// Adds the first stock entry for a medicine, or tops up an existing one.
/// Resolves true when something was saved.
Future<bool?> showAddStockSheet(
  BuildContext context,
  UserMedicineEntity medicine,
) {
  return AppBottomSheet.show<bool>(
    context,
    title: medicine.hasStock ? 'Top up stock' : 'Add stock',
    subtitle: medicine.displayName,
    child: _AddStockBody(medicine: medicine),
  );
}

class _AddStockBody extends ConsumerStatefulWidget {
  const _AddStockBody({required this.medicine});

  final UserMedicineEntity medicine;

  @override
  ConsumerState<_AddStockBody> createState() => _AddStockBodyState();
}

class _AddStockBodyState extends ConsumerState<_AddStockBody> {
  final _qtyCtrl = TextEditingController(text: '30');
  late final TextEditingController _thresholdCtrl;
  DateTime? _expiry;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final stock = widget.medicine.activeStock;
    final expiry = stock?.expiryDate;
    if (expiry != null) _expiry = DateTime.tryParse(expiry);
    // Pre-fill with the stored threshold so a top-up doesn't silently reset
    // it; a first entry starts from the low-stock line the cabinet already
    // uses to flag a card.
    _thresholdCtrl = TextEditingController(
      text: '${stock?.minThreshold ?? UserMedicineEntity.lowStockThreshold}',
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _save() async {
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0) return;
    setState(() => _saving = true);
    try {
      await ref.read(medicinesRepositoryProvider).addStock(
            widget.medicine.id,
            quantity: qty,
            expiryDate: _expiry?.toIso8601String(),
            // Blank means "leave it alone"; 0 explicitly turns alerts off.
            minThreshold: int.tryParse(_thresholdCtrl.text.trim()),
          );
      // The cabinet card and the detail sheet both read stock from
      // /medicines/me, so the list has to be refetched before either updates.
      await ref.read(medicinesProvider.notifier).load();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.medicine.activeStock;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (existing != null) ...[
          AppInfoLabelText(
            icon: Icons.inventory_2_outlined,
            label: 'Currently',
            value: '${existing.quantity} units',
          ),
          const SizedBox(height: 12),
          // The endpoint increments rather than replaces, so say so — "30"
          // here means "thirty more", not "set it to thirty".
          AppText.bodySm('Quantity is added to what is already recorded.'),
          const SizedBox(height: 12),
        ],
        AppTextField(
          label: AppStrings.quantityLabel,
          controller: _qtyCtrl,
          hint: AppStrings.stockQtyHint,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Refill alert at',
          controller: _thresholdCtrl,
          hint: 'e.g. 5',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 6),
        AppText.bodyXs(
            'Warn when the remaining units drop to this. 0 turns it off.'),
        const SizedBox(height: 14),
        AppInfoLabelText(
          icon: Icons.event_busy_rounded,
          label: AppStrings.expiryLabel,
          value: _expiry == null
              ? 'Not set'
              : _expiry!.toIso8601String().split('T').first,
          onTap: _pickExpiry,
        ),
        const SizedBox(height: 24),
        AppButton(
          variant: AppButtonVariant.primary,
          label: AppStrings.save,
          isFullWidth: true,
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}

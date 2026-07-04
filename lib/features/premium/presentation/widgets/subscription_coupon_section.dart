import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/entities/available_coupon_entity.dart';

class SubscriptionCouponSection extends StatefulWidget {
  const SubscriptionCouponSection({
    super.key,
    required this.coupon,
    required this.loading,
    required this.onValidate,
    required this.onClear,
    this.availableCoupons = const [],
    this.planId,
  });

  final CouponEntity? coupon;
  final bool loading;
  final void Function(String code, {String? planId}) onValidate;
  final VoidCallback onClear;
  final List<AvailableCouponEntity> availableCoupons;
  final String? planId;

  @override
  State<SubscriptionCouponSection> createState() =>
      _SubscriptionCouponSectionState();
}

class _SubscriptionCouponSectionState
    extends State<SubscriptionCouponSection> {
  final _ctrl = TextEditingController();
  bool _autoApplied = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final existingCode = widget.coupon?.code;
    if (existingCode != null && existingCode.isNotEmpty) {
      _ctrl.text = existingCode;
      _ctrl.selection = TextSelection.collapsed(offset: existingCode.length);
      _autoApplied = true; // already validated server-side
    } else if (widget.availableCoupons.isNotEmpty && widget.coupon?.valid != true) {
      final code = widget.availableCoupons.first.code;
      _ctrl.text = code;
      _ctrl.selection = TextSelection.collapsed(offset: code.length);
      _autoApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onValidate(code, planId: widget.planId);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SubscriptionCouponSection old) {
    super.didUpdateWidget(old);

    if (widget.coupon?.code != old.coupon?.code) {
      final code = widget.coupon?.code;
      if (code != null && code.isNotEmpty) {
        // No setState — didUpdateWidget triggers a rebuild automatically.
        _ctrl.text = code;
        _ctrl.selection = TextSelection.collapsed(offset: code.length);
      }
    } else if (widget.availableCoupons != old.availableCoupons &&
        widget.availableCoupons.isNotEmpty &&
        widget.coupon?.valid != true &&
        !_autoApplied &&
        _ctrl.text.isEmpty) {
      final code = widget.availableCoupons.first.code;
      _ctrl.text = code;
      _ctrl.selection = TextSelection.collapsed(offset: code.length);
      _autoApplied = true;
      widget.onValidate(code, planId: widget.planId);
    }
  }

  void _apply() {
    if (widget.loading) return;
    final code = _ctrl.text.trim();
    if (code.isEmpty) return;
    widget.onValidate(code, planId: widget.planId);
  }

  void _remove() {
    final fallback = widget.availableCoupons.isNotEmpty
        ? widget.availableCoupons.first.code
        : '';
    _ctrl.text = fallback;
    if (fallback.isNotEmpty) {
      _ctrl.selection = TextSelection.collapsed(offset: fallback.length);
    }
    _autoApplied = false;
    widget.onClear();
  }

  String _discountLine(CouponEntity c) {
    if (c.discountType == 'PERCENT' && c.discountValue != null) {
      return '${c.discountValue!.toStringAsFixed(0)}${AppStrings.couponPctOff}';
    }
    if (c.discountType == 'FLAT' && c.discountValue != null) {
      return '₹${c.discountValue!.toStringAsFixed(0)}${AppStrings.couponFlatOff}';
    }
    if (c.discountType == 'FREE_MONTHS' && c.freePlanName != null) {
      return '${AppStrings.couponFreePrefix}${c.freePlanName}${AppStrings.couponFreeSuffix}';
    }
    return AppStrings.couponApplied;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupon = widget.coupon;
    final isValid = coupon?.valid == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AppTextField(
                controller: _ctrl,
                hint: AppStrings.couponHint,
                readOnly: true,
                textInputAction: TextInputAction.done,
                onSubmitted: isValid ? null : (_) => _apply(),
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: isValid ? AppStrings.couponRemove : AppStrings.couponApply,
              size: AppButtonSize.lg,
              variant: isValid ? AppButtonVariant.secondary : AppButtonVariant.primary,
              isLoading: widget.loading,
              onPressed: widget.loading ? null : (isValid ? _remove : _apply),
            ),
          ],
        ),
        if (isValid && coupon != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: AppBorderRadius.pill,
                border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_rounded,
                      size: 11, color: AppColors.teal),
                  const SizedBox(width: 5),
                  AppText.caption(
                    _discountLine(coupon),
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

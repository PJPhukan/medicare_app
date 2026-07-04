import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/plan_model.dart';
import '../models/my_subscription_model.dart';
import '../models/coupon_model.dart';
import '../models/purchase_result_model.dart';
import '../models/subscription_order_model.dart';
import '../models/available_coupon_model.dart';

class SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<PlanModel>> getPlans() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.subscriptionPlans);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list.map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MySubscriptionModel> getMySubscription() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.mySubscription);
    return MySubscriptionModel.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> selectPlan(String planId) async {
    await _dio.post<void>(ApiConstants.selectPlan, data: {'planId': planId});
  }

  Future<PurchaseResultModel> purchasePlan({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) async {
    final body = <String, dynamic>{
      'planId': planId,
      'billingCycle': billingCycle,
      if (couponCode != null) 'couponCode': couponCode,
    };
    final res = await _dio.post<Map<String, dynamic>>(ApiConstants.purchasePlan, data: body);
    return PurchaseResultModel.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<void> cancelSubscription() async {
    await _dio.post<void>(ApiConstants.cancelSubscription);
  }

  Future<void> toggleAutoRenew(bool enabled) async {
    await _dio.patch<void>(ApiConstants.autoRenew, data: {'enabled': enabled});
  }

  Future<CouponModel> validateCoupon({required String code, String? planId}) async {
    final body = <String, dynamic>{'code': code, if (planId != null) 'planId': planId};
    final res = await _dio.post<Map<String, dynamic>>(ApiConstants.validateCoupon, data: body);
    return CouponModel.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<CouponModel> applyCoupon({required String code, String? planId}) async {
    final body = <String, dynamic>{'code': code, if (planId != null) 'planId': planId};
    final res = await _dio.post<Map<String, dynamic>>(ApiConstants.applyCoupon, data: body);
    return CouponModel.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<SubscriptionOrderModel> createOrder({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) async {
    final body = <String, dynamic>{
      'planId': planId,
      'billingCycle': billingCycle,
      if (couponCode != null) 'couponCode': couponCode,
    };
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.createSubscriptionOrder,
      data: body,
    );
    return SubscriptionOrderModel.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  Future<List<AvailableCouponModel>> getAvailableCoupons() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.availableCoupons);
    final list = (res.data?['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => AvailableCouponModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> confirmPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    await _dio.post<void>(
      ApiConstants.confirmSubscriptionPayment,
      data: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
  }
}

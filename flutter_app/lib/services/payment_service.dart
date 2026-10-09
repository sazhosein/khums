import 'package:dio/dio.dart';

/// درگاه‌های پرداخت معتبر ایرانی
enum PaymentGateway {
  zarinpal('زرین‌پال', 'https://api.zarinpal.com'),
  idpay('آیدی‌پی', 'https://api.idpay.ir'),
  saman('سامان', 'https://sep.shaparak.ir');

  const PaymentGateway(this.label, this.baseUrl);
  final String label;
  final String baseUrl;
}

class PaymentRequestResult {
  final bool success;
  final String? authority;
  final String? paymentUrl;
  final String? error;

  const PaymentRequestResult({
    required this.success,
    this.authority,
    this.paymentUrl,
    this.error,
  });
}

/// سرویس پرداخت — ارتباط با درگاه‌ها
///
/// ⚠️ در تولید، درخواست پرداخت باید از طریق بک‌اند (Node.js) و با
/// کلید مخفی مرچنت انجام شود، نه از سمت کلاینت.
class PaymentService {
  final Dio _dio;
  final String backendBaseUrl;

  PaymentService({Dio? dio, this.backendBaseUrl = 'https://api.khumsyar.app'})
      : _dio = dio ?? Dio();

  /// درخواست پرداخت — مبلغ به ریال
  Future<PaymentRequestResult> requestPayment({
    required double amountToman,
    required PaymentGateway gateway,
    required String description,
    required String callbackUrl,
  }) async {
    try {
      final response = await _dio.post(
        '$backendBaseUrl/v1/payments/request',
        data: {
          'amount': (amountToman * 10).round(), // تبدیل تومان به ریال
          'gateway': gateway.name,
          'description': description,
          'callbackUrl': callbackUrl,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return PaymentRequestResult(
        success: true,
        authority: data['authority'] as String?,
        paymentUrl: data['paymentUrl'] as String?,
      );
    } on DioException catch (e) {
      return PaymentRequestResult(
        success: false,
        error: e.message ?? 'خطا در ارتباط با درگاه پرداخت',
      );
    }
  }

  /// تأیید پرداخت پس از بازگشت از درگاه
  Future<bool> verifyPayment({
    required String authority,
    required double amountToman,
  }) async {
    try {
      final response = await _dio.post(
        '$backendBaseUrl/v1/payments/verify',
        data: {
          'authority': authority,
          'amount': (amountToman * 10).round(),
        },
      );
      return (response.data as Map<String, dynamic>)['verified'] == true;
    } catch (_) {
      return false;
    }
  }
}

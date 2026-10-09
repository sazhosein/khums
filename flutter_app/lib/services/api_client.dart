import 'package:dio/dio.dart';
import '../models/marja.dart';

/// کلاینت API — دریافت و به‌روزرسانی قواعد فقهی از سرور، احراز هویت OTP
class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient({Dio? dio, this.baseUrl = 'https://api.khumsyar.app'})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
            ));

  /// دریافت لیست مراجع و قواعد به‌روز از سرور
  Future<List<Marja>> fetchMarjas() async {
    final res = await _dio.get('/v1/marjas');
    final list = (res.data as Map<String, dynamic>)['data'] as List;
    return list
        .map((e) => Marja.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// درخواست کد یک‌بارمصرف پیامکی
  Future<void> requestOtp(String phone) async {
    await _dio.post('/v1/auth/otp/request', data: {'phone': phone});
  }

  /// تأیید کد و دریافت توکن
  Future<String> verifyOtp(String phone, String code) async {
    final res = await _dio.post(
      '/v1/auth/otp/verify',
      data: {'phone': phone, 'code': code},
    );
    return (res.data as Map<String, dynamic>)['token'] as String;
  }

  /// همگام‌سازی پرداخت‌های کاربر
  Future<List<Map<String, dynamic>>> fetchPayments(String token) async {
    final res = await _dio.get(
      '/v1/payments',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ((res.data as Map<String, dynamic>)['data'] as List)
        .cast<Map<String, dynamic>>();
  }
}

/// ========================================
/// network_service.dart - خدمة الشبكة
/// نظام إدارة التعليم / Education Management System
/// ========================================
///
/// إدارة الاتصالات مع السيرفر PHP/MySQL
/// HTTP Client + WebSocket

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/api_endpoints.dart';
import 'prefs_service.dart';

/// حالة الاتصال / Connection Status
enum ConnectionStatus { connected, disconnected, connecting, error }

/// نتيجة طلب API / API Response
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
    this.errors,
  });

  factory ApiResponse.success(T data, {String? message, int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(
    String message, {
    int statusCode = 500,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

/// خدمة الشبكة / Network Service
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final http.Client _client = http.Client();
  final PrefsService _prefs = PrefsService();

  WebSocketChannel? _wsChannel;
  StreamController<Map<String, dynamic>>? _wsController;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus get status => _status;

  /// الحصول على Base URL
  String get baseUrl {
    // على الويب نستخدم رابط الويب
    if (kIsWeb) {
      return ApiEndpoints.webBaseUrl;
    }
    // على الموبايل نستخدم الرابط المحفوظ أو الافتراضي
    return _prefs.serverUrl;
  }

  /// Headers الأساسية
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Device-ID': _prefs.deviceId,
    };

    final token = _prefs.authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ===== طلبات HTTP / HTTP Requests =====

  /// طلب GET
  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال', statusCode: 408);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت', statusCode: 0);
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: $e', statusCode: 500);
    }
  }

  /// طلب POST
  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال', statusCode: 408);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت', statusCode: 0);
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: $e', statusCode: 500);
    }
  }

  /// طلب PUT
  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال', statusCode: 408);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت', statusCode: 0);
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: $e', statusCode: 500);
    }
  }

  /// طلب DELETE
  Future<ApiResponse<Map<String, dynamic>>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال', statusCode: 408);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت', statusCode: 0);
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: $e', statusCode: 500);
    }
  }

  /// تحليل الاستجابة
  ApiResponse<Map<String, dynamic>> _parseResponse(http.Response response) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data,
          message: data['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          data['message'] as String? ?? 'حدث خطأ',
          statusCode: response.statusCode,
          errors: data['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'خطأ في تحليل الاستجابة',
        statusCode: response.statusCode,
      );
    }
  }

  // ===== WebSocket =====

  /// الاتصال بـ WebSocket
  Future<void> connectWebSocket() async {
    if (_status == ConnectionStatus.connecting) return;

    _status = ConnectionStatus.connecting;

    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(ApiEndpoints.wsUrl));

      _wsController = StreamController<Map<String, dynamic>>.broadcast();

      _wsChannel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            _wsController?.add(data);
          } catch (e) {
            print('❌ WebSocket parse error: $e');
          }
        },
        onDone: () {
          _status = ConnectionStatus.disconnected;
          _wsController?.close();
        },
        onError: (error) {
          _status = ConnectionStatus.error;
          print('❌ WebSocket error: $error');
        },
      );

      _status = ConnectionStatus.connected;
      print('✅ WebSocket connected');

      // إرسال رسالة مصادقة
      sendWebSocketMessage({
        'type': 'auth',
        'token': _prefs.authToken,
        'device_id': _prefs.deviceId,
      });
    } catch (e) {
      _status = ConnectionStatus.error;
      print('❌ WebSocket connection failed: $e');
    }
  }

  /// إرسال رسالة عبر WebSocket
  void sendWebSocketMessage(Map<String, dynamic> message) {
    if (_wsChannel == null) return;
    _wsChannel!.sink.add(json.encode(message));
  }

  /// الاستماع لرسائل WebSocket
  Stream<Map<String, dynamic>>? get webSocketStream => _wsController?.stream;

  /// قطع اتصال WebSocket
  void disconnectWebSocket() {
    _wsChannel?.sink.close();
    _wsController?.close();
    _status = ConnectionStatus.disconnected;
    print('✅ WebSocket disconnected');
  }

  // ===== اختبار الاتصال / Connection Test =====

  /// اختبار الاتصال بالسيرفر
  Future<bool> testConnection([String? url]) async {
    try {
      final testUrl = url ?? baseUrl;
      final response = await _client
          .get(
            Uri.parse('$testUrl/ping.php'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// تغيير رابط السيرفر
  Future<bool> setServerUrl(String url) async {
    // اختبار الرابط الجديد أولاً
    final isValid = await testConnection(url);
    if (isValid) {
      await _prefs.setServerUrl(url);
      return true;
    }
    return false;
  }

  /// إغلاق الخدمة
  void dispose() {
    _client.close();
    disconnectWebSocket();
  }
}

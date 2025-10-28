import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controller/debug_overlay_controller.dart';

/// Helper для логування HTTP запитів (dart http package)
/// 
/// Використання:
/// ```dart
/// final response = await HttpLogger.get('https://api.example.com/users');
/// ```
class HttpLogger {
  /// GET request з автоматичним логуванням
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final response = await http.get(url, headers: headers);
      final duration = DateTime.now().difference(startTime);
      
      _logRequest(
        method: 'GET',
        url: url.toString(),
        headers: headers,
        statusCode: response.statusCode,
        responseBody: response.body,
        duration: duration,
      );
      
      return response;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logRequest(
        method: 'GET',
        url: url.toString(),
        headers: headers,
        statusCode: 0,
        errorMessage: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  /// POST request з автоматичним логуванням
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final response = await http.post(url, headers: headers, body: body);
      final duration = DateTime.now().difference(startTime);
      
      _logRequest(
        method: 'POST',
        url: url.toString(),
        headers: headers,
        requestBody: body,
        statusCode: response.statusCode,
        responseBody: response.body,
        duration: duration,
      );
      
      return response;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logRequest(
        method: 'POST',
        url: url.toString(),
        headers: headers,
        requestBody: body,
        statusCode: 0,
        errorMessage: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  /// PUT request з автоматичним логуванням
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final response = await http.put(url, headers: headers, body: body);
      final duration = DateTime.now().difference(startTime);
      
      _logRequest(
        method: 'PUT',
        url: url.toString(),
        headers: headers,
        requestBody: body,
        statusCode: response.statusCode,
        responseBody: response.body,
        duration: duration,
      );
      
      return response;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logRequest(
        method: 'PUT',
        url: url.toString(),
        headers: headers,
        requestBody: body,
        statusCode: 0,
        errorMessage: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  /// DELETE request з автоматичним логуванням
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final response = await http.delete(url, headers: headers);
      final duration = DateTime.now().difference(startTime);
      
      _logRequest(
        method: 'DELETE',
        url: url.toString(),
        headers: headers,
        statusCode: response.statusCode,
        responseBody: response.body,
        duration: duration,
      );
      
      return response;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      _logRequest(
        method: 'DELETE',
        url: url.toString(),
        headers: headers,
        statusCode: 0,
        errorMessage: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  static void _logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? requestBody,
    required int statusCode,
    String? responseBody,
    String? errorMessage,
    Duration? duration,
  }) {
    // Parse JSON if possible
    dynamic parsedRequest = requestBody;
    dynamic parsedResponse = responseBody;

    if (requestBody is String) {
      try {
        parsedRequest = jsonDecode(requestBody);
      } catch (_) {
        // Keep as string
      }
    }

    if (responseBody != null) {
      try {
        parsedResponse = jsonDecode(responseBody);
      } catch (_) {
        // Keep as string
      }
    }

    final log = NetworkLog.create(
      method: method,
      endpoint: url,
      statusCode: statusCode,
      duration: duration,
      requestHeaders: headers != null ? Map<String, dynamic>.from(headers) : null,
      requestBody: parsedRequest,
      responseBody: parsedResponse,
      errorMessage: errorMessage,
    );

    DebugOverlayController.instance.addLog(log);
  }

  /// Ручне логування (для Firebase, GraphQL, etc.)
  static void logManual({
    required String method,
    required String endpoint,
    required int statusCode,
    Duration? duration,
    Map<String, dynamic>? requestHeaders,
    dynamic requestBody,
    Map<String, dynamic>? responseHeaders,
    dynamic responseBody,
    String? errorMessage,
  }) {
    final log = NetworkLog.create(
      method: method,
      endpoint: endpoint,
      statusCode: statusCode,
      duration: duration,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      responseHeaders: responseHeaders,
      responseBody: _extractFirebaseData(responseBody),
      errorMessage: errorMessage,
    );

    DebugOverlayController.instance.addLog(log);
  }

  /// Витягує дані з Firebase об'єктів для логування
  static dynamic _extractFirebaseData(dynamic data) {
    if (data == null) return null;

    // DocumentSnapshot
    if (data.runtimeType.toString().contains('DocumentSnapshot')) {
      try {
        final snapshot = data as dynamic;
        return {
          'id': snapshot.id,
          'exists': snapshot.exists,
          'data': snapshot.data(),
          'metadata': {
            'hasPendingWrites': snapshot.metadata.hasPendingWrites,
            'isFromCache': snapshot.metadata.isFromCache,
          }
        };
      } catch (e) {
        return 'Error extracting DocumentSnapshot: $e';
      }
    }

    // QuerySnapshot
    if (data.runtimeType.toString().contains('QuerySnapshot')) {
      try {
        final snapshot = data as dynamic;
        return {
          'docs': snapshot.docs.map((doc) => {
            'id': doc.id,
            'data': doc.data(),
          }).toList(),
          'size': snapshot.size,
          'empty': snapshot.docs.isEmpty,
        };
      } catch (e) {
        return 'Error extracting QuerySnapshot: $e';
      }
    }

    // HttpsCallableResult
    if (data.runtimeType.toString().contains('HttpsCallableResult')) {
      try {
        final result = data as dynamic;
        return result.data;
      } catch (e) {
        return 'Error extracting HttpsCallableResult: $e';
      }
    }

    // Звичайні дані
    return data;
  }
}


import 'dart:convert';
import 'package:dio/dio.dart';
import '../controller/debug_overlay_controller.dart';

/// A Dio interceptor that captures all network requests and responses for debugging purposes.
///
/// This interceptor automatically logs all HTTP traffic to the debug overlay,
/// including request/response headers, body content, timing information,
/// and error details. It's designed to provide comprehensive network
/// debugging capabilities for Flutter applications.
///
/// ## Usage
///
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(DebugInterceptor());
/// ```
class DebugInterceptor extends Interceptor {
  final Map<RequestOptions, DateTime> _requestTimestamps = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimestamps[options] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = _requestTimestamps[response.requestOptions];
    final duration = startTime != null 
        ? DateTime.now().difference(startTime).inMilliseconds 
        : 0;

    final uri = response.requestOptions.uri;
    final log = NetworkLog.create(
      method: response.requestOptions.method,
      endpoint: uri.toString(),
      fullUrl: uri.toString(),
      domain: '${uri.scheme}://${uri.host}',
      path: uri.path,
      queryParams: uri.queryParameters.isNotEmpty ? uri.queryParameters : null,
      statusCode: response.statusCode ?? 0,
      requestHeaders: response.requestOptions.headers,
      requestBody: response.requestOptions.data,
      responseHeaders: _convertHeadersToStringMap(response.headers.map),
      responseBody: _processResponseBody(response.data),
      duration: Duration(milliseconds: duration),
    );

    DebugOverlayController.instance.addLog(log);
    _requestTimestamps.remove(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = _requestTimestamps[err.requestOptions];
    final duration = startTime != null 
        ? DateTime.now().difference(startTime).inMilliseconds 
        : 0;

    final uri = err.requestOptions.uri;
    final log = NetworkLog.create(
      method: err.requestOptions.method,
      endpoint: uri.toString(),
      fullUrl: uri.toString(),
      domain: '${uri.scheme}://${uri.host}',
      path: uri.path,
      queryParams: uri.queryParameters.isNotEmpty ? uri.queryParameters : null,
      statusCode: err.response?.statusCode ?? 0,
      requestHeaders: err.requestOptions.headers,
      requestBody: err.requestOptions.data,
      responseHeaders: err.response?.headers.map != null 
          ? _convertHeadersToStringMap(err.response!.headers.map) 
          : null,
      responseBody: err.response?.data != null 
          ? _processResponseBody(err.response!.data) 
          : null,
      duration: Duration(milliseconds: duration),
    );

    DebugOverlayController.instance.addLog(log);
    _requestTimestamps.remove(err.requestOptions);
    handler.next(err);
  }

  /// Converts Dio headers from Map<String, List<String>> to Map<String, dynamic>
  /// for better JSON display in the debug overlay
  Map<String, dynamic> _convertHeadersToStringMap(Map<String, List<String>> headers) {
    final Map<String, dynamic> result = {};
    headers.forEach((key, values) {
      if (values.length == 1) {
        result[key] = values.first;
      } else {
        result[key] = values;
      }
    });
    return result;
  }

  /// Processes response body to ensure proper JSON display
  /// Handles Dio's response data format and converts it to a displayable format
  dynamic _processResponseBody(dynamic data) {
    if (data == null) return null;
    
    // If it's already a Map or List, return as-is
    if (data is Map || data is List) {
      return data;
    }
    
    // If it's a string, try to parse as JSON
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        // If parsing fails, return the string as-is
        return data;
      }
    }
    
    // For other types, convert to string
    return data.toString();
  }
}

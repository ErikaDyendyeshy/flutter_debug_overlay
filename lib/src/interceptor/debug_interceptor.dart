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
    _logNetworkActivity(
      response.requestOptions,
      statusCode: response.statusCode ?? 0,
      responseBody: response.data,
      responseHeaders: response.headers.map,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logNetworkActivity(
      err.requestOptions,
      statusCode: err.response?.statusCode ?? 0,
      responseBody: err.response?.data,
      errorMessage: err.message,
      responseHeaders: err.response?.headers.map,
    );
    handler.next(err);
  }

  /// Logs network activity to the debug overlay controller.
  /// 
  /// This method processes request and response data, parses URL components
  /// for better QA visibility, and creates a comprehensive network log
  /// entry with all relevant information.
  void _logNetworkActivity(
    RequestOptions options, {
    required int statusCode,
    dynamic responseBody,
    Map<String, List<String>>? responseHeaders,
    String? errorMessage,
  }) {
    final startTime = _requestTimestamps[options];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    // Remove from tracking map
    _requestTimestamps.remove(options);

    // Parse URL components for better QA visibility
    final fullUrl = options.uri.toString();
    final uri = Uri.parse(fullUrl);
    final domain = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
    final path = uri.path;
    final queryParams = uri.queryParameters.isNotEmpty ? uri.queryParameters : null;

    // Create network log with comprehensive information
    final log = NetworkLog.create(
      method: options.method,
      endpoint: options.path,
      fullUrl: fullUrl,
      domain: domain,
      path: path,
      queryParams: queryParams,
      statusCode: statusCode,
      duration: duration,
      requestHeaders: options.headers.isNotEmpty
          ? Map<String, dynamic>.from(options.headers)
          : null,
      requestBody: options.data,
      responseHeaders: responseHeaders != null
          ? Map<String, dynamic>.from(
              responseHeaders.map((key, value) => MapEntry(key, value.join(', '))),
            )
          : null,
      responseBody: responseBody,
      errorMessage: errorMessage,
    );

    // Add log to the debug overlay controller
    DebugOverlayController.instance.addLog(log);
  }
}



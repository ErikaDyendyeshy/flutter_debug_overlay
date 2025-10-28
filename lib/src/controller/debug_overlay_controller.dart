import 'package:flutter/foundation.dart';

/// Simple data model for network logs
class NetworkLog {
  final String id;
  final String method;
  final String endpoint;
  final String? fullUrl;
  final String? domain;
  final String? path;
  final Map<String, dynamic>? queryParams;
  final int statusCode;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic>? requestHeaders;
  final dynamic requestBody;
  final Map<String, dynamic>? responseHeaders;
  final dynamic responseBody;
  final String? errorMessage;

  NetworkLog({
    required this.id,
    required this.method,
    required this.endpoint,
    this.fullUrl,
    this.domain,
    this.path,
    this.queryParams,
    required this.statusCode,
    required this.timestamp,
    this.duration,
    this.requestHeaders,
    this.requestBody,
    this.responseHeaders,
    this.responseBody,
    this.errorMessage,
  });

  factory NetworkLog.create({
    required String method,
    required String endpoint,
    String? fullUrl,
    String? domain,
    String? path,
    Map<String, dynamic>? queryParams,
    required int statusCode,
    Duration? duration,
    Map<String, dynamic>? requestHeaders,
    dynamic requestBody,
    Map<String, dynamic>? responseHeaders,
    dynamic responseBody,
    String? errorMessage,
  }) {
    return NetworkLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      endpoint: endpoint,
      fullUrl: fullUrl,
      domain: domain,
      path: path,
      queryParams: queryParams,
      statusCode: statusCode,
      timestamp: DateTime.now(),
      duration: duration,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      errorMessage: errorMessage,
    );
  }

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  bool get isClientError => statusCode >= 400 && statusCode < 500;

  bool get isServerError => statusCode >= 500 && statusCode < 600;

  String get statusDescription {
    if (isSuccess) return 'Success';
    if (isClientError) return 'Client Error';
    if (isServerError) return 'Server Error';
    return 'Unknown';
  }
}

/// Main controller for debug overlay
///
/// Singleton that manages all debug overlay state using ChangeNotifier.
/// Much simpler than BLoC - no dependencies, no conflicts!
class DebugOverlayController extends ChangeNotifier {
  // Singleton
  static final instance = DebugOverlayController._();

  DebugOverlayController._();

  final List<NetworkLog> _logs = [];
  bool _isOverlayVisible = true;
  bool _isBottomSheetVisible = false;

  static const int maxLogs = 100;

  List<NetworkLog> get logs => _logs;

  bool get isOverlayVisible => _isOverlayVisible;

  bool get isBottomSheetVisible => _isBottomSheetVisible;

  /// Add a new network log
  void addLog(NetworkLog log) {
    _logs.insert(0, log);

    if (_logs.length > maxLogs) {
      _logs.removeRange(maxLogs, _logs.length);
    }

    notifyListeners();
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  /// Show/hide overlay
  void setOverlayVisible(bool visible) {
    _isOverlayVisible = visible;
    if (!visible) {
      _isBottomSheetVisible = false;
    }
    notifyListeners();
  }

  /// Show bottom sheet
  void showBottomSheet() {
    _isBottomSheetVisible = true;
    notifyListeners();
  }

  /// Hide bottom sheet
  void hideBottomSheet() {
    _isBottomSheetVisible = false;
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _logs.clear();
    _isOverlayVisible = true;
    _isBottomSheetVisible = false;
    notifyListeners();
  }
}

/// Flutter Debug Overlay - Simple QA Testing Tool
/// 
/// A lightweight debug overlay for Flutter with network logging and JSON viewer.
/// No dependencies on BLoC or get_it - works with any project!
/// 
/// ## Quick Start
/// 
/// 1. Wrap your app:
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return DebugOverlayWrapper(child: child!);
///   },
/// );
/// ```
/// 
/// 2. Add interceptor (if using Dio):
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(DebugInterceptor());
/// ```
/// 
/// That's it! Tap the 🐞 button to view logs.
library;

// Core Controller
export 'src/controller/debug_overlay_controller.dart';

// Network Interceptors & Helpers
export 'src/interceptor/debug_interceptor.dart'; // For Dio
export 'src/helpers/http_logger.dart'; // For http package
export 'src/helpers/firebase_logger.dart'; // For Firebase

// UI Widgets
export 'src/widgets/debug_overlay_wrapper.dart';
export 'src/widgets/draggable_debug_button.dart';
export 'src/widgets/debug_logs_bottom_sheet.dart';
export 'src/widgets/log_detail_view.dart';

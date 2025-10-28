# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-12-19

### 🎉 Initial Release

**flutter_debug_overlay** - A professional debug overlay widget for QA testing with comprehensive network logging capabilities.

#### ✨ Features
- **Network Logging**: Automatic capture of HTTP requests and responses
- **JSON Viewer**: Syntax-highlighted JSON display with expandable nodes
- **URL Components**: Separate display of domain, path, and query parameters
- **Timing Information**: Request duration and status code visualization
- **Filtering**: Search and filter network logs by method, status, or content
- **Dio Integration**: Built-in interceptor for Dio HTTP client
- **HTTP Package Support**: Helper methods for http package
- **Firebase Support**: Logging wrappers for Firebase Functions and Firestore
- **Modular Architecture**: Clean, reusable components for easy maintenance

#### 🔧 Technical Details
- **Zero Dependencies**: No BLoC, get_it, or other complex dependencies
- **Lightweight**: Only 18KB compressed package size
- **Professional Code**: Comprehensive English documentation
- **QA-Friendly**: Designed specifically for quality assurance testing
- **Easy Integration**: Simple wrapper widget with minimal setup

#### 📱 Usage
```dart
// Wrap your app
MaterialApp(
  builder: (context, child) {
    return DebugOverlayWrapper(child: child!);
  },
);

// Add Dio interceptor
dio.interceptors.add(DebugInterceptor());
```

#### 🎯 Perfect For
- QA testing and debugging
- Network request monitoring
- API response validation
- Development and staging environments
- Flutter app testing workflows
# 🐞 QA Debug Overlay
[![pub package](https://img.shields.io/pub/v/qa_debug_overlay.svg)](https://pub.dev/packages/qa_debug_overlay)
[![GitHub stars](https://img.shields.io/github/stars/erika-dev/qa_debug_overlay.svg)](https://github.com/erika-dev/qa_debug_overlay)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

QA Debug Overlay — inspect HTTP calls, view JSON logs, and debug Flutter apps effortlessly.


## 🎬 Demo

![Demo](demo.gif)

*Demo showing the debug overlay in action on iOS simulator*

## ✨ Features

- **🐞 Draggable Debug Button** - Tap to view logs
- **📊 Network Logging** - Automatic request/response capture
- **🔍 JSON Viewer** - Collapsible tree view
- **🪶 Super Lightweight** - Flexible dependencies, no version conflicts
- **🚀 Zero Configuration** - No initialization needed!
- **✅ No Conflicts** - Works with any project setup

## 📦 Installation

```yaml
dependencies:
  qa_debug_overlay: ^1.0.0
  # Add your HTTP client (optional):
  dio: ^5.9.0  # For automatic logging
  http: ^1.5.0 # For manual logging
```

## 🚀 Quick Start

### 1. Wrap Your App (2 lines of code!)

```dart
MaterialApp(
  builder: (context, child) {
    return DebugOverlayWrapper(child: child!);
  },
);
```

### 2. Add Interceptor (if using Dio)

```dart
final dio = Dio();
dio.interceptors.add(DebugInterceptor());
```

**That's it!** The 🐞 button will appear. Tap it to view logs.

## 🌐 Supported HTTP Clients

The debug overlay works with **multiple HTTP clients** - add only what you need:

### 1. **Dio** (Recommended - Automatic Logging)
```yaml
dependencies:
  qa_debug_overlay: ^1.0.0
  dio: ^5.9.0  # Add this for automatic logging
```

```dart
final dio = Dio();
dio.interceptors.add(DebugInterceptor()); // Automatic logging
await dio.get('https://api.example.com');
```

### 2. **HTTP Package** (Manual Logging)
```yaml
dependencies:
  qa_debug_overlay: ^1.0.0
  http: ^1.5.0  # Add this for manual logging
```

```dart
import 'package:qa_debug_overlay/qa_debug_overlay.dart';

// Use wrapper methods for automatic logging
final response = await TestHttpLogger.getWithLogging('https://api.example.com');
final response = await TestHttpLogger.postWithLogging('https://api.example.com', data: data);
```

### 3. **Any HTTP Client** (Manual Logging)
```yaml
dependencies:
  qa_debug_overlay: ^1.0.0
  # No additional dependencies needed!
```

```dart
// Log any request manually
DebugOverlayController.instance.addLog(
  NetworkLog.create(
    method: 'GET',
    endpoint: '/api/users',
    statusCode: 200,
    requestBody: requestData,
    responseBody: responseData,
  ),
);
```

---

## 📖 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:qa_debug_overlay/qa_debug_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // Just wrap with builder - no init needed!
      builder: (context, child) {
        return DebugOverlayWrapper(child: child!);
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    dio.interceptors.add(DebugInterceptor()); // Add interceptor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await dio.get('https://jsonplaceholder.typicode.com/users');
          },
          child: const Text('Make API Call'),
        ),
      ),
    );
  }
}
```

---

## 🎯 Features

### Draggable Button
- Drag anywhere on screen
- Always on top
- Tap to open logs

### Network Logs
- Method (GET, POST, PUT, DELETE)
- Status code (color-coded)
- Endpoint URL
- Timestamp ("5s ago")
- Duration (ms)

### Log Details
- Full request/response
- JSON tree viewer
- Headers
- Copy to clipboard

---

## 🔧 Advanced Usage

### Programmatic Control

```dart
// Access controller
final controller = DebugOverlayController.instance;

// Show/hide overlay
controller.setOverlayVisible(true);

// Show/hide bottom sheet
controller.showBottomSheet();
controller.hideBottomSheet();

// Add manual log
controller.addLog(NetworkLog.create(
  method: 'GET',
  endpoint: '/api/test',
  statusCode: 200,
));

// Clear logs
controller.clearLogs();

// Listen to changes
controller.addListener(() {
  print('Logs updated: ${controller.logs.length}');
});
```

### Conditional Usage (Debug Only)

```dart
import 'package:flutter/foundation.dart';

MaterialApp(
  builder: (context, child) {
    // Only show in debug mode
    if (kDebugMode) {
      return DebugOverlayWrapper(child: child!);
    }
    return child!;
  },
);
```

---

## 📊 What's Inside

```
lib/
├── controller/
│   └── debug_overlay_controller.dart  # Simple ChangeNotifier
├── interceptor/
│   └── debug_interceptor.dart         # Dio interceptor
└── widgets/
    ├── debug_overlay_wrapper.dart     # Main wrapper
    ├── draggable_debug_button.dart    # Floating button
    ├── debug_logs_bottom_sheet.dart   # Bottom sheet UI
    └── log_detail_view.dart           # Detail page
```

---

## 🐛 Troubleshooting

### Bug button doesn't appear?

Check:
1. ✅ Wrapped with `DebugOverlayWrapper`
2. ✅ Used in `builder` parameter
3. ✅ Did Hot Restart (not just hot reload)

### Logs are empty?

Check:
1. ✅ Added `DebugInterceptor()` to Dio
2. ✅ Made an API call
3. ✅ Tapped the 🐞 button

### Using without Dio?

You can manually add logs:

```dart
DebugOverlayController.instance.addLog(
  NetworkLog.create(
    method: 'GET',
    endpoint: '/api/test',
    statusCode: 200,
    requestBody: {'key': 'value'},
    responseBody: {'result': 'success'},
  ),
);
```

---

## 🤝 Contributing

Contributions welcome! This is now a simple, maintainable codebase.

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file.

---

## 🙏 Credits

Created by [Erika](https://github.com/ErikaDyendyeshy) — QA meets Flutter magic 💚

**Made Simple. No Drama.** 😎

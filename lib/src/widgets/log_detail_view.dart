import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/debug_overlay_controller.dart';
import 'url_info_widget.dart';
import 'timing_info_widget.dart';
import 'json_viewer_widget.dart';

/// A detailed view widget for displaying comprehensive information about a single network log entry.
///
/// This widget provides an in-depth view of HTTP requests and responses,
/// including URL components, headers, body content, timing information,
/// and error details. It's designed for thorough debugging and analysis.
class LogDetailView extends StatelessWidget {
  /// The network log entry to display.
  final NetworkLog log;

  /// Creates a new [LogDetailView].
  const LogDetailView({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyLogToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimingInfoWidget(log: log),
            const SizedBox(height: 16),
            UrlInfoWidget(log: log),
            const SizedBox(height: 16),
            _buildRequestSection(context),
            const SizedBox(height: 16),
            _buildResponseSection(context),
            if (log.errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSection(BuildContext context) {
    if (log.requestHeaders == null && log.requestBody == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (log.requestHeaders != null)
          JsonViewerWidget(
            title: 'Headers',
            data: log.requestHeaders,
          ),
        if (log.requestHeaders != null && log.requestBody != null)
          const SizedBox(height: 16),
        if (log.requestBody != null)
          JsonViewerWidget(
            title: 'Body',
            data: log.requestBody,
          ),
      ],
    );
  }

  Widget _buildResponseSection(BuildContext context) {
    if (log.responseHeaders == null && log.responseBody == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (log.responseHeaders != null)
          JsonViewerWidget(
            title: 'Headers',
            data: log.responseHeaders,
          ),
        if (log.responseHeaders != null && log.responseBody != null)
          const SizedBox(height: 16),
        if (log.responseBody != null)
          JsonViewerWidget(
            title: 'Body',
            data: log.responseBody,
          ),
      ],
    );
  }

  Widget _buildErrorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Error',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          child: Text(
            log.errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  void _copyLogToClipboard(BuildContext context) {
    final text = _prettyPrint(log);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log copied to clipboard')),
    );
  }

  String _prettyPrint(dynamic json) {
    try {
      if (json is String) {
        final decoded = jsonDecode(json);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}
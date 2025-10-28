import 'dart:convert';

import 'package:flutter/material.dart';

import '../controller/debug_overlay_controller.dart';
import 'json_tree_view.dart';

/// A bottom sheet widget that displays network logs in a scrollable interface.
///
/// This widget provides a comprehensive view of HTTP requests and responses,
/// including headers, body content, and error information. It features
/// expandable log entries with detailed JSON visualization.
class DebugLogsBottomSheet extends StatefulWidget {
  /// Creates a new [DebugLogsBottomSheet].
  const DebugLogsBottomSheet({super.key});

  @override
  State<DebugLogsBottomSheet> createState() => _DebugLogsBottomSheetState();
}

class _DebugLogsBottomSheetState extends State<DebugLogsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildLogsList(context, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🐞', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Debug Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  DebugOverlayController.instance.clearLogs();
                },
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  DebugOverlayController.instance.hideBottomSheet();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return ListenableBuilder(
      listenable: DebugOverlayController.instance,
      builder: (context, _) {
        final logs = DebugOverlayController.instance.logs;

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No network logs yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          controller: scrollController,
          itemCount: logs.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogItem(context, log);
          },
        );
      },
    );
  }

  Widget _buildLogItem(BuildContext context, NetworkLog log) {
    return SizedBox(
      child: ExpansionTile(
        title: _buildLogTitle(log),
        subtitle: _buildLogSubtitle(context, log),
        children: [_buildLogDetails(context, log)],
      ),
    );
  }

  Widget _buildLogTitle(NetworkLog log) {
    return Row(
      children: [
        _buildMethodBadge(context, log.method),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (log.domain != null) _buildDomainText(log.domain!),
              _buildPathText(log.path ?? log.endpoint),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDomainText(String domain) {
    return Text(
      domain,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.blue,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPathText(String path) {
    return Text(
      path,
      style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLogSubtitle(BuildContext context, NetworkLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          spacing: 8,
          children: [
            _buildStatusCodeBadge(context, log),
            Text(_formatTimestamp(log.timestamp)),
          ],
        ),
        if (log.queryParams != null && log.queryParams!.isNotEmpty)
          _buildQueryParamsText(log.queryParams!),
        if (log.duration != null) _buildDurationText(context, log.duration!),
      ],
    );
  }

  Widget _buildQueryParamsText(Map<String, dynamic> queryParams) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        'Query: ${queryParams.entries.map((e) => '${e.key}=${e.value}').join(', ')}',
        style: const TextStyle(fontSize: 11, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDurationText(BuildContext context, Duration duration) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        'Duration: ${duration.inMilliseconds}ms',
        style: TextStyle(
          color: _getDurationColor(context, duration),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusCodeBadge(BuildContext context, NetworkLog log) {
    Color color;
    if (log.isSuccess) {
      color = Colors.green;
    } else if (log.isClientError) {
      color = Colors.orange;
    } else if (log.isServerError) {
      color = Colors.red;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        log.statusCode.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMethodBadge(BuildContext context, String method) {
    Color color;
    switch (method.toUpperCase()) {
      case 'GET':
        color = Colors.blue;
        break;
      case 'POST':
        color = Colors.green;
        break;
      case 'PUT':
        color = Colors.orange;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getDurationColor(BuildContext context, Duration duration) {
    if (duration.inMilliseconds < 500) {
      return Colors.green;
    } else if (duration.inMilliseconds < 1000) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildLogDetails(BuildContext context, NetworkLog log) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.requestHeaders != null || log.requestBody != null) ...[
            _buildDetailSection(
              context,
              'Request',
              log.requestHeaders,
              log.requestBody,
            ),
            const SizedBox(height: 16),
          ],

          if (log.responseHeaders != null || log.responseBody != null) ...[
            _buildDetailSection(
              context,
              'Response',
              log.responseHeaders,
              log.responseBody,
            ),
            const SizedBox(height: 16),
          ],

          if (log.errorMessage != null) ...[
            _buildDetailSection(context, 'Error', null, log.errorMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),

        if (headers != null && headers.isNotEmpty) ...[
          Text(
            'Headers:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 150, maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _buildJsonViewer(context, headers),
          ),
          const SizedBox(height: 8),
        ],

        if (body != null) ...[
          Text(
            'Body:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 500),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _buildJsonViewer(context, body),
          ),
        ],
      ],
    );
  }

  /// Builds a JSON viewer widget that handles different data types consistently.
  ///
  /// This method automatically detects and parses JSON strings, displays
  /// structured data with syntax highlighting, and provides fallback
  /// rendering for non-JSON content.
  Widget _buildJsonViewer(BuildContext context, dynamic data) {
    if (data == null) {
      return _buildNullViewer();
    }

    final jsonData = _parseJsonData(data);
    if (jsonData is Map || jsonData is List) {
      return _buildStructuredJsonViewer(jsonData);
    }

    return _buildFallbackViewer(data);
  }

  Widget _buildNullViewer() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        'null',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStructuredJsonViewer(dynamic jsonData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: _buildConsistentJsonView(jsonData),
    );
  }

  Widget _buildFallbackViewer(dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        data.toString(),
        style: const TextStyle(
          fontFamily: 'monospace',
          color: Colors.black87,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Parses JSON data from various input types.
  ///
  /// Handles string inputs that look like JSON by attempting to parse them,
  /// while preserving other data types as-is.
  dynamic _parseJsonData(dynamic data) {
    if (data is String) {
      if (_looksLikeJson(data)) {
        try {
          return jsonDecode(data);
        } catch (e) {
          return data;
        }
      }
    }
    return data;
  }

  /// Determines if a string looks like JSON based on its structure.
  bool _looksLikeJson(String data) {
    final trimmed = data.trim();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  Widget _buildConsistentJsonView(dynamic data) {
    return Container(
      width: double.infinity,
      child: JsonTreeView(data: data),
    );
  }
}

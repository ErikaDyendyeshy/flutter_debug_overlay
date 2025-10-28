import 'dart:convert';
import 'package:flutter/material.dart';
import 'json_tree_view.dart';

/// A widget that displays JSON data with consistent styling and scrolling.
/// 
/// This widget handles different data types (strings, maps, lists) and
/// provides a unified interface for displaying JSON content in debug logs.
class JsonViewerWidget extends StatelessWidget {
  /// The data to display (can be string, map, list, or other types).
  final dynamic data;
  
  /// The title to display above the JSON content.
  final String title;

  /// Creates a new [JsonViewerWidget].
  const JsonViewerWidget({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100, maxHeight: 400),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: _buildJsonViewer(context, data),
        ),
      ],
    );
  }

  /// Builds a JSON viewer widget that handles different data types consistently.
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
      child: JsonTreeView(data: jsonData),
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
}

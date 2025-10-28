import 'package:flutter/material.dart';

/// A custom JSON tree view widget that provides consistent rendering
/// of JSON data with syntax highlighting and expandable nodes.
///
/// This widget handles nested JSON structures by recursively rendering
/// objects and arrays with proper indentation and color coding for
/// different data types (strings, numbers, booleans, etc.).
class JsonTreeView extends StatefulWidget {
  /// The JSON data to display.
  final dynamic data;
  
  /// The current nesting level for indentation.
  final int level;

  /// Creates a new [JsonTreeView].
  const JsonTreeView({
    super.key,
    required this.data,
    this.level = 0,
  });

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<JsonTreeView> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return _buildJsonNode(widget.data, widget.level);
  }

  /// Builds the appropriate node type based on the data structure.
  Widget _buildJsonNode(dynamic data, int level) {
    if (data is Map) {
      return _buildMapNode(data, level);
    } else if (data is List) {
      return _buildListNode(data, level);
    } else {
      return _buildValueNode(data, level);
    }
  }

  Widget _buildMapNode(Map data, int level) {
    final indent = '  ' * level;
    final entries = data.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildExpandableLine('$indent{', _isExpanded, () => _toggleExpansion()),
        if (_isExpanded) ...[
          for (int i = 0; i < entries.length; i++) ...[
            _buildKeyValueLine(
              indent: '$indent  ',
              key: entries[i].key,
              value: entries[i].value,
              hasComma: i < entries.length - 1,
            ),
            if (entries[i].value is Map || entries[i].value is List) ...[
              Padding(
                padding: EdgeInsets.only(left: (level + 2) * 8.0),
                child: JsonTreeView(data: entries[i].value, level: level + 1),
              ),
            ],
          ],
          _buildLine('$indent}'),
        ] else
          _buildLine('$indent...}'),
      ],
    );
  }

  Widget _buildListNode(List data, int level) {
    final indent = '  ' * level;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildExpandableLine('$indent[', _isExpanded, () => _toggleExpansion()),
        if (_isExpanded) ...[
          for (int i = 0; i < data.length; i++) ...[
            if (data[i] is Map || data[i] is List) ...[
              Padding(
                padding: EdgeInsets.only(left: (level + 2) * 8.0),
                child: JsonTreeView(data: data[i], level: level + 1),
              ),
            ] else
              _buildLine(
                '$indent  ${_formatValue(data[i])}${i < data.length - 1 ? ',' : ''}',
              ),
          ],
          _buildLine('$indent]'),
        ] else
          _buildLine('$indent...]'),
      ],
    );
  }

  Widget _buildValueNode(dynamic data, int level) {
    final indent = '  ' * level;
    return _buildLine('$indent${_formatValue(data)}');
  }

  Widget _buildExpandableLine(
    String content,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 16,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: _parseJsonLine(content),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueLine({
    required String indent,
    required dynamic key,
    required dynamic value,
    required bool hasComma,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: indent,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: '"$key": ',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (value is Map || value is List) ...[
              TextSpan(
                text: '{',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ] else ...[
              TextSpan(
                text: _formatValue(value),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: _getColorForValue(value),
                ),
              ),
            ],
            if (hasComma) ...[
              TextSpan(
                text: ',',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLine(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: RichText(
        text: TextSpan(
          children: _parseJsonLine(content),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  List<TextSpan> _parseJsonLine(String content) {
    final List<TextSpan> spans = [];
    final RegExp jsonPattern = RegExp(
      r'("[^"]*"|\d+\.?\d*|true|false|null|\{|\}|\[|\]|,|:)',
    );

    int lastIndex = 0;
    for (final Match match in jsonPattern.allMatches(content)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        );
      }

      // Add the matched text with appropriate color
      final String matchedText = match.group(0)!;
      spans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: _getColorForJsonToken(matchedText),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      );
    }

    return spans;
  }

  /// Returns the appropriate color for JSON syntax tokens.
  Color _getColorForJsonToken(String token) {
    if (token.startsWith('"') && token.endsWith('"')) {
      return Colors.green; // Strings
    } else if (RegExp(r'^\d+\.?\d*$').hasMatch(token)) {
      return Colors.blue; // Numbers
    } else if (token == 'true' || token == 'false') {
      return Colors.orange; // Booleans
    } else if (token == 'null') {
      return Colors.grey; // Null
    } else if (token == '{' || token == '}') {
      return Colors.purple; // Objects
    } else if (token == '[' || token == ']') {
      return Colors.indigo; // Arrays
    } else if (token == ',') {
      return Colors.grey[600]!; // Commas
    } else if (token == ':') {
      return Colors.grey[600]!; // Colons
    }
    return Colors.black87;
  }

  /// Returns the appropriate color for different data types.
  Color _getColorForValue(dynamic value) {
    if (value is String) {
      return Colors.green;
    } else if (value is num) {
      return Colors.blue;
    } else if (value is bool) {
      return Colors.orange;
    } else if (value == null) {
      return Colors.grey;
    }
    return Colors.black87;
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return '"$value"';
    } else if (value is num) {
      return value.toString();
    } else if (value is bool) {
      return value.toString();
    } else if (value == null) {
      return 'null';
    }
    return value.toString();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}

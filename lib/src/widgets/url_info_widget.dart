import 'package:flutter/material.dart';
import '../controller/debug_overlay_controller.dart';

/// A widget that displays URL components in a structured format.
/// 
/// This widget shows the full URL, domain, path, and query parameters
/// in separate sections for better QA visibility and debugging.
class UrlInfoWidget extends StatelessWidget {
  /// The network log containing URL information.
  final NetworkLog log;

  /// Creates a new [UrlInfoWidget].
  const UrlInfoWidget({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (log.fullUrl != null) _buildFullUrlSection(context),
        if (_hasUrlComponents) _buildUrlComponentsSection(context),
        _buildEndpointSection(context),
      ],
    );
  }

  bool get _hasUrlComponents =>
      log.domain != null || log.path != null || log.queryParams != null;

  Widget _buildFullUrlSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full URL',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            log.fullUrl!,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildUrlComponentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'URL Components',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        if (log.domain != null)
          _buildInfoRow(context, 'Domain', log.domain!),
        if (log.path != null)
          _buildInfoRow(context, 'Path', log.path!),
        if (log.queryParams != null && log.queryParams!.isNotEmpty)
          _buildInfoRow(
            context,
            'Query Parameters',
            log.queryParams!.entries
                .map((e) => '${e.key}=${e.value}')
                .join(', '),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEndpointSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          log.endpoint,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

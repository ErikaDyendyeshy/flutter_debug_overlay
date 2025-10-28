import 'package:flutter/material.dart';
import '../controller/debug_overlay_controller.dart';

/// A widget that displays timing and status information for a network log.
/// 
/// This widget shows the HTTP method, status code, timestamp, and duration
/// in a structured format for easy debugging and analysis.
class TimingInfoWidget extends StatelessWidget {
  /// The network log containing timing information.
  final NetworkLog log;

  /// Creates a new [TimingInfoWidget].
  const TimingInfoWidget({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMethodAndStatusRow(context),
            const SizedBox(height: 12),
            _buildTimingRow(context),
            if (log.duration != null) ...[
              const SizedBox(height: 8),
              _buildDurationRow(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodAndStatusRow(BuildContext context) {
    return Row(
      children: [
        _buildMethodBadge(context),
        const SizedBox(width: 12),
        _buildStatusCodeBadge(context),
        const Spacer(),
        Text(
          _formatTimestamp(log.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodBadge(BuildContext context) {
    final color = _getMethodColor(log.method);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        log.method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusCodeBadge(BuildContext context) {
    final color = _getStatusCodeColor(log.statusCode);
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

  Widget _buildTimingRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          'Request Time: ${_formatDetailedTimestamp(log.timestamp)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDurationRow(BuildContext context) {
    final duration = log.duration!;
    final color = _getDurationColor(duration);
    
    return Row(
      children: [
        Icon(Icons.timer, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          'Duration: ${duration.inMilliseconds}ms',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.blue;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange;
    } else if (statusCode >= 500) {
      return Colors.red;
    }
    return Colors.grey;
  }

  Color _getDurationColor(Duration duration) {
    if (duration.inMilliseconds < 500) {
      return Colors.green;
    } else if (duration.inMilliseconds < 1000) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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

  String _formatDetailedTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}

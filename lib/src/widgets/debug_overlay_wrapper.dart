import 'package:flutter/material.dart';
import '../controller/debug_overlay_controller.dart';
import 'draggable_debug_button.dart';
import 'debug_logs_bottom_sheet.dart';

/// Main debug overlay wrapper widget
///
/// Wraps your app and provides debug overlay functionality.
/// Simple Stack-based implementation - no OverlayEntry needed!
///
/// Usage:
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return DebugOverlayWrapper(child: child!);
///   },
/// );
/// ```
class DebugOverlayWrapper extends StatelessWidget {
  final Widget child;

  const DebugOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DebugOverlayController.instance,
      builder: (context, _) {
        final controller = DebugOverlayController.instance;

        return Stack(
          children: [
            child,

            if (controller.isOverlayVisible) const DraggableDebugButton(),

            // Bottom sheet overlay
            if (controller.isBottomSheetVisible)
              Positioned.fill(
                child: Material(
                  color: Colors.black54,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      controller.hideBottomSheet();
                    },
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap from propagating
                      child: const DebugLogsBottomSheet(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

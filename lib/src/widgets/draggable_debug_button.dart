import 'package:flutter/material.dart';

import '../controller/debug_overlay_controller.dart';

/// Draggable floating debug button (bug emoji 🐞)
///
/// This button can be dragged anywhere on the screen and tapped to
/// open the debug logs bottom sheet.
class DraggableDebugButton extends StatefulWidget {
  const DraggableDebugButton({super.key});

  @override
  State<DraggableDebugButton> createState() => _DraggableDebugButtonState();
}

class _DraggableDebugButtonState extends State<DraggableDebugButton> {
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  static const double buttonSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              (_position.dx + details.delta.dx).clamp(
                0.0,
                size.width - buttonSize,
              ),
              (_position.dy + details.delta.dy).clamp(
                0.0,
                size.height - buttonSize,
              ),
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
        },
        onTap: () {
          if (!_isDragging) {
            DebugOverlayController.instance.showBottomSheet();
          }
        },
        child: Material(
          elevation: _isDragging ? 8 : 4,
          shape: const CircleBorder(),
          color:Color(0xff68e186),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            alignment: Alignment.center,
            child: const Text('🐞', style: TextStyle(fontSize: 28)),
          ),
        ),
      ),
    );
  }
}

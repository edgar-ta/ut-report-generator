import 'package:flutter/material.dart';

class SlideMenuOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;

  const SlideMenuOverlay({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  State<SlideMenuOverlay> createState() => _SlideMenuOverlayState();
}

class _SlideMenuOverlayState extends State<SlideMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // entra desde la derecha
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: close,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(0.5 * _controller.value),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              elevation: 8,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

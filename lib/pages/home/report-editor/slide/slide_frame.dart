import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/control_variables.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class SlideFrame extends StatefulWidget {
  final Widget child;
  final bool isMenuOpen;
  final void Function() openMenu;

  const SlideFrame({
    super.key,
    required this.child,
    required this.isMenuOpen,
    required this.openMenu,
  });

  @override
  State<SlideFrame> createState() => _SlideFrameState();
}

class _SlideFrameState extends State<SlideFrame> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = slideHeight(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight,
      width: screenWidth,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: screenHeight / 2 - 24,
            right: widget.isMenuOpen ? MENU_WIDTH : 0,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: GestureDetector(
                onTap: widget.openMenu,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isHovering
                            ? Colors.black.withOpacity(0.1)
                            : Colors.transparent,
                  ),
                  child: AnimatedRotation(
                    turns: widget.isMenuOpen ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

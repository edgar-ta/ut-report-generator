import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

class SlideFrame extends StatefulWidget {
  final Widget child;
  final double menuWidth;
  final Widget menuContent;

  const SlideFrame({
    super.key,
    required this.child,
    required this.menuWidth,
    required this.menuContent,
  });

  @override
  State<SlideFrame> createState() => _SlideFrameState();
}

class _SlideFrameState extends State<SlideFrame> {
  bool _menuOpen = false;
  bool _isHovering = false;

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
  }

  void _closeMenu() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height - APP_BAR_HEIGHT * 2;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Stack(
        children: [
          // Contenido principal con scroll
          widget.child,

          // Overlay oscuro -> cubre también el FAB de la app
          if (_menuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black54,
                height: screenHeight,
                width: screenWidth,
              ),
            ),

          // Menú deslizable
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            right: _menuOpen ? 0 : -widget.menuWidth,
            child: AnimatedOpacity(
              opacity: _menuOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: widget.menuWidth,
                color: Colors.white,
                child: widget.menuContent,
              ),
            ),
          ),

          // Botón de menú (flecha)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: screenHeight / 2 - 24,
            right: _menuOpen ? widget.menuWidth : 0,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: GestureDetector(
                onTap: _toggleMenu,
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
                    turns:
                        _menuOpen ? 0.0 : 0.5, // 0 -> derecha, 0.5 -> izquierda
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

import 'dart:math' as math;

import 'package:flutter/material.dart';

class RenderButton extends StatefulWidget {
  final Widget Function(void Function() close, int index) builder;

  int count;
  final double distance;
  final double width;
  final double height;

  RenderButton({
    super.key,
    required this.distance,
    required this.builder,
    required this.count,
    required this.width,
    required this.height,
  });

  @override
  State<RenderButton> createState() => _RenderButtonState();
}

class _RenderButtonState extends State<RenderButton>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
    });
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    setState(() {
      _open = false;
    });
    _controller.reverse();
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.extended(
            onPressed: _toggle,
            icon: const Icon(Icons.create),
            label: Text("Renderizar"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ...List.generate(
            widget.count,
            (index) => AnimatedBuilder(
              builder:
                  (context, wrappedWidget) => Positioned(
                    right: 0,
                    bottom: (index + 1) * (widget.distance + widget.height),
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: wrappedWidget,
                    ),
                  ),
              animation: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: widget.builder(_close, index),
              ),
            ),
          ),
          // ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }
}

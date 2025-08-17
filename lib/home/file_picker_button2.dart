import 'package:flutter/material.dart';

/// Custom dropdown button that renders the options list in an Overlay
/// so taps are guaranteed to reach the items.
class FilePickerButton2<T> extends StatefulWidget {
  final List<T> values;
  final T selectedValue;
  final Widget Function(T selected) triggerBuilder;
  final Widget Function(T value, bool isSelected) itemBuilder;
  final Future<void> Function(T value) onItemSelected;
  final Future<void> Function(T value) onTriggerPressed;

  final double maxListHeight;
  final BoxDecoration? menuDecoration;

  const FilePickerButton2({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.triggerBuilder,
    required this.itemBuilder,
    required this.onItemSelected,
    required this.onTriggerPressed,
    this.maxListHeight = 240,
    this.menuDecoration,
  });

  @override
  State<FilePickerButton2<T>> createState() => _FilePickerButton2State<T>();
}

class _FilePickerButton2State<T> extends State<FilePickerButton2<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlay();
    Overlay.of(context)?.insert(_overlayEntry!);
    _controller.forward();
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 6,
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 6),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizeTransition(
                    sizeFactor: _expandAnimation,
                    axisAlignment: -1.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxListHeight,
                      ),
                      child: DecoratedBox(
                        decoration:
                            widget.menuDecoration ??
                            BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.6),
                              ),
                            ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children:
                                widget.values.map((value) {
                                  final isSelected =
                                      value == widget.selectedValue;
                                  return InkWell(
                                    onTap: () {
                                      if (!isSelected) {
                                        widget.onItemSelected(value);
                                      }
                                      _closeDropdown();
                                    },
                                    child: Container(
                                      color:
                                          isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.12)
                                              : Colors.transparent,
                                      child: widget.itemBuilder(
                                        value,
                                        isSelected,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int tealColor = 0xFF009966;

    return CompositedTransformTarget(
      link: _layerLink,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onTriggerPressed(widget.selectedValue);
                _closeDropdown();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(tealColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              child: widget.triggerBuilder(widget.selectedValue),
            ),
            IconButton(
              onPressed: _toggleDropdown,
              icon: AnimatedRotation(
                turns: _isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Color(tealColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}

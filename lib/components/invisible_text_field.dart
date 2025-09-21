import 'package:flutter/material.dart';

class InvisibleTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextStyle? style;
  final TextAlign? textAlign;

  const InvisibleTextField({
    super.key,
    this.controller,
    this.style,
    this.textAlign,
  });

  @override
  State<InvisibleTextField> createState() => _InvisibleTextFieldState();
}

class _InvisibleTextFieldState extends State<InvisibleTextField> {
  bool _isHovered = false;
  bool _isFocused = false;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color _borderColor(BuildContext context) {
    if (_isFocused) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.9);
    } else if (_isHovered) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.5);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _borderColor(context), width: 2),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(border: InputBorder.none),
          style: widget.style,
          textAlign: widget.textAlign ?? TextAlign.start,
        ),
      ),
    );
  }
}

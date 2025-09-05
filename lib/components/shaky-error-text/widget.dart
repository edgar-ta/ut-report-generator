import 'dart:async';

import 'package:flutter/material.dart';

class ShakyErrorText extends StatefulWidget {
  final bool isError;
  final void Function() removeError;
  final String regularText;
  final String errorText;

  const ShakyErrorText({
    super.key,
    required this.isError,
    required this.removeError,
    required this.regularText,
    required this.errorText,
  });

  @override
  State<ShakyErrorText> createState() => _ShakyErrorTextState();
}

class _ShakyErrorTextState extends State<ShakyErrorText>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Timer? _resetErrorTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24)
      .chain(CurveTween(curve: Curves.elasticIn))
      .animate(_shakeController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _resetErrorTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShakyErrorText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isError && !oldWidget.isError) {
      _shakeController.forward(from: 0);

      _resetErrorTimer?.cancel();
      _resetErrorTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) widget.removeError();
      });
    }

    // Si se resuelve el error, limpiar el timer
    if (!widget.isError && oldWidget.isError) {
      _resetErrorTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = _shakeAnimation.value;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: widget.isError ? 0 : 1,
                duration: Duration(milliseconds: 200),
                child: Text(widget.regularText),
              ),
              AnimatedOpacity(
                opacity: widget.isError ? 1 : 0,
                duration: Duration(milliseconds: 100),
                child: Text(
                  widget.errorText,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

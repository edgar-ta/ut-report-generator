import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_parameter.dart';

class ParameterWidget extends StatefulWidget {
  const ParameterWidget({
    super.key,
    required this.parameter,
    required this.editParameter,
  });

  final ImageSlideParameter parameter;
  final Future<void> Function(String value) editParameter;

  @override
  State<ParameterWidget> createState() => _ParameterWidgetState();
}

class _ParameterWidgetState extends State<ParameterWidget> {
  Timer? _timer;
  late TextEditingController _controller;
  Future<void>? _callback;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.parameter.value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(label: Text(widget.parameter.readableName)),
      onChanged: (text) async {
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 250), () async {
          if (_callback == null) {
            _callback = widget.editParameter(text);
          } else {
            _callback!.then((_) {
              widget.editParameter(text);
            });
          }
        });
      },
    );
  }
}

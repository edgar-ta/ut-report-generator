import 'package:flutter/material.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/components/slideshow_editor/delete_slide_button.dart';
import 'package:ut_report_generator/components/util/invisible_text_field.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_parameter.dart';
import 'dart:async';

import 'package:ut_report_generator/pages/home/slideshow_editor/image_slide_section/parameter_widget.dart';

class ImageSlideEditPane extends StatefulWidget {
  final String title;
  final Map<String, ImageSlideParameter> parameters;
  final ImageSlideBloc bloc;
  final Future<void> Function()? deleteSlide;

  const ImageSlideEditPane({
    super.key,
    required this.title,
    required this.parameters,
    required this.bloc,
    required this.deleteSlide,
  });

  @override
  State<ImageSlideEditPane> createState() => _ImageSlideEditPaneState();
}

class _ImageSlideEditPaneState extends State<ImageSlideEditPane> {
  Timer? _debounce;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
  }

  void _rename(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.bloc.rename(text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InvisibleTextField(
          onChanged: _rename,
          controller: _controller,
          label: Text("Título"),
        ),
        ...widget.parameters.entries.map((data) {
          final (key, value) = (data.key, data.value);
          return ParameterWidget(
            parameter: value,
            editParameter: (value) => widget.bloc.editParameter(key, value),
          );
        }),
        DeleteSlideButton(deleteSlide: widget.deleteSlide),
      ],
    );
  }
}

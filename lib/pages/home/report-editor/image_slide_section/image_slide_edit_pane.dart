import 'package:flutter/material.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_parameter.dart';
import 'dart:async';

import 'package:ut_report_generator/pages/home/report-editor/image_slide_section/parameter_widget.dart';

class ImageSlideEditPane extends StatefulWidget {
  final String title;
  final Map<String, ImageSlideParameter> parameters;
  final ImageSlideBloc bloc;

  const ImageSlideEditPane({
    super.key,
    required this.title,
    required this.parameters,
    required this.bloc,
  });

  @override
  State<ImageSlideEditPane> createState() => _ImageSlideEditPaneState();
}

class _ImageSlideEditPaneState extends State<ImageSlideEditPane> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          TextField(onChanged: widget.bloc.rename),
          ...widget.parameters.entries.map((data) {
            final (key, value) = (data.key, data.value);
            return ParameterWidget(
              parameter: value,
              editParameter: (value) => widget.bloc.editParameter(key, value),
            );
          }),
        ],
      ),
    );
  }
}

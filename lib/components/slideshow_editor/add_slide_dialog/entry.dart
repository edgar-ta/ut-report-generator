import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';

class AddSlideEntry {
  final ImageSlideKind kind;
  final String title;
  final Widget preview;

  const AddSlideEntry({
    required this.kind,
    required this.title,
    required this.preview,
  });
}

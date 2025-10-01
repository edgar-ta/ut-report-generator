import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/tabbed_menu.dart';

class ImageSlideSection extends StatefulWidget {
  final ImageSlide initialSlide;

  const ImageSlideSection({super.key, required this.initialSlide});

  @override
  State<ImageSlideSection> createState() => _ImageSlideSectionState();
}

class _ImageSlideSectionState extends State<ImageSlideSection> {
  @override
  Widget build(BuildContext context) {
    return Image.file(File(widget.initialSlide.preview));
  }
}

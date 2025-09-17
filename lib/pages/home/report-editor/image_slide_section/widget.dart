import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/slide/tabbed_menu.dart';

class ImageSlideSection extends StatefulWidget {
  final ImageSlide initialSlide;
  const ImageSlideSection({super.key, required this.initialSlide});

  @override
  State<ImageSlideSection> createState() => _ImageSlideSectionState();
}

class _ImageSlideSectionState extends State<ImageSlideSection> {
  @override
  Widget build(BuildContext context) {
    return SlideFrame(
      menuWidth: 512,
      menuContent: TabbedMenu(
        editTabBuilder: (context) {
          return Column(
            children: [
              ...widget.initialSlide.parameters.entries.map((entry) {
                final (key, value) = (entry.key, entry.value);
                return TextField(decoration: InputDecoration(label: Text(key)));
              }),
            ],
          );
        },
        metadataTabBuilder: (context) {
          return Text("fs");
        },
      ),
      child: Image.file(File(widget.initialSlide.preview)),
    );
  }
}

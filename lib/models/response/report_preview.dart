import 'dart:ui';

import 'package:relative_time/relative_time.dart';

class SlideshowPreview {
  String preview;
  String name;
  String identifier;
  DateTime lastOpen;

  SlideshowPreview({
    required this.preview,
    required this.name,
    required this.identifier,
    required this.lastOpen,
  });

  factory SlideshowPreview.fromJson(Map<String, dynamic> json) {
    return SlideshowPreview(
      preview: json['preview'] as String,
      name: json['name'] as String,
      identifier: json['identifier'] as String,
      lastOpen: DateTime.parse(json['last_open']),
    );
  }
}

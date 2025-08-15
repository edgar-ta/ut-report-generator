import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/types/slide_type.dart';

class SlideClass {
  String id;
  String key;
  SlideType type;
  List<AssetClass> assets;
  Map<String, dynamic> arguments;
  List<String> dataFiles;
  String preview;

  SlideClass({
    required this.id,
    required this.key,
    required this.type,
    required this.assets,
    required this.arguments,
    required this.dataFiles,
    required this.preview,
  });

  factory SlideClass.fromJson(Map<String, dynamic> json) {
    return SlideClass(
      id: json['id'] as String,
      key: json['key'] as String,
      type: slideTypeFromString(json['type'] as String),
      assets:
          (json['assets'] as List)
              .map((asset) => AssetClass.fromJson(asset))
              .toList(),
      arguments: Map<String, dynamic>.from(json['arguments'] as Map),
      dataFiles: List<String>.from(json['data_files'] as List),
      preview: json['preview'] as String,
    );
  }

  SlideClass copyWith({
    String? id,
    String? key,
    SlideType? type,
    List<AssetClass>? assets,
    Map<String, dynamic>? arguments,
    List<String>? dataFiles,
    String? preview,
  }) {
    return SlideClass(
      id: id ?? this.id,
      key: key ?? this.key,
      type: type ?? this.type,
      assets: assets ?? List<AssetClass>.from(this.assets),
      arguments: arguments ?? Map<String, dynamic>.from(this.arguments),
      dataFiles: dataFiles ?? List<String>.from(this.dataFiles),
      preview: preview ?? this.preview,
    );
  }
}

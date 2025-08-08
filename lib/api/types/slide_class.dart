import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/types/slide_type.dart';

class SlideClass {
  String id;
  SlideType type;
  List<AssetClass> assets;
  Map<String, dynamic> arguments;
  String dataFile;
  String preview;

  SlideClass({
    required this.id,
    required this.type,
    required this.assets,
    required this.arguments,
    required this.dataFile,
    required this.preview,
  });

  factory SlideClass.fromJson(Map<String, dynamic> json) {
    return SlideClass(
      id: json['id'] as String,
      type: slideTypeFromString(json['type'] as String),
      assets:
          (json['assets'] as List)
              .map((asset) => AssetClass.fromJson(asset))
              .toList(),
      arguments: json['arguments'] as Map<String, dynamic>,
      dataFile: json['data_file'] as String,
      preview: json['preview'] as String,
    );
  }

  SlideClass copyWith({
    String? id,
    SlideType? type,
    List<AssetClass>? assets,
    Map<String, dynamic>? arguments,
    String? dataFile,
    String? preview,
  }) {
    return SlideClass(
      id: id ?? this.id,
      type: type ?? this.type,
      assets: assets ?? this.assets,
      arguments: arguments ?? this.arguments,
      dataFile: dataFile ?? this.dataFile,
      preview: preview ?? this.preview,
    );
  }
}

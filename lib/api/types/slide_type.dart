import 'package:ut_report_generator/api/types/asset_type.dart';

class SlideType {
  String id;
  String type;
  List<AssetType> assets;
  Map<String, dynamic> arguments;
  String dataFile;
  String preview;

  SlideType({
    required this.id,
    required this.type,
    required this.assets,
    required this.arguments,
    required this.dataFile,
    required this.preview,
  });

  factory SlideType.fromJson(Map<String, dynamic> json) {
    return SlideType(
      id: json['id'] as String,
      type: json['type'] as String,
      assets:
          (json['assets'] as List)
              .map((asset) => AssetType.fromJson(asset))
              .toList(),
      arguments: json['arguments'] as Map<String, dynamic>,
      dataFile: json['data_file'] as String,
      preview: json['preview'] as String,
    );
  }
}

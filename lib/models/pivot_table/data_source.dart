class DataSource {
  final List<String> files;
  final String? mergedFile;

  DataSource({required this.files, this.mergedFile});

  Map<String, dynamic> toJson() {
    return {"files": files, "merged_file": mergedFile};
  }

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      files: List<String>.from(json["files"]),
      mergedFile: json["merged_file"],
    );
  }

  DataSource copyWith({List<String>? files, String? mergedFile}) {
    return DataSource(
      files: files ?? this.files,
      mergedFile: mergedFile ?? this.mergedFile,
    );
  }
}

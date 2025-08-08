import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ut_report_generator/api/edit_slide.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/components/input_component.dart';

class FailureSectionArguments {
  int unit;
  bool showDelayedTeachers;

  FailureSectionArguments({
    required this.unit,
    required this.showDelayedTeachers,
  });

  static FailureSectionArguments fromJson(Map<String, dynamic> map) {
    return FailureSectionArguments(
      unit: map['unit'] as int,
      showDelayedTeachers: map['show_delayed_teachers'] as bool,
    );
  }

  FailureSectionArguments copyWith({int? unit, bool? showDelayedTeachers}) {
    return FailureSectionArguments(
      unit: unit ?? this.unit,
      showDelayedTeachers: showDelayedTeachers ?? this.showDelayedTeachers,
    );
  }

  Map<String, dynamic> toJson() {
    return {'unit': unit, 'show_delayed_teachers': showDelayedTeachers};
  }
}

class FailureSection extends StatefulWidget {
  final StartReport_Response response;

  FailureSection({super.key, required this.response});

  @override
  State<FailureSection> createState() => _FailureSectionState();
}

class _FailureSectionState extends State<FailureSection> {
  late StartReport_Response response;

  String? selectedAsset;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    response = widget.response;
    selectedAsset = widget.response.preview; // Default to the preview image
  }

  FailureSectionArguments parseArguments(Map<String, dynamic> arguments) {
    return FailureSectionArguments.fromJson(arguments);
  }

  void updateArguments(FailureSectionArguments arguments) async {
    setState(() {
      response = StartReport_Response(
        reportDirectory: response.reportDirectory,
        reportName: response.reportName,
        assets: response.assets,
        slideId: response.slideId,
        arguments: arguments.toJson(),
        preview: response.preview,
      );
      isLoading = true;
    });

    try {
      await editSlide(
        response.reportDirectory,
        response.slideId,
        arguments.toJson(),
      ).then((result) {
        setState(() {
          response = StartReport_Response(
            reportDirectory: response.reportDirectory,
            reportName: response.reportName,
            assets: result.assets,
            slideId: response.slideId,
            arguments: response.arguments,
            preview: result.preview,
          );
          selectedAsset =
              result.preview; // Update the selected asset to the new preview
        });
      });
    } catch (e) {
      print("Error updating arguments: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FailureSectionArguments arguments = parseArguments(response.arguments);
    var imageList =
        response.assets.where((value) {
          return value.type == "image";
        }).toList();
    imageList.insert(0, (
      name: "Preview",
      value: response.preview,
      type: "image",
    ));

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Reprobados por Unidad",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Assets and Preview Panel
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 400, // Set a fixed height for the preview panel
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Selected Image Display
                    SizedBox(
                      height: 250, // Fixed height for the selected image
                      child:
                          selectedAsset != null
                              ? Image.file(File(selectedAsset!))
                              : Center(child: Text("No image selected")),
                    ),

                    // Thumbnails and Buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Buttons
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Copy to clipboard logic
                                },
                                child: Text("Copy"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Save logic
                                },
                                child: Text("Save"),
                              ),
                            ],
                          ),
                        ),

                        // Thumbnails
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  imageList.map((asset) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAsset = asset.value;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.file(
                                          File(asset.value),
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Loading Overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),

          // Control Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Unit Dropdown
                DropdownButton<int>(
                  value: arguments.unit,
                  items: List.generate(6, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text("Unit ${index + 1}"),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      updateArguments(
                        FailureSectionArguments(
                          unit: value,
                          showDelayedTeachers: arguments.showDelayedTeachers,
                        ),
                      );
                    }
                  },
                ),

                // Other controls can be added here
              ],
            ),
          ),
        ],
      ),
    );
  }
}

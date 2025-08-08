import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/change_slide_data.dart';
import 'package:ut_report_generator/api/edit_slide.dart';
import 'package:ut_report_generator/api/start_report.dart';
import 'package:ut_report_generator/api/send_request.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/components/input_component.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/failure_section_arguments.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/pick_file_button.dart';

class FailureSection extends StatefulWidget {
  SlideClass initialData;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, String newFilePath) changeSlideData;

  FailureSection({
    super.key,
    required this.initialData,
    required this.editSlide,
    required this.changeSlideData,
  });

  @override
  State<FailureSection> createState() => _FailureSectionState();
}

class _FailureSectionState extends State<FailureSection> {
  late SlideClass slideData;

  String? selectedAsset;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    slideData = widget.initialData;
    selectedAsset = widget.initialData.preview; // Default to the preview image
  }

  void updateArguments(FailureSectionArguments arguments) async {
    setState(() {
      slideData = slideData.copyWith(
        assets: slideData.assets,
        arguments: arguments.toJson(),
        preview: slideData.preview,
      );
      isLoading = true;
    });

    try {
      await editSlide(
        slideData.reportDirectory,
        slideData.slideId,
        arguments.toJson(),
      ).then((result) {
        setState(() {
          // slideData = slideData.copyWith(
          //   assets: result.assets,
          //   arguments: slideData.arguments,
          //   preview: result.preview,
          // );
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
    FailureSectionArguments arguments = FailureSectionArguments.fromJson(
      slideData.arguments,
    );
    var imageList =
        slideData.assets.where((value) {
          return value.type == "image";
        }).toList();
    imageList.insert(
      0,
      AssetClass(name: "Preview", value: slideData.preview, type: "image"),
    );

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
                              PickFileButton(
                                message: "Cambiar datos",
                                onFilePicked: (filePath) async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    await changeSlideData(
                                      newDataFile: filePath,
                                      reportDirectory:
                                          slideData.reportDirectory,
                                      slideId: slideData.slideId,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Archivo cambiado correctamente",
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    rethrow;
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
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

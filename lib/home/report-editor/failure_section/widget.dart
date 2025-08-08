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
  SlideClass slideData;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, String newFilePath) changeSlideData;

  FailureSection({
    super.key,
    required this.slideData,
    required this.editSlide,
    required this.changeSlideData,
  });

  @override
  State<FailureSection> createState() => _FailureSectionState();
}

class _FailureSectionState extends State<FailureSection> {
  // @todo. This index should go back to zero whenever the slide data or the
  // slide arguments change
  int selectedImageIndex = 0;
  bool isLoading = false;

  void _updateArguments(FailureSectionArguments arguments) async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.editSlide(widget.slideData.id, arguments.toJson());
    } catch (e) {
      print("Error updating arguments: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo actualizar la imagen")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FailureSectionArguments arguments = FailureSectionArguments.fromJson(
      widget.slideData.arguments,
    );
    var imageList =
        widget.slideData.assets.where((value) {
          return value.type == "image";
        }).toList();
    imageList.insert(
      0,
      AssetClass(
        name: "Preview",
        value: widget.slideData.preview,
        type: "image",
      ),
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
                      child: Image.file(
                        File(imageList[selectedImageIndex].value),
                      ),
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
                                    await widget.changeSlideData(
                                      widget.slideData.id,
                                      filePath,
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
                                  imageList.indexed.map((tuple) {
                                    var index = tuple.$1;
                                    var asset = tuple.$2;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImageIndex = index;
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
                  items: List.generate(5, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text("Unidad ${index + 1}"),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      _updateArguments(arguments.copyWith(unit: value));
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

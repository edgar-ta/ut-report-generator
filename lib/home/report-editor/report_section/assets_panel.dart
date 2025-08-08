import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/pick_file_button.dart';

class AssetsPanel extends StatefulWidget {
  List<AssetClass> images;
  bool isLoading;
  AssetsPanel({super.key, required this.images, required this.isLoading});

  @override
  State<AssetsPanel> createState() => _AssetsPanelState();
}

class _AssetsPanelState extends State<AssetsPanel> {
  // @todo. This index should go back to zero whenever the slide data or the
  // slide arguments change
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 400),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Image.file(
                  File(widget.images[selectedImageIndex].value),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
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

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          widget.images.indexed.map((tuple) {
                            var index = tuple.$1;
                            var asset = tuple.$2;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImageIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                color:
                                    selectedImageIndex == index
                                        ? Colors.blue
                                        : Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  color: Colors.white,
                                  width: 64,
                                  height: 64,
                                  child: Image.file(File(asset.value)),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Loading Overlay
          if (widget.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

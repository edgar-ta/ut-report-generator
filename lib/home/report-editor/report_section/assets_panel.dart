import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_clipboard/image_clipboard.dart';

import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/pick_file_button.dart';

class AssetsPanel extends StatefulWidget {
  List<AssetClass> images;
  bool isLoading;
  ImageClipboard imageClipboard;

  AssetsPanel({
    super.key,
    required this.images,
    required this.isLoading,
    required this.imageClipboard,
  });

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
                          onPressed: () async {
                            try {
                              var imagePath =
                                  widget.images[selectedImageIndex].value;
                              print("The image path is this");
                              print(imagePath);
                              await widget.imageClipboard.copyImage(imagePath);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Ruta de la imagen copiada al portapapeles",
                                  ),
                                ),
                              );
                            } catch (e) {
                              // Handle errors
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Error al copiar la imagen: $e",
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text("Copiar"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Save logic
                          },
                          child: Text("Guardar"),
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

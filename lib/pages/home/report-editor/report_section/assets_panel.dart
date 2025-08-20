import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ut_report_generator/models/asset_class.dart';

class AssetsPanel extends StatefulWidget {
  List<AssetClass> images;
  bool isLoading;

  AssetsPanel({super.key, required this.images, required this.isLoading});

  @override
  State<AssetsPanel> createState() => _AssetsPanelState();
}

class _AssetsPanelState extends State<AssetsPanel> {
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          color: Colors.white,
          width: double.maxFinite,
          height: double.maxFinite,
          child: Image.file(File(widget.images[selectedImageIndex].value)),
        ),
        Positioned(
          left: 16,
          child: Column(
            spacing: 16,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 256),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
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
                                      ? Theme.of(context).colorScheme.outline
                                      : Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                              child: StatefulBuilder(
                                builder: (context, setInnerState) {
                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      color: Colors.white,
                                      width: 64,
                                      height: 64,
                                      child: Image.file(File(asset.value)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: IconButton(
                  onPressed: () {
                    // Save logic
                  },
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.save),
                ),
              ),
            ],
          ),
        ),

        // Loading Overlay
        if (widget.isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

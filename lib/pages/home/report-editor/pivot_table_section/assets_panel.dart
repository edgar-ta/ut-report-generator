import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetsPanel extends StatefulWidget {
  // List<AssetClass> images;
  String preview;
  bool isLoading;

  AssetsPanel({super.key, required this.preview, required this.isLoading});

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
          child: Image.file(File(widget.preview)),
        ),
        Positioned(
          left: 16,
          child: Column(
            spacing: 16,
            children: [
              SizedBox(
                width: 48,
                height: 48,
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
              SizedBox(
                width: 48,
                height: 48,
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
                  icon: Icon(Icons.delete),
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

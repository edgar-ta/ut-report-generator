import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/home/report-editor/failure_section/pick_file_button.dart';
import 'package:ut_report_generator/home/report-editor/report_section/assets_panel.dart';

class ReportSection extends StatefulWidget {
  SlideClass slideData;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, String newFilePath) changeSlideData;
  Widget Function(
    Map<String, dynamic> arguments,
    Future<void> Function(Map<String, dynamic> arguments),
  )
  controlPanelBuilder;

  ReportSection({
    super.key,
    required this.slideData,
    required this.editSlide,
    required this.changeSlideData,
    required this.controlPanelBuilder,
  });

  @override
  State<ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends State<ReportSection> {
  bool isLoading = false;

  Future<void> _updateArguments(Map<String, dynamic> arguments) async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.editSlide(widget.slideData.id, arguments);
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

  Future<void> _changeSlideData(String filePath) async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.changeSlideData(widget.slideData.id, filePath);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Archivo cambiado correctamente")));
    } catch (e) {
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageList =
        widget.slideData.assets.where((value) {
          return value.type == "image";
        }).toList();
    imageList.insert(
      0,
      AssetClass(
        name: "preview",
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

          Row(
            children: [
              Expanded(
                flex: 2,
                child: AssetsPanel(images: imageList, isLoading: isLoading),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    widget.controlPanelBuilder(
                      widget.slideData.arguments,
                      _updateArguments,
                    ),
                    PickFileButton(
                      message: "Cambiar datos",
                      onFilePicked:
                          (String filePath) => _changeSlideData(filePath),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

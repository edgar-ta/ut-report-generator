import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/types/asset_class.dart';
import 'package:ut_report_generator/api/types/slide_class.dart';
import 'package:ut_report_generator/pages/home/report-editor/report_section/pick_file_button.dart';
import 'package:ut_report_generator/pages/home/report-editor/report_section/assets_panel.dart';

class ReportSection extends StatefulWidget {
  SlideClass slideData;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, List<File> dataFiles) changeSlideData;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo actualizar la imagen")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changeSlideData(List<File> dataFiles) async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.changeSlideData(widget.slideData.id, dataFiles);
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
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          spacing: 12,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Reprobados por Unidad",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Spacer(),
              ],
            ),

            Row(
              spacing: 16,
              children: [
                Expanded(
                  flex: 2,
                  child: AssetsPanel(
                    key: ValueKey(widget.slideData.key),
                    images: imageList,
                    isLoading: isLoading,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widget.controlPanelBuilder(
                        widget.slideData.arguments,
                        _updateArguments,
                      ),
                      PickFileButton(
                        message: "Cambiar datos",
                        onFilesPicked:
                            (List<File> files) => _changeSlideData(files),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

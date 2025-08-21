import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/assets_panel.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/slide_frame.dart';
import 'package:ut_report_generator/pages/home/report-editor/pivot_table_section/tabbed_menu.dart';

class PivotTableSection extends StatefulWidget {
  PivotTable initialTable;
  Future<void> Function(String slideId, Map<String, dynamic> arguments)
  editSlide;
  Future<void> Function(String slideId, List<File> dataFiles) changeSlideData;
  Widget Function(
    Map<String, dynamic> arguments,
    Future<void> Function(Map<String, dynamic> arguments),
  )
  editionPaneBuilder;
  Widget metadataPane;

  PivotTableSection({
    super.key,
    required this.initialTable,
    required this.editSlide,
    required this.changeSlideData,
    required this.editionPaneBuilder,
    required this.metadataPane,
  });

  @override
  State<PivotTableSection> createState() => _PivotTableSectionState();
}

class _PivotTableSectionState extends State<PivotTableSection> {
  bool isLoading = false;

  Future<void> _updateArguments(Map<String, dynamic> arguments) async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.editSlide(widget.initialTable.identifier, arguments);
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
      await widget.changeSlideData(widget.initialTable.identifier, dataFiles);
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
    return SlideFrame(
      menuWidth: 320,
      menuContent: TabbedMenu(
        editTabBuilder:
            (_) => widget.editionPaneBuilder(
              widget.initialTable.arguments,
              _updateArguments,
            ),
        metadataTabBuilder: (_) => widget.metadataPane,
      ),
      child: AssetsPanel(
        preview: widget.initialTable.preview,
        isLoading: isLoading,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/image_slide_section/image_slide_edit_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/pivot_table_section/pivot_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/pivot_table_section/pivot_table_edit_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/slide_metadata_pane.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/tabbed_menu.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class SlideshowEditorMenu extends StatefulWidget {
  SlideshowEditorMenu({
    super.key,
    this.slide,
    required this.imageSlideBlocBuilder,
    required this.pivotTableBlocBuilder,
  });

  Slide? slide;
  ImageSlideBloc Function(ImageSlide) imageSlideBlocBuilder;
  PivotTableBloc Function(PivotTable) pivotTableBlocBuilder;

  @override
  State<SlideshowEditorMenu> createState() => _SlideshowEditorMenuState();
}

class _SlideshowEditorMenuState extends State<SlideshowEditorMenu> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Builder(
        builder: (context) {
          if (widget.slide is PivotTable) {
            return _pivotTableMenu(widget.slide as PivotTable);
          }
          if (widget.slide is ImageSlide) {
            return _imageSlideMenu(widget.slide as ImageSlide);
          }
          return const Text("Tipo de slide inválido");
        },
      ),
    );
  }

  Widget _pivotTableMenu(PivotTable pivotTable) {
    final bloc = widget.pivotTableBlocBuilder(pivotTable);
    return TabbedMenu(
      editTabBuilder:
          (_) => PivotTableEditPane(
            title: pivotTable.title,
            bloc: bloc,
            filters: pivotTable.filters,
          ),
      metadataTabBuilder:
          (_) => PivotMetadataPane(files: pivotTable.source.files, bloc: bloc),
    );
  }

  Widget _imageSlideMenu(ImageSlide imageSlide) {
    final bloc = widget.imageSlideBlocBuilder(imageSlide);
    return TabbedMenu(
      editTabBuilder:
          (_) => ImageSlideEditPane(
            title: imageSlide.title,
            parameters: imageSlide.parameters,
            bloc: bloc,
          ),
      metadataTabBuilder:
          (_) => SlideMetadataPane(
            identifier: imageSlide.identifier,
            creationDate: imageSlide.creationDate,
            preview: imageSlide.preview,
            category: imageSlide.category,
          ),
    );
  }
}

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
  Future<void> Function()? deleteSlide;

  SlideshowEditorMenu({
    super.key,
    this.slide,
    required this.imageSlideBlocBuilder,
    required this.pivotTableBlocBuilder,
    this.deleteSlide,
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
      child:
          widget.slide == null
              ? SizedBox.shrink()
              : (widget.slide is PivotTable
                  ? _pivotTableMenu(widget.slide as PivotTable)
                  : _imageSlideMenu(widget.slide as ImageSlide)),
    );
  }

  Widget _pivotTableMenu(PivotTable pivotTable) {
    final bloc = widget.pivotTableBlocBuilder(pivotTable);
    return TabbedMenu(
      editPane: PivotTableEditPane(
        title: pivotTable.title,
        bloc: bloc,
        filters: pivotTable.filters,
        deleteSlide: widget.deleteSlide,
      ),
      metadataPane: PivotMetadataPane(
        files: pivotTable.source.files,
        bloc: bloc,
      ),
    );
  }

  Widget _imageSlideMenu(ImageSlide imageSlide) {
    final bloc = widget.imageSlideBlocBuilder(imageSlide);
    return TabbedMenu(
      editPane: ImageSlideEditPane(
        title: imageSlide.title,
        parameters: imageSlide.parameters,
        bloc: bloc,
        deleteSlide: widget.deleteSlide,
      ),
      metadataPane: SlideMetadataPane(
        identifier: imageSlide.identifier,
        creationDate: imageSlide.creationDate,
        preview: imageSlide.preview,
        category: imageSlide.category,
      ),
    );
  }
}

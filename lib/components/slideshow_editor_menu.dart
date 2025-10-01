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
    required this.child,
    this.slide,
    required this.portalController,
    required this.animationController,
    required this.imageSlideBlocBuilder,
    required this.pivotTableBlocBuilder,
    required this.closeSlideMenu,
  });

  Widget child;
  Slide? slide;
  OverlayPortalController portalController;
  AnimationController animationController;
  ImageSlideBloc Function(ImageSlide) imageSlideBlocBuilder;
  PivotTableBloc Function(PivotTable) pivotTableBlocBuilder;
  void Function() closeSlideMenu;

  @override
  State<SlideshowEditorMenu> createState() => _SlideshowEditorMenuState();
}

class _SlideshowEditorMenuState extends State<SlideshowEditorMenu> {
  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: widget.portalController,
      overlayChildBuilder: (context) {
        if (widget.slide == null) return const SizedBox();

        final portalOpacityAnimation = Tween(
          begin: 0.toDouble(),
          end: 0.5,
        ).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Curves.easeInOut,
          ),
        );
        final portalOffsetAnimation = Tween(
          begin: -MENU_WIDTH,
          end: 0.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Curves.easeInOut,
          ),
        );

        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.closeSlideMenu,
                    child: Opacity(
                      opacity: portalOpacityAnimation.value,
                      child: Container(color: Colors.black54),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  width: MENU_WIDTH,
                  right: portalOffsetAnimation.value,
                  child: child ?? SizedBox.shrink(),
                ),
              ],
            );
          },
          child: Material(
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
          ),
        );
      },
      child: widget.child,
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

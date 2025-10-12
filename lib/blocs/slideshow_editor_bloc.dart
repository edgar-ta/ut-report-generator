import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/pivot_table/create_pivot_table.dart'
    as pivot_table_api;
import 'package:ut_report_generator/blocs/bloc.dart';
import 'package:ut_report_generator/components/slideshow_editor/add_slide_dialog/entry.dart';
import 'package:ut_report_generator/components/slideshow_editor/add_slide_dialog/widget.dart';
import 'package:ut_report_generator/components/slideshow_editor/file_selector/widget.dart';
import 'package:ut_report_generator/components/slideshow_editor/image_slide_previews/cover_page_preview.dart';
import 'package:ut_report_generator/components/slideshow_editor/image_slide_previews/image_left_preview.dart';
import 'package:ut_report_generator/components/slideshow_editor/image_slide_previews/title_and_content_preview.dart';
import 'package:ut_report_generator/models/image_slide/image_slide_kind.dart';
import 'package:ut_report_generator/models/image_slide/self.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/api/slideshow/self.dart' as report_api;
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/models/slide_category.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/image_slide_section/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/pivot_table_section/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/slide_frame.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/state.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';

class SlideshowEditorBloc extends Bloc<SlideshowEditorState> {
  SlideshowEditorBloc({
    required super.initialState,
    required super.setInitialState,
  });

  void _setSlideshow(Slideshow Function(Slideshow) callback) {
    setInitialState(
      (state) => state.copyWith(
        slideshow: callback(state.slideshow!),
        openSlideIdentifier: state.openSlideIdentifier,
      ),
    );
  }

  Slideshow get _initialSlideshow => initialState.slideshow!;

  Future<void> rename(String name) async {
    _setSlideshow((report) => report.copyWith(reportName: name));
    await report_api.renameReport(
      report: _initialSlideshow.identifier,
      name: name,
    );
  }

  void openSlideMenu(Slide slide) {
    setInitialState((state) {
      return state.copyWith(
        openSlideIdentifier: slide.identifier,
        slideshow: state.slideshow,
      );
    });
  }

  void closeSlideMenu() {
    setInitialState((state) {
      return state.copyWith(
        openSlideIdentifier: null,
        slideshow: state.slideshow,
      );
    });
  }

  List<Slide> get visibleSlides =>
      _initialSlideshow.slides.where((slide) {
        if (_initialSlideshow.visualizationMode == VisualizationMode.asReport) {
          return true;
        }
        return slide is PivotTable;
      }).toList();

  Widget buildSlideFrame(int index) {
    final slide = visibleSlides[index];
    if (slide is PivotTable) {
      return SlideFrame(
        key: ValueKey(slide.identifier),
        isMenuOpen: initialState.openSlideIdentifier != null,
        openMenu: () => openSlideMenu(slide),
        child: PivotTableSection(data: slide.data, chartName: slide.title),
      );
    }
    if (slide is ImageSlide) {
      return SlideFrame(
        key: ValueKey(slide.identifier),
        isMenuOpen: initialState.openSlideIdentifier != null,
        openMenu: () => openSlideMenu(slide),
        child: ImageSlideSection(initialSlide: slide),
      );
    }
    return Placeholder(child: Text("Tipo de slide inválido"));
  }

  Future<void> toggleSlideshowMode() async {
    if (initialState.slideshow!.visualizationMode ==
        VisualizationMode.asReport) {
      setInitialState((state) {
        for (var i = 0; i < state.slideshow!.slides.length; i++) {
          if (state.slideshow!.slides[i].category == SlideCategory.imageSlide) {
            state.visibleSlidesListKey.currentState!.removeItem(i, (
              context,
              animation,
            ) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, widget) {
                  return Opacity(opacity: animation.value, child: widget);
                },
                child: buildSlideFrame(i),
              );
            });
          }
        }
        return state.copyWith(
          slideshow: state.slideshow!.copyWith(
            visualizationMode: VisualizationMode.chartsOnly,
          ),
          openSlideIdentifier: state.openSlideIdentifier,
        );
      });
    } else {
      setInitialState((state) {
        for (var i = 0; i < state.slideshow!.slides.length; i++) {
          final slide = state.slideshow!.slides[i];
          if (slide.category == SlideCategory.imageSlide) {
            state.visibleSlidesListKey.currentState?.insertItem(i);
          }
        }
        return state.copyWith(
          slideshow: state.slideshow!.copyWith(
            visualizationMode: VisualizationMode.asReport,
          ),
          openSlideIdentifier: state.openSlideIdentifier,
        );
      });
    }

    await report_api.toggleModeOfSlideshow(
      report: _initialSlideshow.identifier,
    );
  }

  Future<void> addPivotTable({
    required List<String> files,
    required ScrollController controller,
  }) async {
    await pivot_table_api
        .createPivotTable(
          report: _initialSlideshow.identifier,
          dataFiles: files,
        )
        .then((value) {
          _setSlideshow(
            (report) =>
                report.copyWith(slides: copyWithAdded(report.slides, value)),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.hasClients) {
              controller.animateTo(
                controller.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          });
        });
  }

  List<String> _getRecentFiles() {
    var pivotTables =
        initialState.slideshow!.slides.whereType<PivotTable>().toList();
    pivotTables.sort(
      (first, second) => first.creationDate.compareTo(second.creationDate),
    );
    var uniqueFiles =
        pivotTables
            .map((pivotTable) => pivotTable.source.files)
            .expand((files) => files)
            .toSet()
            .toList();
    return uniqueFiles;
  }

  void openAddPivotTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        var recentFiles = _getRecentFiles();

        return FileSelector(
          initialFiles: recentFiles,
          defaultSelection: [],
          legend: null,
          onFilesSelected: (List<String> files) async {
            await addPivotTable(
              files: files,
              controller: initialState.scrollController,
            );
          },
        );
      },
    );
  }

  Future<void> openAddSlideDialog(BuildContext context) async {
    if (initialState.slideshow!.visualizationMode ==
        VisualizationMode.chartsOnly) {
      openAddPivotTableDialog(context);
      return;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AddSlideDialog(
            entries: [
              AddSlideEntry(
                kind: ImageSlideKind.coverPage,
                title: "Portada",
                preview: const CoverPagePreview(),
              ),
              AddSlideEntry(
                kind: ImageSlideKind.titleAndContent,
                title: "Título y texto",
                preview: const TitleAndContentPreview(),
              ),
              AddSlideEntry(
                kind: ImageSlideKind.imageLeft,
                title: "Imagen izquierda",
                preview: const ImageLeftPreview(),
              ),
            ],
          );
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/pivot_table/create_pivot_table.dart'
    as pivot_table_api;
import 'package:ut_report_generator/blocs/bloc.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/api/report/self.dart' as report_api;
import 'package:ut_report_generator/models/report/visualization_mode.dart';
import 'package:ut_report_generator/models/slide_category.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/state.dart';
import 'package:ut_report_generator/utils/copy_with_added.dart';

class SlideshowEditorBloc extends Bloc<SlideshowEditorState> {
  SlideshowEditorBloc({required super.initialState, required super.setState});

  void _setSlideshow(Slideshow Function(Slideshow) callback) {
    setState((state) => state.copyWith(slideshow: callback(state.slideshow!)));
  }

  Slideshow get _initialSlideshow => initialState.slideshow!;

  Future<void> rename(String name) async {
    _setSlideshow((report) => report.copyWith(reportName: name));
    await report_api.renameReport(
      report: _initialSlideshow.identifier,
      name: name,
    );
  }

  Future<void> toggleSlideshowMode() async {
    print("Hello world!");
    if (initialState.slideshow!.visualizationMode ==
        VisualizationMode.asReport) {
      setState((state) {
        for (var i = 0; i < state.slideshow!.slides.length; i++) {
          if (state.slideshow!.slides[i].category == SlideCategory.imageSlide) {
            state.visibleSlidesListKey.currentState!.removeItem(i, (
              context,
              animation,
            ) {
              return Text("fsfs");
            });
          }
        }
        print("fjsdklfsd");
        return state.copyWith(
          slideshow: state.slideshow!.copyWith(
            visualizationMode: VisualizationMode.chartsOnly,
          ),
          visibleSlides:
              state.visibleSlides
                  .where((slide) => slide.category == SlideCategory.pivotTable)
                  .toList(),
        );
      });
    } else {
      setState((state) {
        for (var i = 0; i < state.slideshow!.slides.length; i++) {
          final slide = state.slideshow!.slides[i];
          if (slide.category == SlideCategory.imageSlide) {
            state.visibleSlidesListKey.currentState!.insertItem(i);
          }
        }
        return state.copyWith(
          slideshow: state.slideshow!.copyWith(
            visualizationMode: VisualizationMode.asReport,
          ),
          visibleSlides: state.slideshow!.slides,
        );
      });
    }

    await report_api.toggleModeOfReport(report: _initialSlideshow.identifier);
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
}

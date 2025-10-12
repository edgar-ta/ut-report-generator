import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/components/slideshow_editor/app_subscaffold.dart';
import 'package:ut_report_generator/components/slideshow_editor/empty_slideshow_placeholder.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/entry.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box_list.dart';
import 'package:ut_report_generator/components/slideshow_editor/slideshow_editor_fab/widget.dart';
import 'package:ut_report_generator/components/slideshow_editor/slideshow_editor_menu.dart';
import 'package:ut_report_generator/components/slideshow_editor/slideshow_header.dart';
import 'package:ut_report_generator/blocs/image_slide_bloc.dart';
import 'package:ut_report_generator/blocs/pivot_table_bloc.dart';
import 'package:ut_report_generator/blocs/slideshow_editor_bloc.dart';
import 'package:ut_report_generator/components/slideshow_editor/file_selector/widget.dart';
import 'package:ut_report_generator/models/pivot_table/self.dart';
import 'package:ut_report_generator/models/report/self.dart';
import 'package:ut_report_generator/components/util/common_appbar.dart';
import 'package:ut_report_generator/models/slide/self.dart';
import 'package:ut_report_generator/components/slideshow_editor/export_box/widget.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/slide/shimmer_slide.dart';
import 'package:ut_report_generator/pages/home/slideshow_editor/state.dart';
import 'package:ut_report_generator/scaffold_controller.dart';
import 'package:ut_report_generator/utils/design_constants.dart';
import 'package:ut_report_generator/utils/future_status.dart';
import 'package:ut_report_generator/utils/wait_at_least.dart';
import 'package:ut_report_generator/api/slideshow/self.dart' as slideshow_api;
import 'package:ut_report_generator/api/slide/self.dart' as slide_api;

class SlideshowEditor extends StatefulWidget {
  final Future<Slideshow> Function() slideshowCallback;
  final Future<void> Function() callbackWhenReturning;

  SlideshowEditor({
    super.key,
    required this.slideshowCallback,
    required this.callbackWhenReturning,
  });

  @override
  State<SlideshowEditor> createState() => _SlideshowEditorState();
}

class _SlideshowEditorState extends State<SlideshowEditor>
    with SingleTickerProviderStateMixin {
  late SlideshowEditorState state;

  @override
  void initState() {
    super.initState();
    state = SlideshowEditorState(
      scrollController: ScrollController(),
      openSlideIdentifier: null,
      exports: [],
      exportsListKey: GlobalKey<AnimatedListState>(),
      visibleSlidesListKey: GlobalKey<AnimatedListState>(),
      slideshow: null,
      status: FutureStatus.pending,
    );

    _loadReport();
  }

  Future<void> _loadReport() async {
    return waitAtLeast(Duration(seconds: 1), widget.slideshowCallback())
        .then((report) {
          setState(() {
            state = state.copyWith(
              status: FutureStatus.success,
              slideshow: report,
              openSlideIdentifier: state.openSlideIdentifier,
            );
          });
          context.read<ScaffoldController>().setAppBarBuilder(
            _slideshowEditorAppBar,
          );
        })
        .catchError((_) {
          setState(() {
            state = state.copyWith(
              status: FutureStatus.error,
              slideshow: state.slideshow,
              openSlideIdentifier: state.openSlideIdentifier,
            );
          });
        });
  }

  void _compileReport() {
    setState(() {
      final identifier = DateTime.now().toIso8601String();
      state.exportsListKey.currentState!.insertItem(0);
      state.exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return slideshow_api.compileSlideshow(
              report: state.slideshow!.identifier,
            );
          }),
          setState: (callback) {
            setState(() {
              final index = state.exports.indexWhere(
                (export) => export.identifier == identifier,
              );
              state.exports[index] = callback();
            });
          },
          status: FutureStatus.pending,
        ),
      );
    });
  }

  void _exportSlideshow() {
    setState(() {
      final identifier = DateTime.now().toIso8601String();
      state.exportsListKey.currentState!.insertItem(state.exports.length);
      state.exports.add(
        ExportBoxEntry(
          identifier: identifier,
          process: Future.delayed(Duration(seconds: 2), () {
            return slideshow_api.exportSlideshow(
              report: state.slideshow!.identifier,
            );
          }),
          setState: (callback) {
            setState(() {
              final index = state.exports.indexWhere(
                (export) => export.identifier == identifier,
              );
              state.exports[index] = callback();
            });
          },
          status: FutureStatus.pending,
        ),
      );
    });
  }

  void _deleteSlideshow() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar presentación"),
          content: Text(
            "¿Estás seguro de querer eliminar esta presentación? Esta acción no es reversible; todos tus datos se perderán",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await slideshow_api
                    .deleteSlideshow(slideshow: state.slideshow!.identifier)
                    .then((_) {
                      _returnToHome();
                    });
              },
              child: Text("Sí"),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _slideshowEditorAppBar(BuildContext context) {
    return CommonAppbar(
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          tooltip: "Más opciones",
          onSelected: (value) {
            if (value == "pptx") {
              _compileReport();
            }
            if (value == "zip") {
              _exportSlideshow();
            }
            if (value == "delete") {
              _deleteSlideshow();
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "pptx",
                  child: ListTile(
                    leading: Icon(Icons.slideshow),
                    title: Text('Exportar PPTX'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "zip",
                  child: ListTile(
                    leading: Icon(Icons.archive),
                    title: Text('Exportar ZIP'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "delete",
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("Eliminar presentación"),
                  ),
                ),
              ],
        ),
      ],
      leading: IconButton(
        onPressed: _returnToHome,
        icon: Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Future<void> _returnToHome() async {
    context.read<ScaffoldController>()
      ..setAppBarBuilder(null)
      ..setFabBuilder(null);
    context.pop();
    await widget.callbackWhenReturning();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: state.status == FutureStatus.pending ? 1 : 0,
          duration: Duration(milliseconds: 250),
          child: _loadingState(),
        ),
        AnimatedOpacity(
          opacity:
              state.status == FutureStatus.success ||
                      state.status == FutureStatus.error
                  ? 1
                  : 0,
          duration: Duration(milliseconds: 250),
          child:
              state.status == FutureStatus.pending
                  ? SizedBox.shrink()
                  : (state.status == FutureStatus.success
                      ? _successState()
                      : _errorState()),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Text(key: ValueKey('error'), "Algo salió mal");
  }

  Widget _loadingState() {
    return ShimmerSlide(key: ValueKey('loading'));
  }

  Widget _successState() {
    final slideshowBloc = SlideshowEditorBloc(
      initialState: state,
      setInitialState: (callback) {
        setState(() {
          state = callback(state);
        });
      },
    );

    return AppSubscaffold(
      key: ValueKey('success'),
      isMenuOpen: state.openSlideIdentifier != null,
      bloc: slideshowBloc,
      menu: _buildEditorMenu(),
      child: _buildEditorContent(slideshowBloc),
    );
  }

  Widget _buildEditorMenu() {
    Slide? openSlide;
    for (final slide in state.slideshow!.slides) {
      if (slide.identifier == state.openSlideIdentifier) {
        openSlide = slide;
        break;
      }
    }

    return SlideshowEditorMenu(
      slide: openSlide,
      deleteSlide: () async => _openDeleteSlideDialog(openSlide!),
      imageSlideBlocBuilder:
          (imageSlide) => ImageSlideBloc(
            slideshow: state.slideshow!.identifier,
            initialSlide: imageSlide,
            setSlide: (callback) {
              _setSlide(imageSlide.identifier, callback);
            },
          ),
      pivotTableBlocBuilder:
          (pivotTable) => PivotTableBloc(
            slideshow: state.slideshow!.identifier,
            initialSlide: pivotTable,
            setSlide: (callback) {
              _setSlide(pivotTable.identifier, callback);
            },
          ),
    );
  }

  void _openDeleteSlideDialog(Slide slide) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar diapositiva"),
          content: Text(
            "¿Estás seguro de querer borrar esta diapositiva? Esta acción no se puede revertir; tus cambios se perderán",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteSlide(slide);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSlide(Slide slide) async {
    setState(() {
      final index = state.slideshow!.slides.indexWhere(
        (innerSlide) => innerSlide.identifier == slide.identifier,
      );

      final newSlides = [...state.slideshow!.slides];
      state.visibleSlidesListKey.currentState!.removeItem(index, (
        context,
        animation,
      ) {
        return Text("This slide is being removed");
      });
      newSlides.removeAt(index);

      state = state.copyWith(
        openSlideIdentifier: null,
        slideshow: state.slideshow!.copyWith(slides: newSlides),
      );
    });

    await slide_api.deleteSlide(
      slideshow: state.slideshow!.identifier,
      slide: slide.identifier,
    );
  }

  void _setSlide<T extends Slide>(String identifier, T Function(T) callback) {
    setState(() {
      final List<Slide> slides = [];
      for (final slide in state.slideshow!.slides) {
        if (slide.identifier == identifier) {
          slides.add(callback(slide as T));
        } else {
          slides.add(slide);
        }
      }
      state = state.copyWith(
        slideshow: state.slideshow!.copyWith(slides: slides),
        openSlideIdentifier: state.openSlideIdentifier,
      );
    });
  }

  void _removeExport(ExportBoxEntry entry) {
    setState(() {
      final innerIndex = state.exports.indexWhere(
        (innerEntry) => innerEntry.identifier == entry.identifier,
      );
      state.exportsListKey.currentState!.removeItem(innerIndex, (
        context,
        animation,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(opacity: animation.value, child: child);
          },
          child: ExportBox(entry: entry),
        );
      });
      state.exports.removeAt(innerIndex);
    });
  }

  void _retryExport(ExportBoxEntry entry) {
    //
  }

  Widget _buildEditorContent(SlideshowEditorBloc bloc) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: state.scrollController,
          child: Column(
            children: [
              SlideshowHeader(slideshow: state.slideshow!, bloc: bloc),
              if (bloc.visibleSlides.isEmpty)
                EmptySlideshowPlaceholder(
                  onCreatePressed: () {
                    bloc.openAddPivotTableDialog(context);
                  },
                ),
              if (bloc.visibleSlides.isNotEmpty)
                AnimatedList(
                  key: state.visibleSlidesListKey,
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, widget) {
                        return Opacity(opacity: animation.value, child: widget);
                      },
                      child: bloc.buildSlideFrame(index),
                    );
                  },
                  initialItemCount: bloc.visibleSlides.length,
                ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          bottom: 16,
          width: EXPORT_BOX_WIDTH,
          left: 16,
          child: ExportBoxList(
            exportsListKey: state.exportsListKey,
            exports: state.exports,
            removeExport: _removeExport,
            retryExport: _retryExport,
          ),
        ),
      ],
    );
  }
}

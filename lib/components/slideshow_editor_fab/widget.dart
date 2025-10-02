import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:ut_report_generator/blocs/slideshow_editor_bloc.dart';

class SlideshowEditorFab extends StatefulWidget {
  Future<void> Function() addPivotTable;
  Future<void> Function() addImageSlide;

  SlideshowEditorFab({
    super.key,
    required this.addPivotTable,
    required this.addImageSlide,
  });

  @override
  State<SlideshowEditorFab> createState() => _SlideshowEditorFabState();
}

class _SlideshowEditorFabState extends State<SlideshowEditorFab> {
  final key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: key,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        fabSize: ExpandableFabSize.regular,
        child: const Text(
          "Añadir",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
      ),
      type: ExpandableFabType.up,
      distance: 80, // distancia de los botones hijos al FAB principal
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(0.2), // fondo semitransparente
      ),
      childrenAnimation: ExpandableFabAnimation.none,
      children: [
        FloatingActionButton.small(
          heroTag: "add_pivot_table",
          onPressed: () async {
            key.currentState!.close();
            await widget.addPivotTable();
          },
          tooltip: "Tabla dinámica",
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.bar_chart),
              SizedBox(height: 2),
              Text("Tabla", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),

        // Botón para añadir Imagen
        FloatingActionButton.small(
          heroTag: "add_image",
          onPressed: () async {
            key.currentState!.close();
            await widget.addImageSlide();
          },
          tooltip: "Imagen",
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image),
              SizedBox(height: 2),
              Text("Imagen", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
    ;
  }
}

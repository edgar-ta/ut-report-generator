import 'package:flutter/material.dart';
import 'package:ut_report_generator/blocs/slideshow_editor_bloc.dart';
import 'package:ut_report_generator/utils/design_constants.dart';

class AppSubscaffold extends StatefulWidget {
  final bool isMenuOpen;
  final SlideshowEditorBloc bloc;
  final Widget? menu;
  final Widget? child;

  const AppSubscaffold({
    required this.isMenuOpen,
    required this.bloc,
    super.key,
    this.menu,
    this.child,
  });

  @override
  State<AppSubscaffold> createState() => _AppSubscaffoldState();
}

class _AppSubscaffoldState extends State<AppSubscaffold> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child ?? SizedBox.shrink()),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.isMenuOpen,
            child: AnimatedOpacity(
              opacity: widget.isMenuOpen ? 0.25 : 0,
              duration: Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: () {
                  if (widget.isMenuOpen) {
                    widget.bloc.closeSlideMenu();
                  }
                },
                child: Container(color: Colors.black54),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              widget.bloc.openAddSlideDialog(context);
            },
            child: Icon(Icons.add),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          top: 0,
          bottom: 0,
          width: MENU_WIDTH,
          right: widget.isMenuOpen ? 0 : -MENU_WIDTH,
          child: IgnorePointer(
            ignoring: !widget.isMenuOpen,
            child: widget.menu ?? SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

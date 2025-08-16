import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ut_report_generator/api/hello.dart';
import 'package:ut_report_generator/bugs/_main.dart';
import 'package:ut_report_generator/components/footer_component.dart';
import 'package:ut_report_generator/components/header_component.dart';
import 'package:ut_report_generator/components/fullscreen_loading_overlay/widget.dart';
import 'package:ut_report_generator/home/_main.dart';
import 'package:ut_report_generator/main_app.dart';
import 'package:ut_report_generator/profile/_main.dart';
import 'package:ut_report_generator/scaffold_controller.dart';

class AppScaffold extends StatefulWidget {
  StatefulNavigationShell child;

  AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    final fab = context.watch<ScaffoldController>().fab;
    final appBarBuilder = context.watch<ScaffoldController>().appBarBuilder;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Scaffold(
            floatingActionButton: fab,
            appBar:
                appBarBuilder?.call(context) ??
                AppBar(
                  title: Text(
                    "Generador de reportes de la UTSJR",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(45, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  centerTitle: true,
                ),
            body: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      NavigationRail(
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.house),
                            label: Text("Inicio"),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            label: Text("Perfil"),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.bug_report),
                            label: Text("Reportar errores"),
                          ),
                        ],
                        selectedIndex: widget.child.currentIndex,
                        onDestinationSelected: (index) {
                          widget.child.goBranch(index);
                        },
                      ),
                      VerticalDivider(thickness: 1, width: 1),
                      Expanded(child: Center(child: widget.child)),
                    ],
                  ),
                ),
                FooterComponent(),
              ],
            ),
          ),
        ),
        Positioned(top: 0, left: 0, right: 0, child: HeaderComponent()),
      ],
    );
  }
}

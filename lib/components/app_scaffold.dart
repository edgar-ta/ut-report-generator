import 'package:flutter/material.dart';
import 'package:ut_report_generator/api/verify_connection.dart';
import 'package:ut_report_generator/bugs/_main.dart';
import 'package:ut_report_generator/components/footer_component.dart';
import 'package:ut_report_generator/components/header_component.dart';
import 'package:ut_report_generator/components/server_connection_loader/widget.dart';
import 'package:ut_report_generator/home/_main.dart';
import 'package:ut_report_generator/main_app.dart';
import 'package:ut_report_generator/profile/_main.dart';

class AppScaffold extends StatefulWidget {
  Future<bool> Function(int)? allowNewDestination;
  bool verifyConnection;
  Widget? child;

  AppScaffold({
    super.key,
    this.allowNewDestination,
    this.child,
    this.verifyConnection = false,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget getWidgetToRender(VerifyConnection_Response? response) {
      if (widget.child != null) {
        return widget.child!;
      }
      switch (selectedIndex) {
        case 0:
          return HomePage(message: response?.message);
        case 1:
          return ProfilePage();
        default:
          return BugReportPage();
      }
    }

    return MaterialApp(
      title: "UT Report Generator",
      home: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Scaffold(
              appBar: AppBar(
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
                              label: Text("Cuenta"),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.bug_report),
                              label: Text("Reportar errores"),
                            ),
                          ],
                          selectedIndex: selectedIndex,
                          onDestinationSelected: (value) async {
                            var isAllowed = true;
                            if (widget.allowNewDestination != null) {
                              isAllowed = await widget.allowNewDestination!(
                                value,
                              );
                            }

                            if (isAllowed) {
                              setState(() {
                                selectedIndex = value;
                              });
                            }
                          },
                        ),
                        VerticalDivider(thickness: 1, width: 1),
                        Expanded(
                          child: Center(
                            child:
                                widget.verifyConnection
                                    ? ServerConnectionLoader(
                                      builder: getWidgetToRender,
                                    )
                                    : getWidgetToRender(null),
                          ),
                        ),
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
      ),
    );
  }
}

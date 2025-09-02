import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 32,
        children: [
          Column(
            children: [
              Text("(×_×)", style: TextStyle(color: Colors.red, fontSize: 128)),
              Text(
                "Error al conectar con el servidor. ${serverExecutable()}",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

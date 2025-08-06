import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  void Function()? retry;
  ErrorPage({super.key, this.retry});

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
                "Error al conectar con el servidor.",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              retry?.call();
            },
            label: Text("Reintentar"),
            icon: Icon(Icons.refresh, color: Colors.white),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

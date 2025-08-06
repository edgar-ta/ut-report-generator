import 'dart:async';

import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  List<String> messages = [
    "Conectando con el servidor...",
    "Esperando respuesta...",
    "Verificando conexión...",
    "Casi listo...",
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _startMessageCycling();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _startMessageCycling() {
    _messageTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % messages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Conectando al servidor",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(strokeWidth: 8),
          ),
          const SizedBox(height: 24),
          Text(
            messages[_currentMessageIndex],
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

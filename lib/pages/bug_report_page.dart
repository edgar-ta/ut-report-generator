import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({Key? key}) : super(key: key);

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  final List<File> _images = [];
  final picker = ImagePicker();

  bool isError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Timer? _resetErrorTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24)
      .chain(CurveTween(curve: Curves.elasticIn))
      .animate(_shakeController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Reset back to 0 offset so text is aligned after shake
        _shakeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _resetErrorTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      setState(() {
        isError = true;
      });
      _shakeController.forward(from: 0);

      _resetErrorTimer?.cancel();
      _resetErrorTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            isError = false;
          });
        }
      });

      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
        isError = false;
        _resetErrorTimer?.cancel();
      });
    }
  }

  Future<void> _sendReport() async {
    if (!_formKey.currentState!.validate()) return;

    final imagesBase64 =
        _images.map((file) => base64Encode(file.readAsBytesSync())).toList();

    final payload = {
      "name": _nameController.text,
      "title": _titleController.text,
      "body": _bodyController.text,
      "images": imagesBase64,
    };

    try {
      final response = await http.post(
        Uri.parse("https://example.com/api/bug-report"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reporte enviado con éxito")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporte de Bugs")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título"),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 5,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),

              // Leyenda de imágenes
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeAnimation.value;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          opacity: isError ? 0 : 1,
                          duration: Duration(milliseconds: 200),
                          child: Text("${_images.length}/3 imágenes"),
                        ),
                        AnimatedOpacity(
                          opacity: isError ? 1 : 0,
                          duration: Duration(milliseconds: 100),
                          child: Text(
                            "No se puede escoger más imágenes",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Lista de imágenes con botón de eliminar
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo),
                      ),
                    ),
                    ..._images.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            child: Image.file(file, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const Spacer(),

              Center(
                child: ElevatedButton(
                  onPressed: _sendReport,
                  child: const Text("Enviar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

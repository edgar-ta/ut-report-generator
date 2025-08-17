import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ut_report_generator/api/types/profile_record.dart';

String labelForUserType(UserType t) => switch (t) {
  UserType.professor => 'Profesor',
  UserType.tutor => 'Tutor',
  UserType.dean => 'Director',
};

String labelForGender(UserGender g) => switch (g) {
  UserGender.masculine => 'Masculino',
  UserGender.feminine => 'Femenino',
  UserGender.other => 'Otro',
};

IconData iconForUserType(UserType t) => switch (t) {
  UserType.professor => Icons.school,
  UserType.tutor => Icons.supervisor_account,
  UserType.dean => Icons.manage_accounts,
};

IconData iconForGender(UserGender g) => switch (g) {
  UserGender.masculine => Icons.male,
  UserGender.feminine => Icons.female,
  UserGender.other => Icons.transgender,
};

// ===== Page =====
class ProfilePage extends StatefulWidget {
  final ProfileRecord initialProfile;

  const ProfilePage({super.key, required this.initialProfile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late ProfileRecord _baseline; // último perfil confirmado por el backend

  // Valores de edición actuales (UI state)
  late UserType _userType;
  late UserGender _gender;
  bool _dirty = false; // indica si hay cambios sin guardar
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _baseline = widget.initialProfile;
    _nameController = TextEditingController(text: _baseline.name)
      ..addListener(_onAnyFieldChanged);
    _userType = _baseline.type;
    _gender = _baseline.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Construye un ProfileRecord a partir de los valores de la UI
  ProfileRecord get _current => ProfileRecord(
    name: _nameController.text.trim(),
    type: _userType,
    gender: _gender,
  );

  void _onAnyFieldChanged() {
    final changed = _current != _baseline;
    if (changed != _dirty) {
      setState(() => _dirty = changed);
    }
  }

  Future<void> _updateProfile() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final payload = _current.toJson();

    try {
      // TODO: Reemplaza por tu endpoint real
      final resp = await http.put(
        Uri.parse('https://example.com/api/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // Opcional: si tu API regresa el perfil "oficial",
        // usa ese JSON para fijar el baseline.
        // final serverProfile = ProfileRecord.fromJson(jsonDecode(resp.body));
        // setState(() { _baseline = serverProfile; _onAnyFieldChanged(); });

        setState(() {
          _baseline = _current; // confirmamos cambios como baseline
          _onAnyFieldChanged(); // recalcula _dirty (debe quedar en false)
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ${resp.statusCode}: no se pudo actualizar'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textInputAction: TextInputAction.next,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu nombre'
                          : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<UserType>(
              value: _userType,
              decoration: const InputDecoration(labelText: 'Tipo de usuario'),
              items:
                  UserType.values
                      .map(
                        (t) => DropdownMenuItem<UserType>(
                          value: t,
                          child: Row(
                            children: [
                              Icon(iconForUserType(t)),
                              const SizedBox(width: 8),
                              Text(labelForUserType(t)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => _userType = val);
                _onAnyFieldChanged();
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<UserGender>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Género'),
              items:
                  UserGender.values
                      .map(
                        (g) => DropdownMenuItem<UserGender>(
                          value: g,
                          child: Row(
                            children: [
                              Icon(iconForGender(g)),
                              const SizedBox(width: 8),
                              Text(labelForGender(g)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => _gender = val);
                _onAnyFieldChanged();
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _dirty && !_saving ? _updateProfile : null,
                icon:
                    _saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: const Text('Actualizar datos'),
              ),
            ),

            if (_dirty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Tienes cambios sin guardar',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

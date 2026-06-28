import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../ui/widgets.dart';

const _roles = {'Barber': 'Barbero/Peluquero', 'Reception': 'Recepción', 'Admin': 'Administrador'};

class EmployeeFormPage extends ConsumerStatefulWidget {
  const EmployeeFormPage({super.key});

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'Barber';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.length < 8) {
      setState(() => _error = 'Nombre, apellido, email y contraseña (≥8) son obligatorios.');
      return;
    }
    setState(() { _busy = true; _error = null; });

    try {
      await ref.read(apiProvider).createEmployee({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'role': _role,
        'colorHex': '#C8A24B',
      });
      if (mounted) context.pop();
    } catch (e) {
      setState(() { _busy = false; _error = 'No se pudo crear. ($e)'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo empleado')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SurfaceCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 12),
                  TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Apellido')),
                  const SizedBox(height: 12),
                  TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  TextField(controller: _password, decoration: const InputDecoration(labelText: 'Contraseña (mín. 8)'), obscureText: true),
                  const SizedBox(height: 12),
                  LabeledDropdown<String>(
                    label: 'Rol',
                    value: _role,
                    items: [for (final e in _roles.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                    onChanged: (v) => setState(() => _role = v ?? 'Barber'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: t.dangerFg, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: AppButton(label: 'Cancelar', variant: AppButtonVariant.secondary, expand: true, onPressed: _busy ? null : () => context.pop())),
                    const SizedBox(width: 12),
                    Expanded(child: AppButton(label: 'Crear', expand: true, loading: _busy, onPressed: _busy ? null : _save)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

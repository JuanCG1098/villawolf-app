import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  const ClientFormPage({super.key, this.client});

  final ClientModel? client;

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _notes;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.client != null;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _firstName = TextEditingController(text: c?.firstName ?? '');
    _lastName = TextEditingController(text: c?.lastName ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      setState(() => _error = 'Nombre y apellido son obligatorios.');
      return;
    }
    setState(() { _busy = true; _error = null; });

    final body = {
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    };

    try {
      final api = ref.read(apiProvider);
      if (_isEdit) {
        await api.updateClient(widget.client!.id, body);
      } else {
        await api.createClient(body);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() { _busy = false; _error = 'No se pudo guardar. ($e)'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar cliente' : 'Nuevo cliente')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: PanelCard(
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
                  TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Observaciones'), maxLines: 3),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _busy ? null : () => context.pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy ? null : _save,
                          child: _busy
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
                              : const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

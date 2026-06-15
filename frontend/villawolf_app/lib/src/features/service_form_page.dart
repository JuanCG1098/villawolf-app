import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _categoriesProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listCategories());

const _audiences = {'Male': 'Hombre', 'Female': 'Mujer', 'Unisex': 'Unisex'};

class ServiceFormPage extends ConsumerStatefulWidget {
  const ServiceFormPage({super.key, this.service});

  final ServiceModel? service;

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _duration;
  late final TextEditingController _price;
  String? _categoryId;
  String _audience = 'Unisex';
  bool _requiresPrep = false;
  bool _allowsAddons = true;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _name = TextEditingController(text: s?.name ?? '');
    _description = TextEditingController(text: s?.description ?? '');
    _duration = TextEditingController(text: s?.durationMinutes.toString() ?? '30');
    _price = TextEditingController(text: s?.basePrice.toString() ?? '0');
    _categoryId = s?.categoryId;
    _audience = s?.targetAudience ?? 'Unisex';
    _requiresPrep = s?.requiresPreparation ?? false;
    _allowsAddons = s?.allowsAddons ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _duration.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final duration = int.tryParse(_duration.text.trim());
    final price = num.tryParse(_price.text.trim());
    if (_name.text.trim().isEmpty || _categoryId == null || duration == null || duration <= 0 || price == null || price < 0) {
      setState(() => _error = 'Completá nombre, categoría, una duración válida (>0) y un precio (≥0).');
      return;
    }
    setState(() { _busy = true; _error = null; });

    final body = {
      'name': _name.text.trim(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'durationMinutes': duration,
      'basePrice': price,
      'categoryId': _categoryId,
      'targetAudience': _audience,
      'requiresPreparation': _requiresPrep,
      'allowsAddons': _allowsAddons,
    };

    try {
      final api = ref.read(apiProvider);
      if (_isEdit) {
        await api.updateService(widget.service!.id, body);
      } else {
        await api.createService(body);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() { _busy = false; _error = 'No se pudo guardar. ($e)'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(_categoriesProvider).valueOrNull ?? const <CategoryModel>[];

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar servicio' : 'Nuevo servicio')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: PanelCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 12),
                  TextField(controller: _description, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextField(controller: _duration, decoration: const InputDecoration(labelText: 'Duración (min)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _price, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 12),
                  LabeledDropdown<String>(
                    label: 'Categoría',
                    value: _categoryId,
                    items: [for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name))],
                    onChanged: (v) => setState(() => _categoryId = v),
                  ),
                  const SizedBox(height: 12),
                  LabeledDropdown<String>(
                    label: 'Público',
                    value: _audience,
                    items: [for (final e in _audiences.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                    onChanged: (v) => setState(() => _audience = v ?? 'Unisex'),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Requiere preparación', style: TextStyle(color: AppColors.onInk, fontSize: 14)),
                    value: _requiresPrep,
                    onChanged: (v) => setState(() => _requiresPrep = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Permite adicionales', style: TextStyle(color: AppColors.onInk, fontSize: 14)),
                    value: _allowsAddons,
                    onChanged: (v) => setState(() => _allowsAddons = v),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: _busy ? null : () => context.pop(), child: const Text('Cancelar'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy ? null : _save,
                        child: _busy
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
                            : const Text('Guardar'),
                      ),
                    ),
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

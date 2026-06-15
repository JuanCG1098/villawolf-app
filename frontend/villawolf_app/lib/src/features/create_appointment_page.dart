import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _clientsProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listClients());
final _servicesProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listServices());
final _employeesProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listEmployees());

class CreateAppointmentPage extends ConsumerStatefulWidget {
  const CreateAppointmentPage({super.key});

  @override
  ConsumerState<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends ConsumerState<CreateAppointmentPage> {
  String? _clientId;
  String? _serviceId;
  String? _employeeId;
  late DateTime _date;
  List<FreeSlotModel>? _slots;
  FreeSlotModel? _selectedSlot;
  bool _loadingSlots = false;
  bool _booking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  void _resetSlots() {
    setState(() {
      _slots = null;
      _selectedSlot = null;
    });
  }

  Future<void> _loadSlots() async {
    if (_employeeId == null || _serviceId == null) {
      setState(() => _error = 'Elegí profesional y servicio primero.');
      return;
    }
    setState(() { _loadingSlots = true; _error = null; _slots = null; _selectedSlot = null; });
    try {
      final slots = await ref.read(apiProvider).freeSlots(employeeId: _employeeId!, date: _date, serviceId: _serviceId);
      setState(() => _slots = slots);
    } catch (e) {
      setState(() => _error = 'No se pudieron obtener los horarios. ($e)');
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _book() async {
    if (_clientId == null || _serviceId == null || _employeeId == null || _selectedSlot == null) return;
    setState(() { _booking = true; _error = null; });
    try {
      await ref.read(apiProvider).createAppointment({
        'clientId': _clientId,
        'employeeId': _employeeId,
        'serviceId': _serviceId,
        'startUtc': _selectedSlot!.startUtc.toUtc().toIso8601String(),
        'bookingChannel': 'Web',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno reservado')));
        context.pop(true);
      }
    } catch (e) {
      setState(() { _booking = false; _error = 'No se pudo reservar. ($e)'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(_clientsProvider).valueOrNull ?? const <ClientModel>[];
    final services = ref.watch(_servicesProvider).valueOrNull ?? const <ServiceModel>[];
    final employees = ref.watch(_employeesProvider).valueOrNull ?? const <EmployeeModel>[];
    final canBook = _clientId != null && _serviceId != null && _employeeId != null && _selectedSlot != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo turno')),
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
                  _Dropdown(
                    label: 'Cliente',
                    value: _clientId,
                    items: [for (final c in clients) DropdownMenuItem(value: c.id, child: Text(c.fullName))],
                    onChanged: (v) => setState(() => _clientId = v),
                  ),
                  const SizedBox(height: 12),
                  _Dropdown(
                    label: 'Servicio',
                    value: _serviceId,
                    items: [
                      for (final s in services)
                        DropdownMenuItem(value: s.id, child: Text('${s.name} · ${s.durationMinutes}′'))
                    ],
                    onChanged: (v) { setState(() => _serviceId = v); _resetSlots(); },
                  ),
                  const SizedBox(height: 12),
                  _Dropdown(
                    label: 'Profesional',
                    value: _employeeId,
                    items: [for (final e in employees) DropdownMenuItem(value: e.id, child: Text(e.fullName))],
                    onChanged: (v) { setState(() => _employeeId = v); _resetSlots(); },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Fecha:', style: TextStyle(color: AppColors.muted)),
                      IconButton(
                        onPressed: () { setState(() => _date = _date.subtract(const Duration(days: 1))); _resetSlots(); },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(Formatters.date(_date), style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600)),
                      IconButton(
                        onPressed: () { setState(() => _date = _date.add(const Duration(days: 1))); _resetSlots(); },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _loadingSlots ? null : _loadSlots,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Ver horarios disponibles'),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingSlots)
                    const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                  else if (_slots != null)
                    _slots!.isEmpty
                        ? const Text('Sin horarios disponibles ese día.', style: TextStyle(color: AppColors.muted))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in _slots!)
                                _SlotChip(
                                  label: s.localStart,
                                  selected: identical(_selectedSlot, s),
                                  onTap: () => setState(() => _selectedSlot = s),
                                ),
                            ],
                          ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: (canBook && !_booking) ? _book : null,
                    child: _booking
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
                        : const Text('Reservar turno'),
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

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceAlt,
          hint: Text(label, style: const TextStyle(color: AppColors.muted)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.accent : AppColors.line),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.ink : AppColors.onInk,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

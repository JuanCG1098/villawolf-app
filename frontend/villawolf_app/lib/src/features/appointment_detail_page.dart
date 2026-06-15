import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

class AppointmentDetailPage extends ConsumerStatefulWidget {
  const AppointmentDetailPage({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  ConsumerState<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends ConsumerState<AppointmentDetailPage> {
  AppointmentDetailModel? _detail;
  String? _clientName;
  bool _loading = true;
  bool _acting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiProvider);
      final detail = await api.getAppointment(widget.appointmentId);
      String? clientName;
      try {
        clientName = (await api.getClient(detail.clientId)).fullName;
      } catch (_) {/* best effort */}
      if (mounted) setState(() { _detail = detail; _clientName = clientName; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'No se pudo cargar el turno. ($e)'; });
    }
  }

  Future<void> _run(String action) async {
    setState(() { _acting = true; _error = null; });
    try {
      final updated = await ref.read(apiProvider).appointmentAction(widget.appointmentId, action);
      if (mounted) setState(() { _detail = updated; _acting = false; });
    } catch (e) {
      if (mounted) setState(() { _acting = false; _error = 'No se pudo actualizar el estado. ($e)'; });
    }
  }

  List<Widget> _actionsFor(String status) {
    if (_acting) return [const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())];
    switch (status) {
      case 'Pending':
        return [
          FilledButton(onPressed: () => _run('confirm'), child: const Text('Confirmar')),
          OutlinedButton(onPressed: () => _run('cancel'), child: const Text('Cancelar')),
        ];
      case 'Confirmed':
        return [
          FilledButton(onPressed: () => _run('start'), child: const Text('Iniciar')),
          OutlinedButton(onPressed: () => _run('no-show'), child: const Text('No asistió')),
          OutlinedButton(onPressed: () => _run('cancel'), child: const Text('Cancelar')),
        ];
      case 'InProgress':
        return [FilledButton(onPressed: () => _run('complete'), child: const Text('Completar'))];
      default:
        return [const Text('Turno finalizado — sin acciones.', style: TextStyle(color: AppColors.muted))];
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    return Scaffold(
      appBar: AppBar(title: const Text('Turno')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : d == null
              ? Center(child: Text(_error ?? 'No encontrado', style: const TextStyle(color: AppColors.muted)))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: PanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(d.serviceName,
                                      style: const TextStyle(color: AppColors.onInk, fontSize: 18, fontWeight: FontWeight.w700)),
                                ),
                                StatusChip(status: d.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_clientName ?? 'Cliente', style: const TextStyle(color: AppColors.muted)),
                            const Divider(height: 24),
                            _Row('Fecha', Formatters.date(d.startUtc)),
                            _Row('Horario', '${Formatters.time(d.startUtc)} – ${Formatters.time(d.endUtc)}'),
                            _Row('Duración', '${d.totalDurationMinutes} min'),
                            _Row('Total', Formatters.money(d.totalPrice)),
                            _Row('Reserva', Formatters.label(d.bookingChannel)),
                            if (d.addons.isNotEmpty) ...[
                              const Divider(height: 24),
                              const Text('Adicionales', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                              const SizedBox(height: 6),
                              for (final a in d.addons)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(children: [
                                    Expanded(child: Text(a.name, style: const TextStyle(color: AppColors.onInk))),
                                    Text(Formatters.money(a.price), style: const TextStyle(color: AppColors.muted)),
                                  ]),
                                ),
                            ],
                            if (d.internalNotes != null && d.internalNotes!.isNotEmpty) ...[
                              const Divider(height: 24),
                              Text(d.internalNotes!, style: const TextStyle(color: AppColors.muted)),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                            ],
                            const Divider(height: 24),
                            Wrap(spacing: 12, runSpacing: 8, children: _actionsFor(d.status)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600))),
        ]),
      );
}

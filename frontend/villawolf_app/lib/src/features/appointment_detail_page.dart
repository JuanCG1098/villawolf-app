import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
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
    if (_acting) return [const Padding(padding: EdgeInsets.all(8), child: RingLoader())];
    switch (status) {
      case 'Pending':
        return [
          AppButton(label: 'Confirmar', size: AppButtonSize.sm, onPressed: () => _run('confirm')),
          AppButton(label: 'Cancelar', variant: AppButtonVariant.secondary, size: AppButtonSize.sm, onPressed: () => _run('cancel')),
        ];
      case 'Confirmed':
        return [
          AppButton(label: 'Iniciar', size: AppButtonSize.sm, onPressed: () => _run('start')),
          AppButton(label: 'No asistió', variant: AppButtonVariant.secondary, size: AppButtonSize.sm, onPressed: () => _run('no-show')),
          AppButton(label: 'Cancelar', variant: AppButtonVariant.secondary, size: AppButtonSize.sm, onPressed: () => _run('cancel')),
        ];
      case 'InProgress':
        return [AppButton(label: 'Completar', size: AppButtonSize.sm, onPressed: () => _run('complete'))];
      default:
        return [Text('Turno finalizado — sin acciones.', style: TextStyle(color: context.tokens.textMuted))];
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final d = _detail;
    return Scaffold(
      appBar: AppBar(title: const Text('Turno')),
      body: _loading
          ? const Center(child: RingLoader())
          : d == null
              ? Center(child: Text(_error ?? 'No encontrado', style: TextStyle(color: t.textMuted)))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(d.serviceName,
                                      style: TextStyle(color: t.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                                ),
                                StatusBadge(status: d.status, label: Formatters.label(d.status)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_clientName ?? 'Cliente', style: TextStyle(color: t.textMuted)),
                            Divider(height: 24, color: t.borderSubtle),
                            KeyValueRow(label: 'Fecha', value: Formatters.date(d.startUtc)),
                            KeyValueRow(label: 'Horario', value: '${Formatters.time(d.startUtc)} – ${Formatters.time(d.endUtc)}'),
                            KeyValueRow(label: 'Duración', value: '${d.totalDurationMinutes} min'),
                            KeyValueRow(label: 'Total', value: Formatters.money(d.totalPrice)),
                            KeyValueRow(label: 'Reserva', value: Formatters.label(d.bookingChannel)),
                            if (d.addons.isNotEmpty) ...[
                              Divider(height: 24, color: t.borderSubtle),
                              Text('Adicionales', style: TextStyle(color: t.textMuted, fontSize: 12)),
                              const SizedBox(height: 6),
                              for (final a in d.addons)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(children: [
                                    Expanded(child: Text(a.name, style: TextStyle(color: t.textPrimary))),
                                    Text(Formatters.money(a.price), style: TextStyle(color: t.textMuted)),
                                  ]),
                                ),
                            ],
                            if (d.internalNotes != null && d.internalNotes!.isNotEmpty) ...[
                              Divider(height: 24, color: t.borderSubtle),
                              Text(d.internalNotes!, style: TextStyle(color: t.textMuted)),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!, style: TextStyle(color: t.dangerFg, fontSize: 13)),
                            ],
                            Divider(height: 24, color: t.borderSubtle),
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

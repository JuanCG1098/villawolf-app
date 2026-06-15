import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../ui/widgets.dart';

final _camerasProvider = FutureProvider.autoDispose((ref) => ref.read(apiProvider).listCameras());

class CamerasPage extends ConsumerWidget {
  const CamerasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameras = ref.watch(_camerasProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_camerasProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Cámaras',
              style: TextStyle(color: AppColors.onInk, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Monitoreo de dispositivos', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          PanelCard(
            padding: const EdgeInsets.all(14),
            child: Row(children: const [
              Icon(Icons.privacy_tip_outlined, color: AppColors.muted, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Solo administración y monitoreo de dispositivos. Sin reconocimiento facial ni datos biométricos.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          cameras.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, _) => Text('No se pudieron cargar las cámaras.\n$e', style: const TextStyle(color: AppColors.muted)),
            data: (list) => SectionCard(
              title: 'Dispositivos (${list.length})',
              child: list.isEmpty
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Sin cámaras.', style: TextStyle(color: AppColors.muted)))
                  : Column(children: [for (final c in list) _CameraRow(c)]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraRow extends StatelessWidget {
  const _CameraRow(this.camera);
  final CameraModel camera;

  static Color _statusColor(String s) => switch (s) {
        'Active' => AppColors.green,
        'Maintenance' => AppColors.amber,
        _ => AppColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(camera.powerType == 'Solar' ? Icons.solar_power_outlined : Icons.power_outlined,
              color: AppColors.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(camera.name, style: const TextStyle(color: AppColors.onInk, fontWeight: FontWeight.w600)),
              Text(camera.location, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          if (camera.batteryLevel != null) ...[
            Icon(Icons.battery_full,
                size: 16, color: camera.isLowBattery ? AppColors.red : AppColors.muted),
            const SizedBox(width: 4),
            Text('${camera.batteryLevel}%',
                style: TextStyle(color: camera.isLowBattery ? AppColors.red : AppColors.muted, fontSize: 12)),
            const SizedBox(width: 14),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(camera.status).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor(camera.status).withValues(alpha: 0.5)),
            ),
            child: Text(Formatters.label(camera.status),
                style: TextStyle(color: _statusColor(camera.status), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

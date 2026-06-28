import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/design/theme/app_theme.dart';
import 'src/routing/app_router.dart';
import 'src/state/theme_controller.dart';

void main() => runApp(const ProviderScope(child: VillaWolfApp()));

class VillaWolfApp extends ConsumerWidget {
  const VillaWolfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: 'VILLAWOLF — hair studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/theme.dart';
import 'src/routing/app_router.dart';

void main() => runApp(const ProviderScope(child: VillaWolfApp()));

class VillaWolfApp extends ConsumerWidget {
  const VillaWolfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'VILLAWOLF — hair studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

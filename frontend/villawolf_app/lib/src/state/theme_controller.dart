import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the active [ThemeMode] and persists the user's choice. Defaults to dark (the Villa Wolf
/// identity is dark-first); the light preset is a clean inverse for web.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.dark) {
    _load();
  }

  static const _key = 'villawolf_theme_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    state = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  void toggle() =>
      set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) => ThemeController());

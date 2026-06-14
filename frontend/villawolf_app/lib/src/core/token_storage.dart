import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT across sessions (web + mobile) via shared_preferences.
class TokenStorage {
  static const _key = 'villawolf_token';

  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

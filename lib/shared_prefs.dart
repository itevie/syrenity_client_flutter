import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  SettingsStorage._privateConstructor();

  static final SettingsStorage _instance =
      SettingsStorage._privateConstructor();

  static SettingsStorage get instance => _instance;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  T? get<T>(String key) {
    if (_prefs == null) throw Exception("SettingsStorage not initialized");
    return _prefs!.get(key) as T?;
  }

  Future<bool> set<T>(String key, T value) async {
    if (_prefs == null) throw Exception("SettingsStorage not initialized");

    if (value is bool) return _prefs!.setBool(key, value);
    if (value is int) return _prefs!.setInt(key, value);
    if (value is double) return _prefs!.setDouble(key, value);
    if (value is String) return _prefs!.setString(key, value);
    if (value is List<String>) return _prefs!.setStringList(key, value);

    throw Exception("Unsupported type: ${value.runtimeType}");
  }

  Future<bool> remove(String key) async {
    if (_prefs == null) throw Exception("SettingsStorage not initialized");
    return _prefs!.remove(key);
  }
}

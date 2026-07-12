import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';

class SettingsStorage {
  SettingsStorage._privateConstructor();

  final Map<String, ValueNotifier<dynamic>> _notifiers = {};

  ValueNotifier<T> notifierFor<T>(SettingKeys key) {
    if (_prefs == null) throw Exception("SettingsStorage not initialized");

    return _notifiers.putIfAbsent(
          key.storageKey,
          () => ValueNotifier<T>(getSetting<T>(key)),
        )
        as ValueNotifier<T>;
  }

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

    bool result;

    if (value == null) {
      result = await _prefs!.remove(key);
    } else {
      if (value is bool) {
        result = await _prefs!.setBool(key, value);
      } else if (value is int) {
        result = await _prefs!.setInt(key, value);
      } else if (value is double) {
        result = await _prefs!.setDouble(key, value);
      } else if (value is String) {
        result = await _prefs!.setString(key, value);
      } else if (value is List<String>) {
        result = await _prefs!.setStringList(key, value);
      } else {
        throw Exception("Unsupported type: ${value.runtimeType}");
      }
    }

    if (_notifiers.containsKey(key)) {
      _notifiers[key]!.value = value;
    }

    return result;
  }

  Future<bool> remove(String key) async {
    if (_prefs == null) throw Exception("SettingsStorage not initialized");
    return _prefs!.remove(key);
  }

  T getSetting<T>(SettingKeys key) {
    return _prefs!.get(key.storageKey) as T? ?? key.defaultValue as T;
  }
}

import 'dart:ui';

enum SettingType { checkbox, string, seperator, pageSwitch }

sealed class SettingPart<T> {
  final String name;
  final String description;
  final SettingType type;

  SettingPart({
    required this.name,
    required this.description,
    required this.type,
  });
}

class ChecklistSettingPart extends SettingPart<bool> {
  final void Function(bool value) callback;
  final Future<Object?> Function() provideValue;
  final VoidCallback? reload;
  final Object? defaultValue;

  ChecklistSettingPart({
    required super.name,
    required super.description,
    required this.provideValue,
    required this.defaultValue,
    required this.callback,
    this.reload,
  }) : super(type: SettingType.checkbox);
}

class StringSettingPart extends SettingPart<String> {
  final void Function(String value) callback;
  final Future<Object?> Function() provideValue;
  final VoidCallback? reload;
  final Object? defaultValue;

  StringSettingPart({
    required super.name,
    required super.description,
    required this.provideValue,
    required this.defaultValue,
    required this.callback,
    this.reload,
  }) : super(type: SettingType.string);
}

class SeperatorSettingPart extends SettingPart<int> {
  SeperatorSettingPart(String name)
    : super(type: SettingType.seperator, name: name, description: "_");
}

class PageSwitchSettingPart extends SettingPart<int> {
  final VoidCallback onTap;

  PageSwitchSettingPart({
    required super.name,
    required super.description,
    required this.onTap,
  }) : super(type: SettingType.pageSwitch);
}

import 'dart:ui';

enum SettingType { checkbox, seperator, pageSwitch }

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
  final Future<bool> Function() provideValue;
  final VoidCallback? reload;
  final bool defaultValue;

  ChecklistSettingPart({
    required super.name,
    required super.description,
    required this.provideValue,
    required this.defaultValue,
    required this.callback,
    this.reload,
  }) : super(type: SettingType.checkbox);
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

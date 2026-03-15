import 'dart:ui';

enum SettingType { checkbox, seperator }

sealed class SettingPart<T> {
  final String name;
  final String description;
  final SettingType type;
  final Future<T> Function() provideValue;
  final T defaultValue;
  final VoidCallback? reload;

  SettingPart({
    required this.name,
    required this.description,
    required this.type,
    required this.provideValue,
    required this.defaultValue,
    this.reload,
  });
}

class ChecklistSettingPart extends SettingPart<bool> {
  final void Function(bool value) callback;

  ChecklistSettingPart({
    required super.name,
    required super.description,
    required super.provideValue,
    required super.defaultValue,
    required this.callback,
    super.reload,
  }) : super(type: SettingType.checkbox);
}

class SeperatorSettingPart extends SettingPart<int> {
  SeperatorSettingPart()
    : super(
        type: SettingType.seperator,
        name: "_",
        description: "_",
        provideValue: () async {
          return 0;
        },
        defaultValue: 0,
      );
}

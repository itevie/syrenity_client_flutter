import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';

sealed class SettingSection {
  final String name;
  final BuildContext context;

  SettingSection({required this.name, required this.context});
}

class PartsSettingSection extends SettingSection {
  final List<SettingPart> parts;

  PartsSettingSection({
    required super.name,
    required super.context,
    required this.parts,
  }) : super();
}

class CallbackSettingSecttion extends SettingSection {
  final VoidCallback callback;

  CallbackSettingSecttion({
    required super.name,
    required super.context,
    required this.callback,
  }) : super();
}

class WidgetSettingsSection extends SettingSection {
  final Widget Function() widget;

  WidgetSettingsSection({
    required super.name,
    required super.context,
    required this.widget,
  }) : super();
}

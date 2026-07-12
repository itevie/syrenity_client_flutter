import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';

sealed class SettingSection {
  final String name;
  final BuildContext context;
  final IconData? icon;

  SettingSection({required this.name, required this.context, this.icon});
}

class PartsSettingSection extends SettingSection {
  final List<SettingPart> parts;

  PartsSettingSection({
    required super.name,
    required super.context,
    required this.parts,
    super.icon,
  }) : super();
}

class CallbackSettingSecttion extends SettingSection {
  final VoidCallback callback;

  CallbackSettingSecttion({
    required super.name,
    required super.context,
    required this.callback,
    super.icon,
  }) : super();
}

class WidgetSettingsSection extends SettingSection {
  final Widget Function() widget;
  final (VoidCallback, IconData)? fab;

  WidgetSettingsSection({
    required super.name,
    required super.context,
    required this.widget,
    super.icon,
    this.fab,
  }) : super();
}

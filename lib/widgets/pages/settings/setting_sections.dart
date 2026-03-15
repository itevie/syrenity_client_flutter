import 'package:dawn_ui_flutter/prompts/confirm.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/pages/app_loading.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_parts.dart';

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

class SettingSections {
  static chat(context) => PartsSettingSection(
    context: context,
    name: "Chat",
    parts: [
      SettingParts.showSendMessageButton,
      SettingParts.showGifPickerButton,
    ],
  );

  static widget(context) => WidgetSettingsSection(
    name: "Widget",
    context: context,
    widget: () => Text("bye"),
  );

  static logout(context) => CallbackSettingSecttion(
    context: context,
    name: "Logout",
    callback: () async {
      final conf = await showConfirmPrompt(
        context,
        const Text("Logout"),
        const Text("Are you sure you want to logout?"),
      );

      if (conf) {
        await SettingsStorage.instance.remove("token");
        setupClient(login: false);
        reload();
      }
    },
  );
}

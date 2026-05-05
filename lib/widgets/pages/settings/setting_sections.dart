import 'package:dawn_ui_flutter/prompts/confirm.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/modals/user_viewer.dart';
import 'package:syrenity_client_flutter/widgets/pages/app_loading.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/pages/about.dart';
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
  static user(context) => WidgetSettingsSection(
    name: "User",
    context: context,
    widget: () => UserViewerModal(user: client.user),
  );

  static interface(context) => PartsSettingSection(
    context: context,
    name: "Interface",
    parts: [SettingParts.showCopiedToClipboardFlout],
  );

  static chat(context) => PartsSettingSection(
    context: context,
    name: "Chat",
    parts: [
      SeperatorSettingPart("Chatbar"),
      SettingParts.showSendMessageButton,
      SettingParts.showGifPickerButton,
      SettingParts.showEmojiPickerButton,
      SeperatorSettingPart("Messages"),
      SettingParts.markdown,
    ],
  );

  static developer(context) => PartsSettingSection(
    context: context,
    name: "Developer",
    parts: [SettingParts.developerMode, SettingParts.developerShowBots],
  );

  static about(context) => WidgetSettingsSection(
    name: "About",
    context: context,
    widget: () => AboutPage(),
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

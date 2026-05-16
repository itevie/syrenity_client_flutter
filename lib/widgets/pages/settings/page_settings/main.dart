import 'package:dawn_ui_flutter/prompts/confirm.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/pages/app_loading.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/pages/about.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/pages/user_applications.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/pages/user_edit.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_sections.dart';

class SettingSections {
  SettingSections._();

  static user(context) => WidgetSettingsSection(
    name: "User",
    context: context,
    widget: () => EditUserPage(),
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

  static bots(context) => WidgetSettingsSection(
    context: context,
    name: "Applications",
    widget: () => UserApplicationsPage(),
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

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

  static WidgetSettingsSection user(BuildContext context) =>
      WidgetSettingsSection(
        name: "User",
        icon: Icons.person,
        context: context,
        widget: () => EditUserPage(),
      );

  static PartsSettingSection interface(BuildContext context) =>
      PartsSettingSection(
        context: context,
        name: "Interface",
        icon: Icons.display_settings,
        parts: [SettingParts.showCopiedToClipboardFlout],
      );

  static PartsSettingSection appearance(BuildContext context) =>
      PartsSettingSection(
        context: context,
        icon: Icons.palette,
        name: "Appearance",
        parts: [SettingParts.darkMode, SettingParts.themeColour],
      );

  static PartsSettingSection chat(BuildContext context) => PartsSettingSection(
    context: context,
    name: "Chat",
    icon: Icons.chat,
    parts: [
      SeperatorSettingPart("Chatbar"),
      SettingParts.showSendMessageButton,
      SettingParts.showGifPickerButton,
      SettingParts.showEmojiPickerButton,
      SeperatorSettingPart("Messages"),
      SettingParts.markdown,
    ],
  );

  static PartsSettingSection developer(BuildContext context) =>
      PartsSettingSection(
        context: context,
        name: "Developer",
        icon: Icons.code,
        parts: [SettingParts.developerMode, SettingParts.developerShowBots],
      );

  static WidgetSettingsSection bots(BuildContext context) =>
      WidgetSettingsSection(
        context: context,
        name: "Applications",
        icon: Icons.apps,
        widget: () => UserApplicationsPage(),
      );

  static WidgetSettingsSection about(BuildContext context) =>
      WidgetSettingsSection(
        name: "About",
        icon: Icons.info,
        context: context,
        widget: () => AboutPage(),
      );

  static CallbackSettingSecttion logout(BuildContext context) =>
      CallbackSettingSecttion(
        context: context,
        name: "Logout",
        icon: Icons.logout,
        callback: () async {
          final conf = await showConfirmPrompt(
            context,
            const Text("Logout"),
            const Text("Are you sure you want to logout?"),
          );

          if (conf) {
            await SettingsStorage.instance.remove("token");
            await client.ws.socket.close();
            reload();
          }
        },
      );
}

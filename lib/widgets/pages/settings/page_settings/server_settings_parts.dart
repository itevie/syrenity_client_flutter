import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_channel_order.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_channel_settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_invite_settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_member_settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_role_settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/pages/about.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_sections.dart';

class ServerSettingsParts {
  ServerSettingsParts._();

  static WidgetSettingsSection about(BuildContext context) =>
      WidgetSettingsSection(
        name: "Server",
        context: context,
        widget: () => AboutPage(),
      );

  static WidgetSettingsSection members(BuildContext context) =>
      WidgetSettingsSection(
        context: context,
        name: "Members",
        widget: () => ServerMemberSettingss(),
      );

  static WidgetSettingsSection roles(BuildContext context) =>
      WidgetSettingsSection(
        context: context,
        name: "Roles",
        widget: () => ServerRoleSettings(),
        fab: (() {}, Icons.add),
      );

  static WidgetSettingsSection channels(BuildContext context) =>
      WidgetSettingsSection(
        context: context,
        name: "Channels",
        widget: () => ServerChannelSettingsPage(),
      );

  static WidgetSettingsSection invites(BuildContext context) =>
      WidgetSettingsSection(
        context: context,
        name: "Invites",
        widget: () => ServerInviteSettings(),
      );

  static WidgetSettingsSection details(BuildContext context) =>
      WidgetSettingsSection(
        context: context,
        name: "Details",
        widget: () => Container(),
      );
}

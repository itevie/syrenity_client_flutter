import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_invite_settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_role_settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/pages/about.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_sections.dart';

class ServerSettingsParts {
  ServerSettingsParts._();

  static about(context) => WidgetSettingsSection(
    name: "Server",
    context: context,
    widget: () => AboutPage(),
  );

  static members(context) => WidgetSettingsSection(
    context: context,
    name: "Members",
    widget: () => Container(),
  );

  static roles(context) => WidgetSettingsSection(
    context: context,
    name: "Roles",
    widget: () => ServerRoleSettings(),
  );

  static invites(context) => WidgetSettingsSection(
    context: context,
    name: "Invites",
    widget: () => ServerInviteSettings(),
  );

  static details(context) => WidgetSettingsSection(
    context: context,
    name: "Details",
    widget: () => Container(),
  );
}

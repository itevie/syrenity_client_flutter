import 'package:syrenity_client_flutter/widgets/pages/settings/pages/about.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_sections.dart';

class ChannelSettingsParts {
  ChannelSettingsParts._();

  static about(context) => WidgetSettingsSection(
    name: "About",
    context: context,
    widget: () => AboutPage(),
  );
}

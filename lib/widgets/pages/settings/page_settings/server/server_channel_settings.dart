import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server/server_channel_order.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings_widgets/page_switch_part.dart';

class ServerChannelSettingsPage extends StatelessWidget {
  const ServerChannelSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        pageSwitchPart("Channel Order", "Change the order of channels", () {
          if (changeSettingsPagesPage != null) {
            changeSettingsPagesPage!(ServerChannelOrderSettings());
          }
        }),
      ],
    );
  }
}

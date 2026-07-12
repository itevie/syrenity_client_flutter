import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/all_channels.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/text_channel.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/self_section.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/server_bar.dart';
import 'package:syrenity_client_flutter/widgets/prominent_banner.dart';

class DesktopChatShell extends StatelessWidget {
  final Widget? currentPage;
  final Widget? sidebarWidget;
  final VoidCallback onToggleRightPanel;

  const DesktopChatShell({
    super.key,
    required this.currentPage,
    required this.sidebarWidget,
    required this.onToggleRightPanel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sidebarWidth =
        currentPage != null
            ? MediaQuery.of(context).size.width
            : SyrenityTheme.serverChannelBarWidth;

    final currentSettings = context.watch<CurrentSettingsState>();
    final channels = context.watch<ChannelStore>();
    final channel =
        currentSettings.channelId == null
            ? null
            : channels[currentSettings.channelId!];

    final settings = context.watch<CurrentSettingsState>();

    return Column(
      children: [
        if (settings.prominentBannerDetails != null)
          ProminentBannerWidget(details: settings.prominentBannerDetails!),

        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: sidebarWidth,
                child: Container(
                  color: colors.secondaryContainer,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: SyrenityTheme.serverBarWidth,
                              child: ServerBar(),
                            ),

                            if (currentPage == null)
                              const Expanded(child: ChannelBar()),

                            if (currentPage != null)
                              Expanded(child: currentPage!),
                          ],
                        ),
                      ),

                      const SelfSection(),
                    ],
                  ),
                ),
              ),

              if (currentPage == null)
                Expanded(
                  child: AllChannels(
                    key: Key("main-${channel?.id}"),
                    channelId: channel?.id,
                  ),
                ),

              if (sidebarWidget != null)
                SizedBox(
                  width: SyrenityTheme.memberBarWidgth,
                  child: sidebarWidget,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

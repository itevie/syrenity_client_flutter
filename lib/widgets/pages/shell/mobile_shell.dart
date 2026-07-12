import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/all_channels.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/self_section.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/server_bar.dart';

class MobileChatShell extends StatelessWidget {
  final Widget? currentPage;
  final bool leftPanelOpen;
  final Widget? sidebarWidget;
  final VoidCallback onToggleLeftPanel;
  final VoidCallback onToggleRightPanel;

  const MobileChatShell({
    super.key,
    required this.currentPage,
    required this.leftPanelOpen,
    required this.sidebarWidget,
    required this.onToggleLeftPanel,
    required this.onToggleRightPanel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentSettings = context.watch<CurrentSettingsState>();
    final channels = context.watch<ChannelStore>();
    final channel =
        currentSettings.channelId == null
            ? null
            : channels[currentSettings.channelId!];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:
                currentPage == null
                    ? AllChannels(
                      channelId: channel?.id,
                      key: Key("main-${channel?.id}"),
                    )
                    : currentPage!,
          ),

          if (leftPanelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: onToggleLeftPanel,
                child: Container(color: const Color(0x66000000)),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastEaseInToSlowEaseOut,
            left: leftPanelOpen ? 0 : -320,
            top: 0,
            bottom: 0,
            width: 320,
            child: Container(
              color: colors.secondaryContainer,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: SyrenityTheme.serverBarWidth,
                          child: const ServerBar(),
                        ),
                        Expanded(
                          child:
                              currentPage == null
                                  ? const ChannelBar()
                                  : currentPage!,
                        ),
                      ],
                    ),
                  ),
                  const SelfSection(),
                ],
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastEaseInToSlowEaseOut,
            right: (sidebarWidget == null || leftPanelOpen) ? -320 : 0,
            top: 0,
            bottom: 0,
            width: 320,
            child: sidebarWidget ?? SizedBox(),
          ),
        ],
      ),
    );
  }
}

import 'package:dawn_ui_flutter/prompts/error.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/member_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/self_section.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/server_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool drawerShown = false;
  bool memberBarShown = false;

  @override
  void initState() {
    MainCallbacks.setDrawerVisibility = (value) {
      setState(() {
        if (value == null) {
          drawerShown = !drawerShown;
        } else {
          drawerShown = value;
        }
      });
    };

    MainCallbacks.setMemberBarVisibility = (value) {
      setState(() {
        if (value == null) {
          memberBarShown = !memberBarShown;
        } else {
          memberBarShown = value;
        }
      });
    };

    MainCallbacks.showError = (error) {
      showErrorPrompt(context, error.toString());
    };
    super.initState();
  }

  @override
  void dispose() {
    MainCallbacks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    bool showMobileDrawer = !isDesktop && drawerShown;

    return GestureDetector(
      // Detect horizontal swipes anywhere on the screen
      onHorizontalDragUpdate: (details) {
        if (!isDesktop) {
          if (details.delta.dx > 10) {
            // Swipe right → open drawer
            setState(() => drawerShown = true);
          } else if (details.delta.dx < -10) {
            // Swipe left → close drawer
            setState(() => drawerShown = false);
          }
        }
      },
      child: Row(
        children: [
          // Server/Channel panel
          Offstage(
            offstage: !(isDesktop || drawerShown),
            child: Container(
              width:
                  showMobileDrawer
                      ? MediaQuery.of(context).size.width
                      : SyrenityTheme.serverChannelBarWidth,
              color: colors.secondaryContainer,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Servers (keeps state alive)
                        SizedBox(
                          width: SyrenityTheme.serverBarWidth,
                          child: ServerBar(),
                        ),
                        // Channels (keeps state alive)
                        Expanded(child: ChannelBar()),
                      ],
                    ),
                  ),
                  SelfSection(),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(child: MainRight()),
          if (memberBarShown)
            SizedBox(width: SyrenityTheme.memberBarWidgth, child: MemberBar()),
        ],
      ),
    );
  }
}

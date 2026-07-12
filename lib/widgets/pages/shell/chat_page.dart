import 'package:dawn_ui_flutter/prompts/error.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/pages/shell/desktop_shell.dart';
import 'package:syrenity_client_flutter/widgets/pages/shell/mobile_shell.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool leftPanelOpen = false;
  bool rightPanelOpen = false;

  (Widget, Widget)? sidebarWidget;
  Widget? currentPage;

  @override
  void initState() {
    super.initState();

    MainCallbacks.setDrawerVisibility = (value) {
      setState(() {
        if ((value ?? !leftPanelOpen == true)) sidebarWidget = null;
        leftPanelOpen = value ?? !leftPanelOpen;
      });
    };

    MainCallbacks.setSidebar = (value) {
      setState(() {
        sidebarWidget = value;
      });
    };

    MainCallbacks.showError = (error) {
      showErrorPrompt(context, error.toString());
    };

    MainCallbacks.setPage = (givenPage) {
      setState(() {
        currentPage = givenPage;
      });
    };
  }

  @override
  void dispose() {
    MainCallbacks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= SyrenityTheme.mobileSize;

        final colors = Theme.of(context).colorScheme;

        final sidebar =
            sidebarWidget == null
                ? null
                : Column(
                  children: [
                    Container(
                      height: SyrenityTheme.topBarHeight,
                      color: colors.surfaceContainer,
                      child: Stack(
                        children: [
                          // Centered title (true center)
                          Center(child: sidebarWidget!.$1),

                          // Left icon
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  sidebarWidget = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    sidebarWidget!.$2,
                    Container(
                      height: SyrenityTheme.bottomBarHeight,
                      color: colors.inversePrimary,
                    ),
                  ],
                );

        if (isDesktop) {
          return DesktopChatShell(
            currentPage: currentPage,
            sidebarWidget: sidebar,
            onToggleRightPanel:
                () => setState(() => rightPanelOpen = !rightPanelOpen),
          );
        }

        return MobileChatShell(
          currentPage: currentPage,
          leftPanelOpen: leftPanelOpen,
          sidebarWidget: sidebar,

          onToggleLeftPanel:
              () => setState(() => leftPanelOpen = !leftPanelOpen),
          onToggleRightPanel:
              () => setState(() => rightPanelOpen = !rightPanelOpen),
        );
      },
    );
  }
}

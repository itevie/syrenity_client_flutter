import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/main.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/message.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/message_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/typing_indicator.dart';

class MainRight extends StatefulWidget {
  const MainRight({super.key});

  @override
  State<StatefulWidget> createState() => _MainRightState();
}

class _MainRightState extends State<MainRight> {
  List<SyMessage> messages = [];
  int? _lastChannelId;
  bool _isLoadingMore = false;
  bool _showScrollToBottom = false;
  late void Function(SyMessage)? callback;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !_isLoadingMore) {
        _loadMore();
      }

      if (_scrollController.hasClients) {
        final scrolledUpEnough = _scrollController.offset > 1000;
        if (_showScrollToBottom == scrolledUpEnough) return;

        setState(() {
          _showScrollToBottom = scrolledUpEnough;
        });
      }
    });

    callback = (message) {
      if (message.channelId != _lastChannelId) return;

      setState(() {
        messages.insert(0, message);
      });
    };

    client.events.on(SyEvents.dispatchCreateMessage, callback!);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (callback != null) {
      client.events.off(SyEvents.dispatchCreateMessage, callback!);
      callback = null;
    }
    super.dispose();
  }

  Future<void> load(int channelId) async {
    final channelStore = context.read<ChannelStore>();
    final channel = channelStore[channelId];

    if (channel == null) {
      setState(() => messages = []);
      return;
    }

    try {
      final fetchedMessages = await channel.query(
        ChannelMessageQueryOptions(amount: 20),
      );

      setState(() => messages = fetchedMessages);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });
    } catch (e) {
      setState(() => messages = []);
      rethrow;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadMore() async {
    if (_lastChannelId == null || messages.isEmpty) return;

    final channelStore = context.read<ChannelStore>();
    final channel = channelStore[_lastChannelId!];
    if (channel == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final oldestMessageId = messages
          .map((m) => m.id)
          .reduce((a, b) => a < b ? a : b);
      final fetched = await channel.query(
        ChannelMessageQueryOptions(amount: 20, startAt: oldestMessageId),
      );

      if (fetched.isNotEmpty) {
        // Preserve scroll position
        final oldScrollHeight = _scrollController.position.maxScrollExtent;

        setState(() {
          messages = messages + fetched;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final newScrollHeight = _scrollController.position.maxScrollExtent;
            _scrollController.jumpTo(newScrollHeight - oldScrollHeight);
          }
        });
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentSettings = context.watch<CurrentSettingsState>();

    final channel =
        currentSettings.channelId == null
            ? null
            : context.select<ChannelStore, SyChannel?>(
              (store) =>
                  currentSettings.channelId == null
                      ? null
                      : store[currentSettings.channelId!],
            );

    // Load messages when the selected channel changes
    if (currentSettings.channelId != null &&
        currentSettings.channelId != _lastChannelId) {
      _lastChannelId = currentSettings.channelId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        load(currentSettings.channelId!);
      });
    }

    return Container(
      color: colors.surface,
      child: Stack(
        children: [
          Column(
            children: [
              // Top bar
              Container(
                height: SyrenityTheme.topBarHeight,
                color: colors.surfaceContainer,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("#${channel?.name ?? "Loading..."}"),
                  ),
                ),
              ),

              Expanded(
                child:
                    channel == null
                        ? const Center(child: Text("Click a channel!"))
                        : Stack(
                          children: [
                            ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.all(10),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                return MessageWidget(
                                  message: msg,
                                  newestMessage: messages[0].id,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Visibility(
                                visible: _showScrollToBottom,
                                child: FloatingActionButton(
                                  mini: true,
                                  onPressed: _scrollToBottom,
                                  child: const Icon(Icons.arrow_downward),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),

              TypingIndicator(channelId: _lastChannelId),
              MessageBar(
                key: ValueKey(currentSettings.channelId),
                channel: channel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

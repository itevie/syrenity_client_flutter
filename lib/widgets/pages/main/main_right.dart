import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
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
  bool _initialLoading = true;

  int _loadToken = 0;

  late void Function(SyMessage)? messageCreateCallback;
  late void Function(int)? messageDeleteCallback;

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

    messageCreateCallback = (message) {
      if (message.channelId != _lastChannelId) return;

      setState(() {
        messages.insert(0, message);
      });
    };

    client.events.on(SyEvents.dispatchCreateMessage, messageCreateCallback!);

    messageDeleteCallback = (messageId) {
      setState(() {
        messages = messages.where((x) => x.id != messageId).toList();
      });
    };

    client.events.on(SyEvents.dispatchDeleteMessage, messageDeleteCallback!);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    if (messageCreateCallback != null) {
      client.events.off(SyEvents.dispatchCreateMessage, messageCreateCallback!);
      messageCreateCallback = null;
    }

    if (messageDeleteCallback != null) {
      client.events.off(SyEvents.dispatchDeleteMessage, messageDeleteCallback!);
      messageDeleteCallback = null;
    }

    super.dispose();
  }

  void _onChannelChanged(int? channelId) {
    if (channelId == null || channelId == _lastChannelId) return;

    _lastChannelId = channelId;
    _loadToken++;

    setState(() {
      messages = [];
      _initialLoading = true;
      _isLoadingMore = false;
      _showScrollToBottom = false;
    });

    load(channelId, _loadToken);
  }

  Future<void> load(int channelId, int token) async {
    final channelStore = context.read<ChannelStore>();
    final channel = channelStore[channelId];

    if (channel == null) {
      if (mounted && token == _loadToken) {
        setState(() => messages = []);
      }
      return;
    }

    try {
      final fetchedMessages = await channel.query(
        ChannelMessageQueryOptions(amount: 20),
      );

      if (!mounted || token != _loadToken) return;

      setState(() {
        messages = fetchedMessages;
        _initialLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });
    } catch (_) {
      if (!mounted || token != _loadToken) return;

      setState(() {
        messages = [];
        _initialLoading = false;
      });
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
    if (_lastChannelId == null || messages.isEmpty || _isLoadingMore) return;

    final token = _loadToken;

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

      if (!mounted || token != _loadToken) return;

      if (fetched.isNotEmpty) {
        final oldScrollHeight = _scrollController.position.maxScrollExtent;

        setState(() {
          messages = [...messages, ...fetched];
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final newScrollHeight = _scrollController.position.maxScrollExtent;
            _scrollController.jumpTo(newScrollHeight - oldScrollHeight);
          }
        });
      }
    } finally {
      if (mounted && token == _loadToken) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final channelId = context.select<CurrentSettingsState, int?>(
      (s) => s.channelId,
    );

    _onChannelChanged(channelId);

    final channel =
        channelId == null
            ? null
            : context.select<ChannelStore, SyChannel?>(
              (store) => store[channelId],
            );

    return Container(
      color: colors.surface,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: SyrenityTheme.topBarHeight,
                color: colors.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (!isDesktop) ...[
                        IconButton(
                          onPressed: () {
                            MainCallbacks.setDrawerVisibility?.call(true);
                          },
                          icon: const Icon(Icons.menu),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text("#${channel?.name ?? "Loading..."}"),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.group),
                        onPressed: () {
                          if (MainCallbacks.setMemberBarVisibility != null) {
                            MainCallbacks.setMemberBarVisibility!(null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child:
                    channel == null
                        ? const Center(child: Text("Click a channel!"))
                        : Stack(
                          children: [
                            _initialLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : messages.isEmpty
                                ? const Center(child: Text("So empty..."))
                                : ListView.builder(
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
              MessageBar(key: ValueKey(channelId), channel: channel),
            ],
          ),
        ],
      ),
    );
  }
}

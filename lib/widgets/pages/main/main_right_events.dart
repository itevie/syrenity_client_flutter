import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ChannelMessagesController extends ChangeNotifier {
  final int channelId;
  final ChannelStore channelStore;
  final bool noEvents;
  final bool showPinned;

  List<SyMessage> messages = [];
  List<SyTodoItem> todos = [];

  bool isLoadingMore = false;
  bool initialLoading = true;
  int _loadToken = 0;

  late void Function(SyMessage) _messageCreateCallback;
  late void Function(int) _messageDeleteCallback;

  ChannelMessagesController({
    required this.channelId,
    required this.channelStore,
    this.noEvents = false,
    this.showPinned = false,
  });

  Future<void> init() async {
    await load(_loadToken);

    if (noEvents) return;

    final channel = channelStore[channelId];

    if (channel!.isTextChannel()) {
      _messageCreateCallback = (message) {
        if (message.channelId != channelId) return;

        messages.insert(0, message);
        notifyListeners();
      };

      _messageDeleteCallback = (messageId) {
        messages.removeWhere((x) => x.id == messageId);
        notifyListeners();
      };

      client.events.on(SyEvents.dispatchCreateMessage, _messageCreateCallback);

      client.events.on(SyEvents.dispatchDeleteMessage, _messageDeleteCallback);
    } else if (channel.isTodoChannel()) {}
  }

  Future<void> load(int token) async {
    final channel = channelStore[channelId];

    if (channel == null) {
      if (token == _loadToken) {
        messages = [];
        notifyListeners();
      }

      return;
    }

    try {
      final fetchedMessages = await channel.asTextChannel().query(
        ChannelMessageQueryOptions(amount: 20, isPinned: showPinned),
      );

      if (token != _loadToken) return;

      messages = fetchedMessages;
      initialLoading = false;

      notifyListeners();

      if (fetchedMessages.isNotEmpty) {
        await channel.lastMessageAck?.updateAck(fetchedMessages.first.id);
      }
    } catch (e) {
      print(e);
      if (token != _loadToken) return;

      messages = [];
      initialLoading = false;

      notifyListeners();
    }
  }

  Future<List<SyMessage>> loadMore() async {
    if (messages.isEmpty || isLoadingMore) return [];

    final token = _loadToken;

    final channel = channelStore[channelId];
    if (channel == null) return [];

    isLoadingMore = true;
    notifyListeners();

    try {
      final oldestMessageId = messages
          .map((m) => m.id)
          .reduce((a, b) => a < b ? a : b);

      final fetched = await channel.asTextChannel().query(
        ChannelMessageQueryOptions(
          amount: 20,
          startAt: oldestMessageId,
          isPinned: showPinned,
        ),
      );

      if (token != _loadToken) return [];

      if (fetched.isNotEmpty) {
        messages = [...messages, ...fetched];
        notifyListeners();
      }

      return fetched;
    } finally {
      if (token == _loadToken) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  void addFakeMessage(SyMessage message) {
    messages.insert(0, message);
    notifyListeners();
  }

  void removeFakeMessage(int id) {
    messages.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  void disposeController() {
    client.events.off(SyEvents.dispatchCreateMessage, _messageCreateCallback);

    client.events.off(SyEvents.dispatchDeleteMessage, _messageDeleteCallback);
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}

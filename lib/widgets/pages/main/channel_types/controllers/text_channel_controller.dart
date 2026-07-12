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
  late void Function(SyMessage) _messageUpdateCallback;
  late void Function(int) _messageDeleteCallback;

  ChannelMessagesController({
    required this.channelId,
    required this.channelStore,
    this.noEvents = false,
    this.showPinned = false,
  });

  Future<void> init() async {
    await loadMessages(isInitial: false);

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

      _messageUpdateCallback = (message) {
        if (message.channelId != channelId) return;

        final index = messages.indexWhere((x) => x.id == message.id);
        if (index == -1) return;

        messages[index] = message;
        notifyListeners();
      };

      client.events.on(SyEvents.dispatchMessageCreate, _messageCreateCallback);

      client.events.on(SyEvents.dispatchMessageDelete, _messageDeleteCallback);

      client.events.on(SyEvents.dispatchMessageUpdate, _messageUpdateCallback);
    } else if (channel.isTodoChannel()) {}
  }

  Future<List<SyMessage>> loadMessages({required bool isInitial}) async {
    final token = _loadToken;

    final channel = channelStore[channelId];

    if (channel == null) {
      if (!isInitial && token == _loadToken) {
        messages = [];
        initialLoading = false;
        notifyListeners();
      }

      return [];
    }

    if (isInitial) {
      isLoadingMore = true;
      notifyListeners();
    }

    try {
      final start =
          isInitial == false
              ? null
              : messages.map((m) => m.id).reduce((a, b) => a < b ? a : b);

      final fetched = await channel.asTextChannel().query(
        TextChannelMessageQueryOptions(
          amount: 20,
          startAt: start,
          isPinned: showPinned == true ? true : null,
        ),
      );

      if (token != _loadToken) return [];

      if (isInitial) {
        if (fetched.isNotEmpty) {
          messages = [...messages, ...fetched];
        }
      } else {
        messages = fetched;
        initialLoading = false;

        if (fetched.isNotEmpty) {
          await channel.lastMessageAck?.updateAck(fetched.first.id);
        }
      }

      notifyListeners();

      return fetched;
    } catch (e) {
      print(e);

      if (token != _loadToken) return [];

      if (!isInitial) {
        messages = [];
        initialLoading = false;
        notifyListeners();
      }

      return [];
    } finally {
      if (isInitial && token == _loadToken) {
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
    client.events.off(SyEvents.dispatchMessageCreate, _messageCreateCallback);

    client.events.off(SyEvents.dispatchMessageDelete, _messageDeleteCallback);

    client.events.off(SyEvents.dispatchMessageUpdate, _messageUpdateCallback);
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}

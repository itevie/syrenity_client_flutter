import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class TodoChannelMessagesController extends ChangeNotifier {
  final int channelId;
  final ChannelStore channelStore;
  final bool noEvents;
  final bool showPinned;

  List<SyTodoItem> todos = [];

  bool isLoadingMore = false;
  bool initialLoading = true;

  late void Function(SyTodoItem) _todoUpdateCallback;
  late void Function(SyTodoItem) _todoCreateCallback;
  late void Function(int) _todoDeleteCallback;

  TodoChannelMessagesController({
    required this.channelId,
    required this.channelStore,
    this.noEvents = false,
    this.showPinned = false,
  });

  Future<void> init() async {
    await loadMessages(isInitial: false);

    if (noEvents) return;

    final channel = channelStore[channelId];

    _todoUpdateCallback = (todo) {
      if (todo.channelId != channelId) return;

      final index = todos.indexWhere((x) => x.id == todo.id);
      if (index == -1) return;

      todos[index] = todo;
      notifyListeners();
    };

    _todoCreateCallback = (todo) {
      if (todo.channelId != channelId) return;

      todos.insert(0, todo);
      notifyListeners();
    };

    _todoDeleteCallback = (todoId) {
      todos = todos.where((x) => x.id != todoId).toList();
      notifyListeners();
    };

    client.events.on(SyEvents.dispatchTodoUpdate, _todoUpdateCallback);
    client.events.on(SyEvents.dispatchTodoCreate, _todoCreateCallback);
    client.events.on(SyEvents.dispatchTodoDelete, _todoDeleteCallback);
  }

  Future<List<SyTodoItem>> loadMessages({required bool isInitial}) async {
    final channel = channelStore[channelId];

    if (channel == null) {
      if (!isInitial) {
        todos = [];
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
              : todos.map((m) => m.id).reduce((a, b) => a < b ? a : b);

      final fetched = await channel.asTodoChannel().query(
        TodoChannelMessageQueryOptions(
          amount: 20,
          startAt: start,
          completed: showPinned == true ? true : null,
        ),
      );

      if (isInitial) {
        if (fetched.isNotEmpty) {
          todos = [...todos, ...fetched];
        }
      } else {
        todos = fetched;
        initialLoading = false;
      }

      notifyListeners();

      return fetched;
    } catch (e) {
      if (!isInitial) {
        todos = [];
        initialLoading = false;
        notifyListeners();
      }

      return [];
    } finally {
      if (isInitial) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  // void addFakeMessage(SyMessage message) {
  //   messages.insert(0, message);
  //   notifyListeners();
  // }

  // void removeFakeMessage(int id) {
  //   messages.removeWhere((x) => x.id == id);
  //   notifyListeners();
  // }

  void disposeController() {
    client.events.off(SyEvents.dispatchTodoUpdate, _todoUpdateCallback);
    client.events.off(SyEvents.dispatchTodoCreate, _todoCreateCallback);
    client.events.off(SyEvents.dispatchTodoDelete, _todoDeleteCallback);
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}

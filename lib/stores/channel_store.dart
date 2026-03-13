import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';

class ChannelStore extends ChangeNotifier {
  final Map<int, SyChannel> _channels = {};

  SyChannel? operator [](int id) => _channels[id];

  void set(SyChannel channel) {
    _channels[channel.id] = channel;
    notifyListeners();
  }

  void remove(int id) {
    _channels.remove(id);
    notifyListeners();
  }

  Iterable<SyChannel> get all => _channels.values;
}

final channelStore = ChannelStore();

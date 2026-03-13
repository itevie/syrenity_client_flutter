import 'package:flutter/material.dart';

class CurrentSettingsState extends ChangeNotifier {
  int? serverId;
  int? channelId;

  void setServer(int id) {
    serverId = id;
    channelId = null;
    notifyListeners();
  }

  void setChannel(int id) {
    channelId = id;
    notifyListeners();
  }
}

final currentSettingsStore = CurrentSettingsState();

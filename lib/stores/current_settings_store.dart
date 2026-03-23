import 'package:flutter/material.dart';

class CurrentSettingsState extends ChangeNotifier {
  int? serverId;
  int? channelId;
  bool memberBarShown = false;

  void setMemberBarShown(bool val) {
    memberBarShown = val;
    notifyListeners();
  }

  void setServer(int? id) {
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

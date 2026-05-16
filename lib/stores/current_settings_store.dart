import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/widgets/prominent_banner.dart';

class CurrentSettingsState extends ChangeNotifier {
  int? serverId;
  int? channelId;
  bool sidebarShown = false;
  ProminentBannerDetails? prominentBannerDetails = ProminentBannerDetails(
    color: Colors.red,
    text: "Hello, you're gay!",
    button: (
      "hello",
      (c) {
        print("hi");
        currentSettingsStore.setProminentBannerDetails(null);
      },
    ),
  );

  void setProminentBannerDetails(ProminentBannerDetails? details) {
    prominentBannerDetails = details;
    notifyListeners();
  }

  void setSidebarShown(bool val) {
    sidebarShown = val;
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

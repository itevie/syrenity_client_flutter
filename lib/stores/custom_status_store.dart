import 'package:flutter/material.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class CustomStatusStore extends ChangeNotifier {
  final Map<int, SyCustomStatus> _customStatuses = {};

  SyCustomStatus? operator [](int id) => _customStatuses[id];

  void set(SyCustomStatus customStatus) {
    _customStatuses[customStatus.userId] = customStatus;
    notifyListeners();
  }

  void remove(int id) {
    _customStatuses.remove(id);
    notifyListeners();
  }

  Iterable<SyCustomStatus> get all => _customStatuses.values;
}

final customStatuStore = CustomStatusStore();

import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';

class SettingListener extends StatelessWidget {
  final SettingKeys setting;
  final Widget child;
  final Widget? hiddenChild;

  const SettingListener({
    super.key,
    required this.setting,
    required this.child,
    this.hiddenChild,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsStorage.instance.notifierFor<bool>(setting),
      builder: (context, value, _) {
        if (value) {
          return child;
        }
        return hiddenChild ?? const SizedBox.shrink();
      },
    );
  }
}

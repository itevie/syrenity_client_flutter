import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/show_top_overlay.dart';

void showCopyChip(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));

  if (!SettingsStorage.instance.getSetting<bool>(
    SettingKeys.showCopiedToClipboardFlout,
  )) {
    return;
  }

  showTopOverlay(context, "Copied To Clipboard");
}

ContextMenuButton makeCopyContextMenuButton(
  BuildContext context,
  String name,
  String value,
) {
  return ContextMenuButton(
    onPressed: () async {
      showCopyChip(context, value);
    },
    label: "Copy $name",
    icon: Icons.copy,
  );
}

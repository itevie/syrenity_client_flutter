import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';

enum SettingKeys {
  showSendMessageButton(
    storageKey: "chatbar_send_message_button",
    defaultValue: false,
  ),
  showGifPickerButton(
    storageKey: "chatbar_gif_picker_button",
    defaultValue: true,
  ),
  showEmojiPickerButton(
    storageKey: "chatbar_emoji_picker_button",
    defaultValue: true,
  ),

  showCopiedToClipboardFlout(
    storageKey: "show_copied_to_clipboard_flyout",
    defaultValue: true,
  ),

  developerMode(storageKey: "developer_mode", defaultValue: false);

  final String storageKey;
  final bool defaultValue;

  const SettingKeys({required this.storageKey, required this.defaultValue});
}

class SettingParts {
  static final showSendMessageButton = ChecklistSettingPart(
    name: "Send Message Button",
    description: "Show a send message button in the chatbar.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>(
            SettingKeys.showSendMessageButton.storageKey,
          ) ??
          SettingKeys.showSendMessageButton.defaultValue;
    },
    defaultValue: SettingKeys.showSendMessageButton.defaultValue,
    callback: (value) {
      SettingsStorage.instance.set<bool>(
        SettingKeys.showSendMessageButton.storageKey,
        value,
      );
    },
  );

  static final showGifPickerButton = ChecklistSettingPart(
    name: "Gif Picker Button",
    description: "Show the gif picker in the charbar.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>(
            SettingKeys.showGifPickerButton.storageKey,
          ) ??
          SettingKeys.showGifPickerButton.defaultValue;
    },
    defaultValue: SettingKeys.showGifPickerButton.defaultValue,
    callback: (value) {
      SettingsStorage.instance.set<bool>(
        SettingKeys.showGifPickerButton.storageKey,
        value,
      );
    },
  );

  static final showEmojiPickerButton = ChecklistSettingPart(
    name: "Emoji Picker Button",
    description: "Show the emoji picker in the charbar.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>(
            SettingKeys.showEmojiPickerButton.storageKey,
          ) ??
          SettingKeys.showEmojiPickerButton.defaultValue;
    },
    defaultValue: SettingKeys.showEmojiPickerButton.defaultValue,
    callback: (value) {
      SettingsStorage.instance.set<bool>(
        SettingKeys.showEmojiPickerButton.storageKey,
        value,
      );
    },
  );

  static final showCopiedToClipboardFlout = ChecklistSettingPart(
    name: "Copied To Clipboard",
    description:
        "Show the flyout in the top left when copying something to the clipboard.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>(
            SettingKeys.showCopiedToClipboardFlout.storageKey,
          ) ??
          SettingKeys.showCopiedToClipboardFlout.defaultValue;
    },
    defaultValue: SettingKeys.showCopiedToClipboardFlout.defaultValue,
    callback: (value) {
      SettingsStorage.instance.set<bool>(
        SettingKeys.showCopiedToClipboardFlout.storageKey,
        value,
      );
    },
  );

  static final developerMode = ChecklistSettingPart(
    name: "Developer Mode",
    description: "Show copy IDs in context menus.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>(
            SettingKeys.developerMode.storageKey,
          ) ??
          SettingKeys.developerMode.defaultValue;
    },
    defaultValue: SettingKeys.developerMode.defaultValue,
    callback: (value) {
      SettingsStorage.instance.set<bool>(
        SettingKeys.developerMode.storageKey,
        value,
      );
    },
  );
}

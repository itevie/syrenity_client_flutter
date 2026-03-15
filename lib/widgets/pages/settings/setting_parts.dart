import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';

final _showSendMessageButtonDefault = false;
final _showGifPickerButtonDefault = true;

class SettingParts {
  static final showSendMessageButton = ChecklistSettingPart(
    name: "Show Send Message Button",
    description: "Show a send message button in the chatbar.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>(
            "chatbar_send_message_button",
          ) ??
          _showSendMessageButtonDefault;
    },
    defaultValue: _showSendMessageButtonDefault,
    callback: (value) {
      SettingsStorage.instance.set<bool>("chatbar_send_message_button", value);
    },
  );

  static final showGifPickerButton = ChecklistSettingPart(
    name: "Show Send Gif Picker Button",
    description: "Show the gif picker in the charbar.",
    provideValue: () async {
      return SettingsStorage.instance.get<bool>("chatbar_gif_picker_button") ??
          _showGifPickerButtonDefault;
    },
    defaultValue: _showGifPickerButtonDefault,
    callback: (value) {
      SettingsStorage.instance.set<bool>("chatbar_gif_picker_button", value);
    },
  );
}

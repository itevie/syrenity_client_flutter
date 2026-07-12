import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings_widgets/page_switch_part.dart';

class SettingsPartRenderer extends StatefulWidget {
  final List<SettingPart> parts;
  const SettingsPartRenderer({super.key, required this.parts});

  @override
  State<StatefulWidget> createState() => _SettingsPartRendererState();
}

class _SettingsPartRendererState extends State<SettingsPartRenderer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.parts.map((part) {
          return switch (part) {
            ChecklistSettingPart() => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(part.description),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PartInput(part: part, key: Key(part.name)),
                  ],
                ),
              ),
            ),
            StringSettingPart() => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(part.description),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PartInput(part: part, key: Key(part.name)),
                  ],
                ),
              ),
            ),
            SeperatorSettingPart(:final name) => Row(
              children: [
                Text(name),
                const SizedBox(width: 8),
                const Expanded(child: Divider()),
              ],
            ),
            PageSwitchSettingPart() => pageSwitchPart(
              part.name,
              part.description,
              part.onTap,
            ),
          };
        }),
      ],
    );
  }
}

class _PartInput extends StatefulWidget {
  final SettingPart part;
  const _PartInput({required this.part, super.key});

  @override
  State<StatefulWidget> createState() => _PartInputState();
}

class _PartInputState extends State<_PartInput> {
  dynamic currentValue;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.part is ChecklistSettingPart) {
      currentValue =
          (widget.part as ChecklistSettingPart).defaultValue as bool?;
    } else if (widget.part is StringSettingPart) {
      currentValue = (widget.part as StringSettingPart).defaultValue as String?;
    }

    loadValue();
  }

  void loadValue() async {
    dynamic value;
    if (widget.part is ChecklistSettingPart) {
      value = await (widget.part as ChecklistSettingPart).provideValue();
    } else if (widget.part is StringSettingPart) {
      value = await (widget.part as StringSettingPart).provideValue();
      _controller.text = value ?? "";
    }

    setState(() {
      currentValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;

    switch (part) {
      case ChecklistSettingPart(:final name, :final callback):
        if (currentValue is! bool?) {
          print(
            "ERROR! In checklist value was not a bool, resetting to default value",
          );
          currentValue = false;
        }

        return Checkbox(
          key: Key(name),
          value: currentValue as bool?,
          onChanged: (value) async {
            if (value == null) return;
            callback(value);
            loadValue();
          },
        );

      case StringSettingPart(:final name, :final callback):
        return SizedBox(
          width: 200,
          child: TextFormField(
            key: Key(name),
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter value..."),
            onChanged: (value) {
              callback(value);
            },
          ),
        );

      default:
        return Text("Fail");
    }
  }
}

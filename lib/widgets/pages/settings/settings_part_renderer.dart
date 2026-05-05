import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_part_def.dart';

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
                    _PartInput(part: part),
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
            PageSwitchSettingPart() => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                onTap: part.onTap,
                borderRadius: BorderRadius.circular(
                  12,
                ), // optional, matches Card
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(part.description),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          };
        }),
      ],
    );
  }
}

class _PartInput extends StatefulWidget {
  final SettingPart part;
  const _PartInput({required this.part});

  @override
  State<StatefulWidget> createState() => _PartInputState();
}

class _PartInputState extends State<_PartInput> {
  dynamic currentValue;

  @override
  void initState() {
    super.initState();

    if (widget.part is ChecklistSettingPart) {
      currentValue = (widget.part as ChecklistSettingPart).defaultValue;
    }

    loadValue();
  }

  void loadValue() async {
    if (widget.part is ChecklistSettingPart) {
      final loadedValue =
          await (widget.part as ChecklistSettingPart).provideValue();

      setState(() {
        currentValue = loadedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;

    switch (part) {
      case ChecklistSettingPart(:final name, :final callback):
        return Checkbox(
          key: Key(name),
          value: currentValue as bool,
          onChanged: (value) async {
            if (value == null) return;
            callback(value);
            loadValue();
          },
        );

      default:
        return Text("Fail");
    }
  }
}

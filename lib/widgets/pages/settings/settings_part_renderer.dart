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
        ...widget.parts.map(
          (part) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    // <-- important
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
        ),
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
    currentValue = widget.part.defaultValue;
    loadValue();
  }

  void loadValue() async {
    final loadedValue = await widget.part.provideValue();

    setState(() {
      currentValue = loadedValue;
    });
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

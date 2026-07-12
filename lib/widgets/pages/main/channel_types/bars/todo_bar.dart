import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class TodoBar extends StatefulWidget {
  final SyTodoChannel? channel;

  const TodoBar({super.key, required this.channel});

  @override
  State<TodoBar> createState() => _TodoBarState();
}

class _TodoBarState extends State<TodoBar> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  void _createTodo() async {
    await widget.channel?.send(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      color: colors.inversePrimary,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Shortcuts(
                shortcuts: const {
                  SingleActivator(LogicalKeyboardKey.enter): _SendIntent(),
                },
                child: Actions(
                  actions: {
                    _SendIntent: CallbackAction<_SendIntent>(
                      onInvoke: (intent) {
                        _createTodo();
                        return null;
                      },
                    ),
                  },
                  child: TextField(
                    focusNode: _focusNode,
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          "Type a todo for #${widget.channel?.name ?? "Loading..."}",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendIntent extends Intent {
  const _SendIntent();
}

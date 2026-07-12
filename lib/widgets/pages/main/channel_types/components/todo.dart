import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/todo_cm.dart';
import 'package:syrenity_client_flutter/widgets/message_markdown.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class TodoWidget extends StatefulWidget {
  final SyTodoItem todo;
  const TodoWidget({super.key, required this.todo});

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title:
            (SettingsStorage.instance.getSetting<bool>(
                  SettingKeys.parseMarkdownInMessages,
                ))
                ? MessageMarkdown(
                  parsed: SyContentParser(lex(widget.todo.name)).parse(),
                )
                : Text(widget.todo.name),
        leading: Checkbox(
          key: Key(widget.todo.id.toString()),
          value: widget.todo.completed,
          onChanged: (value) async {
            await widget.todo.edit(
              TodoEditOptions(completed: !widget.todo.completed),
            );
          },
        ),
        trailing: ContextMenu(
          onTapToo: true,
          items:
              () => makeTodoContextMenu(
                context,
                client.user,
                widget.todo,
                edit: () {},
              ),
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class MessageMarkdown extends StatelessWidget {
  final SyParserResponse parsed;
  const MessageMarkdown({super.key, required this.parsed});

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: _build(parsed.tokens)));
  }
}

List<TextSpan> _build(List<ParserToken> tokens) {
  final widgets = <TextSpan>[];

  for (final token in tokens) {
    switch (token) {
      case TextParserToken(:final text):
        widgets.add(TextSpan(text: text));
        break;
      case ItalicParserToken(:final children):
        widgets.add(
          TextSpan(
            children: _build(children),
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        );
        break;
      case UnderlineParserToken(:final children):
        widgets.add(
          TextSpan(
            children: _build(children),
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        );
        break;
      case BoldParserToken(:final children):
        widgets.add(
          TextSpan(
            children: _build(children),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        break;
      case TextParserTokenGroup(:final children):
        widgets.add(TextSpan(children: _build(children)));
        break;

      // ignore: unreachable_switch_default
      default:
        if (MainCallbacks.showError != null) {
          MainCallbacks.showError!(
            Exception("Cannot handle: ${token.toString()}"),
          );
        }
    }
  }

  return widgets;
}

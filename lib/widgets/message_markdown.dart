import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class MessageMarkdown extends StatelessWidget {
  final SyParserResponse parsed;
  final bool isSending;
  const MessageMarkdown({
    super.key,
    required this.parsed,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: _build(parsed.tokens, isSending)));
  }
}

List<TextSpan> _build(List<ParserToken> tokens, bool isSending) {
  final widgets = <TextSpan>[];

  Color? color = isSending ? Colors.grey : null;

  for (final token in tokens) {
    switch (token) {
      case TextParserToken(:final text):
        widgets.add(TextSpan(text: text, style: TextStyle(color: color)));
        break;
      case ItalicParserToken(:final children):
        widgets.add(
          TextSpan(
            children: _build(children, isSending),
            style: TextStyle(fontStyle: FontStyle.italic, color: color),
          ),
        );
        break;
      case LinkParserToken(:final url):
        widgets.add(
          TextSpan(
            text: url,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blue,
            ),
          ),
        );
        break;
      case UnderlineParserToken(:final children):
        widgets.add(
          TextSpan(
            children: _build(children, isSending),
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: color,
            ),
          ),
        );
        break;
      case BoldParserToken(:final children):
        widgets.add(
          TextSpan(
            children: _build(children, isSending),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        );
        break;
      case TextParserTokenGroup(:final children):
        widgets.add(
          TextSpan(
            children: _build(children, isSending),
            style: TextStyle(color: color),
          ),
        );
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

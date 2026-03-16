import 'package:syrenity_client_flutter/syrenity_client/content_parser/lexer.dart';
import 'package:syrenity_client_flutter/syrenity_client/content_parser/parser_tokens.dart';

class SyParserResponse {
  final List<ParserToken> tokens;

  SyParserResponse(this.tokens);
}

class SyContentParser {
  final List<LexicalToken> tokens;
  int position = 0;

  SyContentParser(this.tokens);

  bool get isAtEnd => position >= tokens.length;

  LexicalToken? peek([int offset = 0]) {
    final index = position + offset;
    if (index >= tokens.length) return null;
    return tokens[index];
  }

  LexicalToken advance() {
    return tokens[position++];
  }

  /// Parses the full token stream
  SyParserResponse parse() {
    final result = <ParserToken>[];

    while (!isAtEnd) {
      final token = parseNext();
      if (token != null) result.add(token);
    }

    return SyParserResponse(result);
  }

  /// Tries to parse the next token (including nested ones)
  ParserToken? parseNext() {
    final token = peek();
    if (token == null) return null;

    switch (token.type) {
      case LexicalTokenType.underscore:
        return parseEnclosed(
          startType: LexicalTokenType.underscore,
          endType: LexicalTokenType.underscore,
          onMatch: (children) => UnderlineParserToken(children),
        );

      case LexicalTokenType.italic:
        return parseEnclosed(
          startType: LexicalTokenType.italic,
          endType: LexicalTokenType.italic,
          onMatch: (children) => ItalicParserToken(children),
        );

      case LexicalTokenType.bold:
        return parseEnclosed(
          startType: LexicalTokenType.bold,
          endType: LexicalTokenType.bold,
          onMatch: (children) => BoldParserToken(children),
        );

      case LexicalTokenType.text:
        return TextParserToken(advance().value);

      default:
        // fallback: treat any unknown token as text
        return TextParserToken(advance().value);
    }
  }

  /// Generic parser for enclosed tokens (_…_, *…*, etc.) that supports nested content
  ParserToken parseEnclosed({
    required LexicalTokenType startType,
    required LexicalTokenType endType,
    required ParserToken Function(List<ParserToken> children) onMatch,
  }) {
    if (peek()?.type != startType) {
      // Not a start token, just return null (or call parseNext fallback)
      throw Exception("parseEnclosed called on wrong token");
    }

    advance(); // consume opening token

    final children = <ParserToken>[];
    bool foundClosing = false;

    while (!isAtEnd) {
      final token = peek()!;
      if (token.type == endType) {
        advance(); // consume closing
        foundClosing = true;
        break;
      }

      final child = parseNext();
      if (child != null) {
        children.add(child);
      } else {
        // fallback: consume as text
        children.add(TextParserToken(advance().value));
      }
    }

    if (foundClosing) {
      return onMatch(children);
    } else {
      // No closing token → treat opening as text + all collected children as text
      final fallback = <ParserToken>[
        TextParserToken(startTypeToChar(startType)),
      ];
      fallback.addAll(children);
      return TextParserTokenGroup(fallback);
    }
  }

  String startTypeToChar(LexicalTokenType type) {
    switch (type) {
      case LexicalTokenType.underscore:
        return "_";
      case LexicalTokenType.italic:
        return "*";
      case LexicalTokenType.bold:
        return "**";
      default:
        return "";
    }
  }
}

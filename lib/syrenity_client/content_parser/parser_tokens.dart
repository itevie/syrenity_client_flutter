enum ParserTokenType { text, underline, italic, bold }

sealed class ParserToken {
  final ParserTokenType type;

  ParserToken({required this.type});
}

class TextParserToken extends ParserToken {
  final String text;

  TextParserToken(this.text) : super(type: ParserTokenType.text);

  @override
  String toString() => "Text('$text')";
}

class UnderlineParserToken extends ParserToken {
  final List<ParserToken> children;

  UnderlineParserToken(this.children) : super(type: ParserTokenType.underline);

  @override
  String toString() => "Underline($children)";
}

class ItalicParserToken extends ParserToken {
  final List<ParserToken> children;

  ItalicParserToken(this.children) : super(type: ParserTokenType.italic);

  @override
  String toString() => "Italic($children)";
}

class BoldParserToken extends ParserToken {
  final List<ParserToken> children;

  BoldParserToken(this.children) : super(type: ParserTokenType.bold);

  @override
  String toString() => "Bold($children)";
}

class TextParserTokenGroup extends ParserToken {
  final List<ParserToken> children;

  TextParserTokenGroup(this.children) : super(type: ParserTokenType.text);

  @override
  String toString() => "Text($children)";
}

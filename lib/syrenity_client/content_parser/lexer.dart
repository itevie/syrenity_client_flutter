enum LexicalTokenType {
  bold,
  italic,
  boldItalic,
  underscore,
  code,
  openAngle,
  closeAngle,
  at,
  hashtag,
  file, // f:
  server, // s:
  strikeThrough, // ~~
  link,
  text,
}

class LexicalToken {
  final LexicalTokenType type;
  final String value;

  const LexicalToken(this.type, this.value);

  @override
  String toString() => "LexicalToken($type, '$value')";
}

List<LexicalToken> lex(String contents) {
  final tokens = <LexicalToken>[];
  final buffer = StringBuffer();

  int i = 0;

  void flushText() {
    if (buffer.isNotEmpty) {
      tokens.add(LexicalToken(LexicalTokenType.text, buffer.toString()));
      buffer.clear();
    }
  }

  while (i < contents.length) {
    final c = contents[i];

    // multi-char tokens
    if (contents.startsWith("***", i)) {
      flushText();
      tokens.add(LexicalToken(LexicalTokenType.boldItalic, "***"));
      i += 3;
      continue;
    }

    if (contents.startsWith("**", i)) {
      flushText();
      tokens.add(LexicalToken(LexicalTokenType.bold, "**"));
      i += 2;
      continue;
    }

    if (contents.startsWith("~~", i)) {
      flushText();
      tokens.add(LexicalToken(LexicalTokenType.strikeThrough, "~~"));
      i += 2;
      continue;
    }

    if (contents.startsWith("f:", i)) {
      flushText();
      tokens.add(LexicalToken(LexicalTokenType.file, "f:"));
      i += 2;
      continue;
    }

    if (contents.startsWith("s:", i)) {
      flushText();
      tokens.add(LexicalToken(LexicalTokenType.server, "s:"));
      i += 2;
      continue;
    }

    // single-char tokens
    switch (c) {
      case "*":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.italic, "*"));
        i++;
        continue;

      case "_":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.underscore, "_"));
        i++;
        continue;

      case "`":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.code, "`"));
        i++;
        continue;

      case "<":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.openAngle, "<"));
        i++;
        continue;

      case ">":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.closeAngle, ">"));
        i++;
        continue;

      case "@":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.at, "@"));
        i++;
        continue;

      case "#":
        flushText();
        tokens.add(LexicalToken(LexicalTokenType.hashtag, "#"));
        i++;
        continue;
    }

    // default text
    buffer.write(c);
    i++;
  }

  flushText();
  return tokens;
}

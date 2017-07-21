import ceylon.json {
    ParseException,
    StringTokenizer,
    Tokenizer,
    Visitor,
    parseJsonString = parseKeyOrString,
    parseJsonNumber = parseNumber
}

"Parse #t, #T, #f, #F, consuming any initial whitespace."
shared Boolean parseBool(Tokenizer tokenizer) {
    tokenizer.eatSpacesUntil('#');
    switch (character = tokenizer.character())
    case ('t'|'T') {
        tokenizer.eatChar();
        return true;
    }
    case ('f'|'F') {
        tokenizer.eatChar();
        return false;
    }
    else {
        throw ParseException(
            """Invalid value: expecting #t, #T, #f, #F,
               but got #``c``""",
            tokenizer.line, tokenizer.column);
    }
}

"Parse a String literal, consuming any initial whitespace"
shared String parseKeyOrString(Tokenizer tokenizer) {
    return parseJsonString(tokenizer);
}

"Parse a number, consuming any initial whitespace."
shared Integer|Float parseNumber(Tokenizer tokenizer) {
    return parseJsonNumber(tokenizer);
}

"Parses an SEXP string into an SEXP value"
throws(`class Exception`, "the SEXP string is invalid")
shared Value parse(String string) {
    value builder = Builder();
    value parser = Parser(StringTokenizer(string), builder);
    parser.parse();
    return builder.result;
}

"A parser for SEXP data presented as a Tokenizer which calls
 the given visitor for each matched rule.

 To construct a JSON model the visitor would be a [[Builder]]."
shared class Parser(tokenizer, visitor) {

    "The data to be parsed."
    Tokenizer tokenizer;

    "The visitor to called for each matched rule."
    shared Visitor visitor;

    void parsePair() {
        tokenizer.eatSpacesUntil('(');
        String key = parseKeyOrString(tokenizer);
        if (tokenizer.isSpace(tokenizer.eatChar())) {
            tokenizer.eatSpacesUntil('.');
            if (tokenizer.isSpace(tokenizer.eatChar())) {
                visitor.onKey(key);
                parseValue();
                tokenizer.eatSpacesUntil(')');
            }
        }
        tokenizer.eatSpaces();
    }

    void parseObject() {
        visitor.onStartObject();
        for (c in "hash(") {
            tokenizer.eat(c);
        }
        tokenizer.eatSpaces();
        while (!tokenizer.check(')')) {
            parsePair();
        }
        visitor.onEndObject();
    }

    void parseElements() {
        while (!tokenizer.check(')')) {
            tokenizer.eatSpaces();
            parseValue();
            Character c = tokenizer.eatChar();
            if (!tokenizer.isSpace(c)) {
                switch (c)
                case (')') {
                    return;
                }
                else {
                    throw ParseException(
                        "Invalid value: expecting ) to end the array, but got ``c``",
                        tokenizer.line, tokenizer.column);
                }
            }
        }
    }

    void parseArray(){
        visitor.onStartArray();
        tokenizer.eatSpacesUntil('(');
        parseElements();
        visitor.onEndArray();
    }

    throws(`class ParseException`,
        "If the specified string cannot be parsed")
    shared void parseValue() {
        tokenizer.eatSpaces();
        switch (c = tokenizer.character())
        case ('#') {
            parseSpecial();
        }
        case ('(') {
            parseArray();
        }
        case ('"') {
            visitor.onString(parseKeyOrString(tokenizer));
        }
        case ('0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9'|'-') {
            visitor.onNumber(parseNumber(tokenizer));
        }
        else {
            throw ParseException(
                "Invalid value: expecting object, array, string, " +
                "number, true, false, null but got `` c ``",
                tokenizer.line, tokenizer.column);
        }
    }

    void parseSpecial() {
        tokenizer.eat('#');
        switch (c = tokenizer.character())
        case ('t'|'T') {
            tokenizer.eat(c);
            visitor.onBoolean(true);
        }
        case ('f'|'F') {
            tokenizer.eat(c);
            visitor.onBoolean(false);
        }
        case ('h') {
            parseObject();
        }
        else {
            throw ParseException(
                """Invalid value: expecting #t, #T, #f, #F, or #hash,
                   but got `` c ``""",
                tokenizer.line, tokenizer.column);
        }
    }

    shared void parse() {
        parseValue();
        tokenizer.eatSpaces();
        if (tokenizer.hasMore) {
            throw ParseException("Unexpected extra characters", tokenizer.line, tokenizer.column);
        }
    }
}


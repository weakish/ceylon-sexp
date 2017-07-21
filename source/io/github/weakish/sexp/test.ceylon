import ceylon.test {
    test,
    assertTrue,
    assertFalse,
    assertThatException,
    assertEquals
}
import ceylon.json {
    StringTokenizer,
    ParseException,
    parseKeyOrString
}

test void canParseBool() {
    assertTrue(parseBool(StringTokenizer("#t")));
    assertTrue(parseBool(StringTokenizer("#T")));
    assertFalse(parseBool(StringTokenizer("#f")));
    assertFalse(parseBool(StringTokenizer("#F")));
    assertThatException(
                () => parseBool(StringTokenizer("true"))
    ).hasType(`ParseException`);
}

test void canParseKeyOrString() {
    assertEquals(
        parseKeyOrString(StringTokenizer("\"a string\"")),
        "a string");
    assertEquals(
        parseKeyOrString(StringTokenizer("\"backslash \\\" escaping\"")),
        "backslash \" escaping");
}

test void parseInvalidString() {
    assertThatException(
                () => parseKeyOrString(StringTokenizer("noQuotes"))
    ).hasType(`ParseException`);
    assertThatException(
                () => parseKeyOrString(StringTokenizer("123"))
    ).hasType(`ParseException`);
}

test void canParseInteger() {
    assertEquals(
        parseNumber(StringTokenizer("123")), 123);
    assertEquals(parseNumber(StringTokenizer("0")), 0);
}

test void canParseFloat() {
    assertEquals(parseNumber(StringTokenizer("0.0")), 0.0);
    assertEquals(parseNumber(StringTokenizer("3.14")), 3.14);
}

test void canParseNegative() {
    assertEquals(parseNumber(StringTokenizer("-1")), -1);
    assertEquals(parseNumber(StringTokenizer("-3.14")), -3.14);
}

test void parseInvalidNumber() {
    assertThatException(
                () => parseNumber(StringTokenizer("\"123\""))
    ).hasType(`ParseException`);
    assertThatException(
                () => parseNumber(StringTokenizer("#t"))
    ).hasType(`ParseException`);
}

test void canParseOneElementArray() {
    String sexp = "(1)";
    Value parsed = parse(sexp);
    assert (is SexpArray parsed);
    assertEquals(parsed.first, 1);
}

test void canParseSimpleArray() {
    String sexp = "(1 2 3)";
    Value parsed = parse(sexp);
    assert (is SexpArray parsed);
    assertEquals(parsed.first, 1);
}

test void canParseBoolArray() {
    String sexp = "(#t #f)";
    Value parsed = parse(sexp);
    assert (is SexpArray parsed);
    assertEquals(parsed.first, true);
}


test void canParseNestedArray() {
    String sexp = """((1 2 3) ("a" "b" "c") (0 #f))""";
    Value parsed = parse(sexp);
    assert (is SexpArray parsed);
    assert (is SexpArray firstArray = parsed.first);
    assertEquals(firstArray.first, 1);
    assert (is SexpArray lastArray = parsed.last);
    assertEquals(lastArray.last, false);
}


test void parseUnmatchedParens() {
    assertThatException(
                () => parse("""((1 2 3) ("a" "b" "c") (0 #f)""")
    ).hasType(`ParseException`);
}

test void parseSimpleObject() {
    String sexp = """#hash(("a" . 1) ("b" . 2))""";
    Value parsed = parse(sexp);
    assert (is SexpObject parsed);
    assertEquals(parsed["b"], 2);
}

test void canParseSimpleSException() {
    String sexp = """#hash(("name" . "Introduction to Ceylon")
                      ("authors" . ("Stef Epardaud" "Emmanuel Bernard")))""";
    Value parsed = parse(sexp);

    assert (is SexpObject parsed);
    assertEquals(parsed.getString("name"), "Introduction to Ceylon");

    assert (is SexpArray authors = parsed["authors"]);
    assertEquals(authors.first, "Stef Epardaud");
    assertEquals(authors.last, "Emmanuel Bernard");

}

test void parseUnknownType() {
    String sexp = """#set(1 2 3)""";
    assertThatException(() => parse(sexp)).hasType(`ParseException`);

}

test void bracketsAndBracesAreNotSupported() {
    assertThatException(() => parse("[1, 2, 3]")).hasType(`ParseException`);
    String sexp = """#hash{("name" . Introduction to Ceylon)
                      ("authors" . ["Stef Epardaud" "Emmanuel Bernard"])}""";
    assertThatException(() => parse(sexp)).hasType(`ParseException`);
}

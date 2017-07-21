import ceylon.collection {
    ArrayList
}
import ceylon.json {
    Visitor,
    jsonVisit = visit
}
import ceylon.language.meta {
    type
}


shared final sealed annotation class LicensedUnderAnnotation(
        shared String description)
        satisfies OptionalAnnotation<LicensedUnderAnnotation> {}

shared annotation LicensedUnderAnnotation licensedUnder(String description)
        => LicensedUnderAnnotation(description);

"A [[Visitor]] that constructs a [[Value]].

 This would usually be used in conjunction with
 a [[Parser]]."
by("Tom Bentley", "Jakukyo Friel")
licensedUnder("[Apache-2.0](https://github.com/ceylon/ceylon-sdk/blob/master/LICENSE)")
shared class Builder() satisfies Visitor {

    ArrayList<Value> stack = ArrayList<Value>();

    variable String? currentKey = null;

    "The constructed [[Value]]."
    throws(`class AssertionError`,
        "The builder has not yet seen enough input to return a fully formed JSON value.")
    shared Value result {
        if (stack.size == 1,
            ! currentKey exists) {
            Value? element = stack.pop();
            assert (exists element);
            return element;
        } else {
            throw AssertionError("currenyKey=``currentKey else "null" ``, stack=``stack``");
        }
    }

    void addToCurrent(Value v) {
        value current = stack.last;
        switch(current)
        case (is SexpObject) {
            if (exists ck=currentKey) {
                if (exists old = current.put(ck, v)) {
                    throw AssertionError("duplicate key ``ck``");
                }
                currentKey = null;
            } else {
                "value within object without key"
                assert(false);
            }
        }
        case (is SexpArray) {
            current.add(v);
        }
        case (is Null) {

        }
        else {
            throw AssertionError("cannot add value to ``type(current)``");
        }
    }

    void push(Value v) {
        if (stack.empty) {
            stack.push(v);
        }
        if (v is SexpObject|SexpArray) {
            stack.push(v);
        }
    }

    void pop() {
        stack.pop();
    }

    shared actual void onStartObject() {
        SexpObject newObj = SexpObject{};
        addToCurrent(newObj);
        push(newObj);
    }
    shared actual void onKey(String key) {
        this.currentKey = key;
    }

    shared actual void onEndObject() {
        pop();
    }
    shared actual void onStartArray() {
        SexpArray newArray = SexpArray();
        addToCurrent(newArray);
        push(newArray);
    }

    shared actual void onEndArray() {
        pop();
    }
    shared actual void onNumber(Integer|Float num) {
        addToCurrent(num);
        push(num);
    }
    shared actual void onBoolean(Boolean bool) {
        addToCurrent(bool);
        push(bool);
    }

    shared actual void onString(String string) {
        addToCurrent(string);
        push(string);
    }

    shared actual void onNull() {}
}

"Recursively visit the given subject using the given visitor. If
 [[sortedKeys]] is true then the keys of Objects will be visited
 in alphabetical order"
shared void visit(subject, visitor, sortedKeys=false) {
    "The value to visit."
    Value subject;
    "The visitor to apply."
    Visitor visitor;
    "Whether keys should be visited in alphabetical order, when visiting objects."
    Boolean sortedKeys;

    jsonVisit(subject, visitor, sortedKeys);
}
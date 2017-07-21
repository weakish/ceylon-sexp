import ceylon.json {
    JsonObject
}


"S-expression object (hashmap)."
shared class SexpObject({<String->Value>*} values = {})
        extends JsonObject(values) {}

import ceylon.json {
    JsonObject
}
shared class SexpObject({<String->Value>*} values = {})
        extends JsonObject(values) {}

import ceylon.json {
    JsonArray
}

"S-expression array."
shared class SexpArray({Value*} values = {}) extends JsonArray(values) {}
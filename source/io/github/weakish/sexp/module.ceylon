"""A subset of S-expressions as a lightweight data-interchange format.

   S-expressions is an elegant markup: simple, unambiguius, and easy to parse.

   ```lisp
   (value
    (#t #f
     string number
     (object
      (#hash()
       #hash(pairs)))
     (array
      (()
       (values))))

   (pair
    (string . value))

   (pairs
    (pair
     (pair values)))

   (values
    (value
     (value values)))
   ```

   Unlike JSON, a value cannot be null.

   Example:

   Suppose we have a strip containing the following s-expression:

   ```lisp
   #hash(("name" . "Introduction to Ceylon")
         ("authors" . ("Stef Epardaud" "Emmanuel Bernard")))
   ```

   We can `parse` it as following:

   ```ceylon
   String get_name(String sexp) {
     Value parsed = parse(sexp);
     assert (is SexpObject parsed);
     return parsed.getString("name");
   }
   ```
   """
module io.github.weakish.sexp "0.0.0" {
    shared import ceylon.json "1.3.2";
    import ceylon.test "1.3.2";
}

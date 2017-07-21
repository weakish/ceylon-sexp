S-expression subset as a data-interchange format
================================================

Syntax
------

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

Features
--------

Currently there is a demo implementation in Ceylon.

- [x] compatible with JVM and JavaScript backend
- [x] decode (parsing)
- [x] `#hash` (syntax from Racket)
- [ ] remove `#T`/`#F` for simplicity (r6s6 does not support them)
- [ ] comment `;`
- [ ] bracket (requires matching)
- [ ] encode
- [ ] customized

Doc
---

<https://weakish.github.io/ceylon-sexp/api/>

Contribute
----------

Send issues or pull requests at
<https://github.com/weakish/ceylon-sexp>

License
-------

0BSD except for the Builder class (licensed under Apache-2.0).
See LICENSE for more information.
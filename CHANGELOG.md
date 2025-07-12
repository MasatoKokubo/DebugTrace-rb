## 1.3.0 - July 12, 2025

* Added optional argument `string_as_bytes` (default: `false`) to the `print` method. The string will be output in hexadecimal if it is `true`.
* Hexadecimal output of strings with encoding `ASCII_8BIT` has been discontinued.

## 1.2.0 - July 5, 2025

* Changed source file name output to a relative path from the current directory.
* Added class name to method name output.

## 1.1.2 - July 2, 2025

Fixed a bug that caused exceptions to be thrown by the `print` methods depending on the conditions.

## 1.1.1 - July 1, 2025

Fixed a bug that caused exceptions to be thrown by the `enter`, `leave` and `print` methods depending on the conditions.

## 1.1.0 - May 25, 2025

### Bug fix

* Fixed a bug where line breaks were not inserted between elements when outputting `Array`, `Hash`, and `Set` using the print method.

### Specification changes

* Changed the following keyword argument names for the `print` method, and also changed the property names of the same names in `debugtrace.yml`.
    * `output_size_limit` ← `collection_limit`
    * `output_length_limit` ← `string_limit` and `bytes_limit` _(Unified)_

## 1.0.1 - May 19, 2025

Fixed a bug that caused an error if the environment variable `DEBUGTRACE_CONFIG` was not set.

## 1.0.0 - May 18, 2025

This is the initial release.

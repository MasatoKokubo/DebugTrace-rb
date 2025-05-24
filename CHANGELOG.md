## 1.1.0 - May 25, 2025

### Bug fixes

* Fixed a bug where line breaks were not inserted between elements when outputting `Array`, `Hash`, and `Set` using the print method.

### Specification changes

* Changed the following keyword argument names for the `print` method, and also changed the property names of the same names in `debugtrace.yml`.
    * `output_size_limit` ← `collection_limit`
    * `output_length_limit` ← `string_limit` and `bytes_limit` _(Unified)_

## 1.0.1 - May 19, 2025

Fixed a bug that caused an error if the environment variable `DEBUGTRACE_CONFIG` was not set.

## 1.0.0 - May 18, 2025

This is the initial release.

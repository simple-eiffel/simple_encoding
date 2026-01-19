# CURRENT STATE SPECIFICATION: simple_encoding

**Generated:** 2026-01-19
**Version:** 1.0 (pre-enhancement)

---

## Executive Summary

simple_encoding is a pure Eiffel library providing UTF-8 <-> UTF-32 encoding/decoding. It has a single facade class (SIMPLE_ENCODING) with 42 passing tests covering basic conversion, adversarial inputs, stress scenarios, and edge cases.

**Status:** Production ready for UTF-8/UTF-32 conversion. Ready for enhancement to add additional codecs.

---

## Library Overview

| Item | Value |
|------|-------|
| **Name** | simple_encoding |
| **UUID** | E3A8F9C2-5B7D-4A6E-8F1C-D2B3E4A5F6C7 |
| **Purpose** | UTF-8 <-> UTF-32 encoding/decoding |
| **Source Classes** | 1 |
| **Test Classes** | 5 |
| **Total Tests** | 42 (all passing) |
| **Dependencies** | base, simple_testing |

---

## Class Structure

### SIMPLE_ENCODING (Facade)

**Purpose:** Bidirectional conversion between STRING_32 (UTF-32/Unicode) and STRING_8 (UTF-8 bytes).

**Public Interface:**

| Feature | Type | Signature |
|---------|------|-----------|
| make | Creation | make |
| utf_32_to_utf_8 | Query | (a_utf32: READABLE_STRING_32): STRING_8 |
| utf_8_to_utf_32 | Query | (a_utf8: READABLE_STRING_8): STRING_32 |
| has_error | Query | BOOLEAN |
| last_error | Query | STRING_32 |

**Contracts:**

| Feature | Precondition | Postcondition |
|---------|--------------|---------------|
| utf_32_to_utf_8 | string_not_void | result_not_void, empty_preserved |
| utf_8_to_utf_32 | string_not_void | result_not_void, empty_preserved |

**Invariant:** last_error_not_void

---

## Encoding Rules (RFC 3629)

| Code Point Range | Bytes | Pattern |
|------------------|-------|---------|
| U+0000..U+007F | 1 | 0xxxxxxx |
| U+0080..U+07FF | 2 | 110xxxxx 10xxxxxx |
| U+0800..U+FFFF | 3 | 1110xxxx 10xxxxxx 10xxxxxx |
| U+10000..U+10FFFF | 4 | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx |

---

## Error Handling

Invalid sequences produce:
1. Replacement character U+FFFD in output
2. Error message appended to last_error
3. Continued processing of remaining input

Invalid conditions handled:
- Code points > U+10FFFF
- Invalid leading bytes (0x80-0xBF, 0xFE, 0xFF, 0xF5+)
- Truncated multi-byte sequences
- Missing continuation bytes

---

## Test Coverage

| Suite | Tests | Focus |
|-------|-------|-------|
| ENCODING_TESTS | 10 | Basic roundtrip, byte counts, error tracking |
| ADVERSARIAL_TESTS | 18 | Boundaries, surrogates, invalid bytes, BOM |
| STRESS_TESTS | 10 | Long strings, repeated ops, error sequences |
| BUG_HUNT_TESTS | 4 | F4-F7 leading byte edge cases |

**Baseline Result:** 42 passed, 0 failed

---

## Known Limitations

1. **Surrogates:** Encodes U+D800-U+DFFF without error (debatable - invalid in UTF-32)
2. **Overlong:** May not detect all overlong encodings (security concern)
3. **Streaming:** No support for incremental/streaming conversion
4. **Other encodings:** Only UTF-8/UTF-32 supported

---

## Enhancement Targets

Per enhancement spec (05_simple_encoding_enhancements.md):

### New Classes to Add

1. **SIMPLE_CODEC** - Abstract base for all codecs
2. **SIMPLE_ISO_8859_1_CODEC** - Latin-1
3. **SIMPLE_ISO_8859_15_CODEC** - Latin-9 (Euro)
4. **SIMPLE_WINDOWS_1252_CODEC** - Windows Western European
5. **SIMPLE_CODEC_REGISTRY** - Codec lookup by name
6. **SIMPLE_CHARACTER_PROPERTIES** - Unicode character classification
7. **SIMPLE_ENCODING_DETECTOR** - Auto-detect encoding

### Design Goals

- All codecs implement common interface
- Bidirectional encode/decode
- Strong validation contracts
- Table-driven for efficiency

---

## Configuration

**ECF Settings:**
- void_safety: all
- concurrency: scoop supported
- assertions: all enabled

---

## Files

| Path | Purpose |
|------|---------|
| simple_encoding.ecf | Library configuration |
| src/simple_encoding.e | Main implementation |
| testing/*.e | Test classes (5 files) |
| specs/ | Specification documents |
| hardening/ | Previous hardening work |
| audit/ | Previous audit work |

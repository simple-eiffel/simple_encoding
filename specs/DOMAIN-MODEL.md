# Domain Model: simple_encoding

**Generated:** 2026-01-19
**Phase:** DISCOVERY (Spec Extraction - Step 2)

---

## PROBLEM DOMAIN

This library addresses **character encoding conversion** - specifically the bidirectional transformation between UTF-32 (Unicode code points stored in STRING_32) and UTF-8 (variable-length byte sequences stored in STRING_8). It handles the complexities of multi-byte encoding including error detection and graceful degradation for invalid sequences.

---

## CORE CONCEPTS

| Concept | Definition |
|---------|------------|
| **UTF-32** | Fixed-width Unicode encoding where each code point uses 32 bits (one STRING_32 character = one code point) |
| **UTF-8** | Variable-width Unicode encoding using 1-4 bytes per code point |
| **Code Point** | A numeric value in the Unicode space (0x0000 to 0x10FFFF) |
| **Encoding** | The process of converting code points to byte sequences |
| **Decoding** | The process of converting byte sequences back to code points |
| **Replacement Character** | U+FFFD, used when an invalid sequence is encountered |
| **BOM** | Byte Order Mark (U+FEFF), optional marker at start of encoded text |

---

## RELATIONSHIPS

```
[STRING_32] ──contains──> [Code Points (NATURAL_32)]
     │
     │ utf_32_to_utf_8
     ▼
[SIMPLE_ENCODING] ──produces──> [STRING_8 (UTF-8 bytes)]
     │
     │ utf_8_to_utf_32
     ▼
[STRING_8] ──decoded-to──> [STRING_32]
     │
     └──may-produce──> [Replacement Character + Error Message]
```

**Key Relationships:**
- SIMPLE_ENCODING **transforms** STRING_32 to STRING_8 (encoding)
- SIMPLE_ENCODING **transforms** STRING_8 to STRING_32 (decoding)
- SIMPLE_ENCODING **tracks** errors via last_error
- Invalid input **produces** replacement characters (U+FFFD)

---

## DOMAIN VOCABULARY

| Term | Source | Definition |
|------|--------|------------|
| utf_32 | Feature parameter | STRING_32 containing Unicode code points |
| utf_8 | Feature parameter | STRING_8 containing UTF-8 encoded bytes |
| code point | Note clause | Single Unicode character value (0-0x10FFFF) |
| leading byte | Implementation | First byte of a multi-byte UTF-8 sequence |
| continuation byte | Implementation | Subsequent bytes (0x80-0xBF) in multi-byte sequence |
| replacement character | Implementation | U+FFFD used for invalid sequences |
| roundtrip | Tests | Encoding then decoding returns original input |

---

## RESPONSIBILITY ALLOCATION

### CLASS: SIMPLE_ENCODING

| Aspect | Description |
|--------|-------------|
| **Domain Concept** | Character encoding converter |
| **Primary Responsibility** | Bidirectional conversion between UTF-32 and UTF-8 |
| **Collaborators** | None (standalone) |
| **State** | `last_error: STRING_32` - accumulated error messages |
| **Behavior** | Encode UTF-32 to UTF-8, Decode UTF-8 to UTF-32, Track errors |

**Feature Responsibilities:**

| Feature | Responsibility |
|---------|---------------|
| `make` | Initialize converter with empty error state |
| `utf_32_to_utf_8` | Convert Unicode string to UTF-8 bytes |
| `utf_8_to_utf_32` | Convert UTF-8 bytes to Unicode string |
| `has_error` | Query whether last conversion encountered errors |
| `last_error` | Access accumulated error messages |
| `append_replacement_and_error` | (private) Handle invalid sequences |

---

## DOMAIN INVARIANTS

### SIMPLE_ENCODING Invariant

```eiffel
invariant
    last_error_not_void: last_error /= Void
```

| Rule | Domain Meaning |
|------|----------------|
| `last_error_not_void` | Error tracking is always available; converter is always in a valid state to report errors |

### Implicit Domain Rules (from contracts)

| Rule | Enforcement |
|------|-------------|
| Input must not be Void | Precondition: string_not_void |
| Output is never Void | Postcondition: result_not_void |
| Empty input produces empty output | Postcondition: empty_preserved |
| Invalid sequences produce replacement (U+FFFD) | Implementation behavior |
| Errors are cleared on each new conversion | Implementation behavior |

---

## UTF-8 ENCODING RULES (Domain Knowledge)

The library implements RFC 3629 UTF-8 encoding:

| Code Point Range | Byte Count | Pattern |
|------------------|------------|---------|
| U+0000..U+007F | 1 | 0xxxxxxx |
| U+0080..U+07FF | 2 | 110xxxxx 10xxxxxx |
| U+0800..U+FFFF | 3 | 1110xxxx 10xxxxxx 10xxxxxx |
| U+10000..U+10FFFF | 4 | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx |

**Invalid Sequences Handled:**
- Leading bytes 0x80-0xBF (continuation-only)
- Leading bytes 0xF5-0xFF (would exceed U+10FFFF)
- Truncated multi-byte sequences
- Code points > U+10FFFF

---

## OPEN QUESTIONS

1. **Surrogate handling**: Tests show surrogates (U+D800-U+DFFF) are encoded without error. Should they be rejected? (They're only valid in UTF-16)

2. **Overlong detection**: Tests show overlong sequences may not be detected (C0 80 for NULL). Security-critical applications require rejection.

3. **Streaming**: Current API requires complete strings. Should streaming conversion be supported for large files?

4. **Additional encodings**: Enhancement spec proposes ISO-8859-x, Windows-125x codecs. Current design has no codec abstraction.

---

## ENHANCEMENT IMPLICATIONS

The proposed enhancements require:

1. **SIMPLE_CODEC** - Abstract base class for all encoders
2. **Codec interface** - Standardized encode/decode signatures
3. **SIMPLE_CODEC_REGISTRY** - Factory for codec lookup by name
4. **SIMPLE_ENCODING_DETECTOR** - Heuristic encoding detection

Current SIMPLE_ENCODING could become SIMPLE_UTF8_CODEC or be refactored to use a codec internally.

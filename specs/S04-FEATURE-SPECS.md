# S04: Feature Specifications - simple_encoding

## Priority Features

1. `utf_32_to_utf_8` - Main API, complex algorithm, multiple code paths
2. `utf_8_to_utf_32` - Main API, complex algorithm, multiple code paths

---

# FEATURE SPECIFICATION: SIMPLE_ENCODING.utf_32_to_utf_8

## Signature
```eiffel
utf_32_to_utf_8 (a_utf32: READABLE_STRING_32): STRING_8
```

## Purpose
Convert a UTF-32 encoded string (where each CHARACTER_32 is a Unicode code point) to UTF-8 byte sequence. This is the standard conversion for preparing Unicode text for I/O, network transmission, or file storage.

## Behavior (Algorithm)

1. Create result buffer sized at 4x input (worst case: all 4-byte sequences)
2. Clear error state (`last_error.wipe_out`)
3. For each character in input:
   - Get code point value
   - If code <= 0x7F: emit 1 byte (ASCII)
   - If code <= 0x7FF: emit 2 bytes (Latin extended, etc.)
   - If code <= 0xFFFF: emit 3 bytes (BMP, including CJK)
   - If code <= 0x10FFFF: emit 4 bytes (supplementary planes, emoji)
   - Else: emit U+FFFD (3 bytes), record error

## Code Paths

| Path | Condition | Outcome | Lines |
|------|-----------|---------|-------|
| A | `code <= 0x7F` | 1 ASCII byte | 52-54 |
| B | `code <= 0x7FF` | 2 bytes: 110xxxxx 10xxxxxx | 55-58 |
| C | `code <= 0xFFFF` | 3 bytes: 1110xxxx 10xxxxxx 10xxxxxx | 59-63 |
| D | `code <= 0x10FFFF` | 4 bytes: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx | 64-69 |
| E | `code > 0x10FFFF` | 3-byte U+FFFD + error | 70-77 |

## Contracts

### Existing (lines 40-41, 81-83)
```eiffel
require
    string_not_void: a_utf32 /= Void
ensure
    result_not_void: Result /= Void
    empty_preserved: a_utf32.is_empty implies Result.is_empty
```

### Recommended Additions
```eiffel
ensure
    -- Error tracking
    all_valid_implies_no_error: (across a_utf32 as c all c.code <= 0x10FFFF end) implies not has_error

    -- Length bounds (ASCII = 1x, all 4-byte = 4x)
    length_lower_bound: Result.count >= a_utf32.count
    length_upper_bound: Result.count <= a_utf32.count * 4
```

## State Changes

| Attribute | Before | After |
|-----------|--------|-------|
| last_error | any | empty (if all valid) OR contains error messages |

## Input Validation

| Parameter | Type | Valid | Invalid |
|-----------|------|-------|---------|
| a_utf32 | READABLE_STRING_32 | Any non-void string | Void |

**Note:** Code points > 0x10FFFF are HANDLED (not rejected) - they produce replacement characters.

## Output Specification

| Aspect | Value |
|--------|-------|
| Type | STRING_8 |
| Meaning | UTF-8 encoded byte sequence |
| Range | 0 to 4×input.count bytes |
| Relationship | Decoding with utf_8_to_utf_32 yields original (if no errors) |

## Edge Cases

| Case | Input | Behavior | Tested |
|------|-------|----------|--------|
| Empty string | "" | Returns "" | test_empty_string |
| ASCII only | "Hello" | 1 byte per char | test_ascii_roundtrip |
| Latin extended | "Café" | 2 bytes for é | test_latin_extended |
| CJK characters | "中文" | 3 bytes each | test_cjk_characters |
| Emoji | "😀" | 4 bytes | test_emoji_4byte |
| Mixed | "Hi中😀" | Variable | test_mixed_content |

## Test Coverage

| Test | Aspect Tested |
|------|---------------|
| test_ascii_roundtrip | 1-byte path, roundtrip |
| test_latin_extended | 2-byte path, roundtrip |
| test_cjk_characters | 3-byte path, byte count |
| test_emoji_4byte | 4-byte path, byte count |
| test_empty_string | Empty input handling |
| test_mixed_content | All paths in one string |
| test_utf8_byte_counts | Correct byte counts |

### Untested Aspects
- Code points > 0x10FFFF (error path E)
- Very long strings (performance)
- Strings with embedded NULLs (U+0000)

---

# FEATURE SPECIFICATION: SIMPLE_ENCODING.utf_8_to_utf_32

## Signature
```eiffel
utf_8_to_utf_32 (a_utf8: READABLE_STRING_8): STRING_32
```

## Purpose
Convert UTF-8 encoded bytes back to UTF-32 string (Unicode code points). This is used when reading text from files, network, or external sources.

## Behavior (Algorithm)

1. Create result buffer sized at input length (worst case: all ASCII)
2. Clear error state (`last_error.wipe_out`)
3. While bytes remain:
   - Read leading byte
   - Determine sequence length from leading byte pattern
   - If ASCII (0xxxxxxx): emit code point, advance 1
   - If 2-byte (110xxxxx): verify continuation, decode, advance 2
   - If 3-byte (1110xxxx): verify continuations, decode, advance 3
   - If 4-byte (11110xxx): verify continuations, decode, advance 4
   - Else: emit U+FFFD, record error, advance 1

## Code Paths

| Path | Condition | Outcome | Lines |
|------|-----------|---------|-------|
| A | `byte1 <= 0x7F` | Direct ASCII code point | 103-106 |
| B | `(byte1 & 0xE0) = 0xC0` + valid cont | 2-byte decode | 107-122 |
| C | `(byte1 & 0xF0) = 0xE0` + valid conts | 3-byte decode | 123-139 |
| D | `(byte1 & 0xF8) = 0xF0` + valid conts | 4-byte decode | 140-157 |
| E | Invalid leading byte | U+FFFD + error | 158-161 |
| F | Missing continuation | U+FFFD + error | 116-117, 119-121, etc. |
| G | Invalid continuation | U+FFFD + error | 115-117, 132-134, 150-152 |

## Contracts

### Existing (lines 90-91, 164-166)
```eiffel
require
    string_not_void: a_utf8 /= Void
ensure
    result_not_void: Result /= Void
    empty_preserved: a_utf8.is_empty implies Result.is_empty
```

### Recommended Additions
```eiffel
ensure
    -- Length bounds (1-4 UTF-8 bytes = 1 code point)
    length_lower_bound: Result.count >= a_utf8.count // 4
    length_upper_bound: Result.count <= a_utf8.count
```

## State Changes

| Attribute | Before | After |
|-----------|--------|-------|
| last_error | any | empty (if valid UTF-8) OR contains error positions |

## Input Validation

| Parameter | Type | Valid | Invalid |
|-----------|------|-------|---------|
| a_utf8 | READABLE_STRING_8 | Any non-void byte sequence | Void |

**Note:** Invalid UTF-8 is HANDLED with replacement characters, not rejected.

## Output Specification

| Aspect | Value |
|--------|-------|
| Type | STRING_32 |
| Meaning | Unicode code points |
| Range | 0 to input.count characters |
| Relationship | Encoding with utf_32_to_utf_8 yields original bytes (if no errors) |

## Edge Cases

| Case | Input | Behavior | Tested |
|------|-------|----------|--------|
| Empty string | "" | Returns "" | test_empty_string |
| Valid ASCII | 0x41 | U+0041 | test_ascii_roundtrip |
| Valid 2-byte | 0xC3 0xA9 | U+00E9 | test_latin_extended |
| Valid 3-byte | 0xE4 0xB8 0xAD | U+4E2D | test_cjk_characters |
| Valid 4-byte | 0xF0 0x9F 0x98 0x80 | U+1F600 | test_emoji_4byte |
| Invalid leading | 0x80 | U+FFFD + error | test_invalid_utf8_sequence |
| Truncated seq | 0xC3 0x58 | U+FFFD U+0058 + error | test_truncated_utf8 |

## Test Coverage

| Test | Aspect Tested |
|------|---------------|
| test_ascii_roundtrip | 1-byte decoding |
| test_latin_extended | 2-byte decoding |
| test_cjk_characters | 3-byte decoding |
| test_emoji_4byte | 4-byte decoding |
| test_empty_string | Empty input |
| test_mixed_content | Mixed sequences |
| test_invalid_utf8_sequence | Invalid leading byte |
| test_truncated_utf8 | Invalid continuation |
| test_error_tracking | Error state management |

### Untested Aspects
- Overlong encodings (e.g., C0 80 for NULL)
- Surrogate code points in UTF-8 (ED A0 80 to ED BF BF)
- Very long strings (performance)
- All bytes being continuation bytes

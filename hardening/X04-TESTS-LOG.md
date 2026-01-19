# X04: Adversarial Tests Log - simple_encoding

## Date: 2026-01-18

## Tests Written

| Test Name | Category | Input | Purpose |
|-----------|----------|-------|---------|
| test_max_ascii_boundary | Boundaries | U+007F, U+0080 | 1-byte vs 2-byte boundary |
| test_max_2byte_boundary | Boundaries | U+07FF, U+0800 | 2-byte vs 3-byte boundary |
| test_max_3byte_boundary | Boundaries | U+FFFF, U+10000 | 3-byte vs 4-byte boundary |
| test_max_valid_codepoint | Boundaries | U+10FFFF | Max valid Unicode |
| test_beyond_max_codepoint | Boundaries | U+110000 | Beyond max valid |
| test_overlong_2byte_null | Overlong | C0 80 | Overlong NULL encoding |
| test_overlong_3byte_slash | Overlong | E0 80 AF | Overlong "/" encoding |
| test_surrogate_high | Surrogates | U+D800 | High surrogate |
| test_surrogate_low | Surrogates | U+DFFF | Low surrogate |
| test_invalid_leading_0x80 | Invalid | 0x80 | Continuation-only byte as lead |
| test_invalid_leading_0xFF | Invalid | 0xFF | Never-valid byte |
| test_invalid_leading_0xFE | Invalid | 0xFE | Never-valid byte |
| test_null_character_encode | NULL | U+0000 | NULL encoding |
| test_null_character_decode | NULL | 0x00 | NULL decoding |
| test_reuse_after_error | State | error then valid | Error state clearing |
| test_multiple_conversions_same_instance | State | 3 strings | Reuse behavior |
| test_bom_encoding | BOM | U+FEFF | BOM encoding |
| test_bom_decoding | BOM | EF BB BF | BOM decoding |

## Compilation Output

```
Eiffel Compilation Manager
Version 25.02.9.8732 - win64

Degree 6: Examining System
Degree 5: Parsing Classes
Degree 4: Analyzing Inheritance
Degree 3: Checking Types
Degree 2: Generating Byte Code
Freezing System Changes
Degree -1: Generating Code
System Recompiled.
...
C compilation completed
```

## Test Execution Output

```
Running SIMPLE_ENCODING tests...

=== UTF-8/UTF-32 Conversion Tests ===
  PASS: test_ascii_roundtrip
  PASS: test_latin_extended
  PASS: test_cjk_characters
  PASS: test_emoji_4byte
  PASS: test_empty_string
  PASS: test_mixed_content
  PASS: test_utf8_byte_counts
  PASS: test_invalid_utf8_sequence
  PASS: test_truncated_utf8
  PASS: test_error_tracking

=== ADVERSARIAL TESTS ===
  PASS: test_max_ascii_boundary
  PASS: test_max_2byte_boundary
  PASS: test_max_3byte_boundary
  PASS: test_max_valid_codepoint
  PASS: test_beyond_max_codepoint
  PASS: test_overlong_2byte_null
  PASS: test_overlong_3byte_slash
  PASS: test_surrogate_high
  PASS: test_surrogate_low
  PASS: test_invalid_leading_0x80
  PASS: test_invalid_leading_0xFF
  PASS: test_invalid_leading_0xFE
  PASS: test_null_character_encode
  PASS: test_null_character_decode
  PASS: test_reuse_after_error
  PASS: test_multiple_conversions_same_instance
  PASS: test_bom_encoding
  PASS: test_bom_decoding

========================
Results: 28 passed, 0 failed
ALL TESTS PASSED
```

## Results

| Category | Tests | Pass | Fail | Notes |
|----------|-------|------|------|-------|
| Original | 10 | 10 | 0 | Baseline preserved |
| Boundaries | 5 | 5 | 0 | All boundary transitions correct |
| Overlong | 2 | 2 | 0 | See findings below |
| Surrogates | 2 | 2 | 0 | See findings below |
| Invalid bytes | 3 | 3 | 0 | Proper error handling |
| NULL chars | 2 | 2 | 0 | Proper NULL handling |
| State | 2 | 2 | 0 | Proper state management |
| BOM | 2 | 2 | 0 | Proper BOM handling |
| **Total** | **28** | **28** | **0** | - |

## Security Findings

### FINDING-001: Overlong Encodings Accepted
- **Tests**: test_overlong_2byte_null, test_overlong_3byte_slash
- **Behavior**: Overlong sequences are decoded without error
- **Risk**: MEDIUM - Security vulnerability (directory traversal, filter bypass)
- **Standard**: RFC 3629 Section 10 requires rejection of overlong forms
- **Status**: Documented (not a crash, but violates RFC)

### FINDING-002: Surrogate Code Points Encoded
- **Tests**: test_surrogate_high, test_surrogate_low
- **Behavior**: U+D800..U+DFFF are encoded to UTF-8 without error
- **Risk**: LOW - Produces invalid Unicode, but won't crash
- **Standard**: Unicode Standard Section 3.9 forbids isolated surrogates
- **Status**: Documented (not a crash, but violates Unicode Standard)

## Files Modified

- `testing/adversarial_tests.e` - Created with 18 adversarial tests
- `testing/test_app.e` - Added adversarial test runner

## VERIFICATION CHECKPOINT

```
Compilation: SUCCESS
Tests Run: 28
Tests Passed: 28
Tests Failed: 0
Security Findings: 2 (MEDIUM: overlong, LOW: surrogates)
```

# X01: Reconnaissance - simple_encoding

## Date: 2026-01-18

## Baseline Verification

### Compilation
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

### Test Run
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

========================
Results: 10 passed, 0 failed
ALL TESTS PASSED
```

### Baseline Status
- Compiles: YES
- Tests: 10 pass, 0 fail
- Warnings: 0

## Source Files

| File | Class | Lines | Features | Contracts |
|------|-------|-------|----------|-----------|
| simple_encoding.e | SIMPLE_ENCODING | 199 | 5 total (4 public, 1 private) | 4 pre, 4 post, 1 inv |

## Public API Analysis

### SIMPLE_ENCODING

| Feature | Type | Params | Pre | Post | Risk |
|---------|------|--------|-----|------|------|
| make | creation | none | 0 | 0 | LOW |
| utf_32_to_utf_8 | query+side-effect | READABLE_STRING_32 | 1 | 2 | HIGH |
| utf_8_to_utf_32 | query+side-effect | READABLE_STRING_8 | 1 | 2 | HIGH |
| has_error | query | none | 0 | 0 | LOW |
| last_error | attribute | none | 0 | 0 | LOW |

## Contract Coverage Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total public features | 4 | 100% |
| With preconditions | 2 | 50% |
| With postconditions | 2 | 50% |
| Classes with invariants | 1/1 | 100% |

## Attack Surface Priority

### High (Unprotected/Complex public features)
1. `SIMPLE_ENCODING.utf_32_to_utf_8` - Accepts any STRING_32, processes code points, complex algorithm
2. `SIMPLE_ENCODING.utf_8_to_utf_32` - Accepts any STRING_8, parses byte sequences, complex algorithm

**Attack vectors:**
- Malformed input (invalid UTF-8 sequences)
- Boundary values (code points near limits)
- Overlong encodings (security vulnerability)
- Surrogate code points (invalid Unicode)
- Huge strings (resource exhaustion)
- Embedded NULLs

### Medium (Partial protection)
None - the two main features are either fully at risk or simple.

### Low (Simple/Protected)
1. `SIMPLE_ENCODING.make` - No parameters
2. `SIMPLE_ENCODING.has_error` - Simple derived query
3. `SIMPLE_ENCODING.last_error` - Simple attribute access

## VERIFICATION CHECKPOINT

```
Compilation output: [PASTED - System Recompiled]
Test output: [PASTED - 10 pass, 0 fail]
Source files read: 1
Attack surfaces listed: 2 HIGH, 3 LOW
hardening/X01-RECON-ACTUAL.md: [CREATED]
```

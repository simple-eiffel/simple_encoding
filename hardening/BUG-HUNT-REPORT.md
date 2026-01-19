# Bug Hunt Report: simple_encoding

## Date: 2026-01-18

## Summary

**4 BUGS FOUND** - All related to missing range validation in UTF-8 decoder

## Bug Details

### BUG-001: F5 Leading Byte Accepted
- **Input**: F5 90 80 80
- **Produced**: Code point 1376256 (0x150000)
- **Expected**: Error (exceeds U+10FFFF)
- **Severity**: MEDIUM
- **RFC 3629**: F5-FF bytes MUST be rejected

### BUG-002: F4 90+ Sequences Accepted
- **Input**: F4 90 80 80
- **Produced**: Code point 1114112 (0x110000)
- **Expected**: Error (exceeds U+10FFFF = 1114111)
- **Severity**: MEDIUM
- **RFC 3629**: F4 must be followed by 80-8F (not 90-BF)

### BUG-003: F6 Leading Byte Accepted
- **Input**: F6 80 80 80
- **Produced**: Code point 1572864 (0x180000)
- **Expected**: Error (exceeds U+10FFFF)
- **Severity**: MEDIUM
- **RFC 3629**: F6 byte MUST be rejected

### BUG-004: F7 Leading Byte Accepted
- **Input**: F7 80 80 80
- **Produced**: Code point 1835008 (0x1C0000)
- **Expected**: Error (exceeds U+10FFFF)
- **Severity**: MEDIUM
- **RFC 3629**: F7 byte MUST be rejected

## Root Cause

In `utf_8_to_utf_32`, the 4-byte sequence check uses:
```eiffel
elseif (byte1 & 0xF8) = 0xF0 then
```

This matches F0-F7 (11110xxx pattern), but:
- F5-F7 ALWAYS produce code points > U+10FFFF
- F4 needs additional validation (byte2 must be 80-8F)

## RFC 3629 Requirements

Valid 4-byte sequences per RFC 3629:
```
F0 90-BF 80-BF 80-BF  (U+10000..U+3FFFF)
F1-F3 80-BF 80-BF 80-BF  (U+40000..U+FFFFF)
F4 80-8F 80-BF 80-BF  (U+100000..U+10FFFF)
```

Invalid bytes that must be rejected:
- F5-FF as leading bytes (NEVER valid)
- F4 followed by 90-BF (would exceed U+10FFFF)

## Fix Required

In `utf_8_to_utf_32`, modify the 4-byte sequence handling:

1. Reject F5-F7 as leading bytes (change mask check)
2. For F4, verify byte2 is 80-8F (not 90-BF)
3. Or: After decoding, check code <= 0x10FFFF

## Test Evidence

```
=== BUG HUNT TESTS ===
  BUG: F5 90 80 80 accepted, produced: 1376256
  FAIL: test_f5_leading_byte
  BUG: F4 90 80 80 accepted, produced: 1114112
  FAIL: test_f4_90_boundary
  BUG: F6 80 80 80 accepted, produced: 1572864
  FAIL: test_f6_leading_byte
  BUG: F7 80 80 80 accepted, produced: 1835008
  FAIL: test_f7_leading_byte

Results: 38 passed, 4 failed
```

## Files Created

- `testing/bug_hunt_tests.e` - 4 tests exposing the bugs
- `testing/test_app.e` - Modified to include bug hunt tests
- `hardening/BUG-HUNT-REPORT.md` - This document

## Verification Checkpoint

```
Bugs Found: 4
Severity: All MEDIUM
Category: RFC compliance / range validation
Fix Complexity: LOW (simple conditional check)
```

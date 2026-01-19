# Bug Fix Report: simple_encoding

## Date: 2026-01-18

## Summary

Fixed 4 bugs related to UTF-8 decoding of invalid byte sequences that would produce code points > U+10FFFF.

## Bugs Fixed

| Bug | Description | Status |
|-----|-------------|--------|
| BUG-001 | F5 leading byte accepted | FIXED |
| BUG-002 | F4 90+ sequences accepted | FIXED |
| BUG-003 | F6 leading byte accepted | FIXED |
| BUG-004 | F7 leading byte accepted | FIXED |

## Changes Made

### File: src/simple_encoding.e

**Location**: Line 140 (4-byte sequence handling)

**Before**:
```eiffel
elseif (byte1 & 0xF8) = 0xF0 then
    -- 4-byte sequence
    ...
    code := ((byte1 & 0x07) |<< 18) | ...
    Result.append_code (code)
    i := i + 4
```

**After**:
```eiffel
elseif (byte1 & 0xF8) = 0xF0 and byte1 <= 0xF4 then
    -- 4-byte sequence (F0-F4 only; F5-F7 would exceed U+10FFFF)
    ...
    code := ((byte1 & 0x07) |<< 18) | ...
    if code > 0x10FFFF then
        -- Code point exceeds max valid Unicode (e.g., F4 90+)
        append_replacement_and_error (Result, i)
        i := i + 4
    else
        Result.append_code (code)
        i := i + 4
    end
```

## Fix Details

1. **F5-F7 Rejection**: Added `and byte1 <= 0xF4` to the condition
   - F5-F7 (0xF5-0xF7) now fall through to "Invalid leading byte" handler
   - These bytes ALWAYS produce code points > U+10FFFF

2. **F4 90+ Rejection**: Added `if code > 0x10FFFF` check after decoding
   - F4 80-8F produces valid code points (U+100000..U+10FFFF)
   - F4 90-BF produces invalid code points (U+110000+)
   - Now correctly rejects the latter

## Test Results

**Before Fix**:
```
Results: 38 passed, 4 failed
TESTS FAILED
```

**After Fix**:
```
Results: 42 passed, 0 failed
ALL TESTS PASSED
```

## RFC 3629 Compliance Improvement

| Requirement | Before | After |
|-------------|--------|-------|
| Reject F5-FF | NO | YES |
| Reject F4 90+ | NO | YES |
| Reject > U+10FFFF | PARTIAL | FULL |

## Verification Checkpoint

```
Compilation: SUCCESS
Tests: 42 passed, 0 failed
Bugs Fixed: 4
Regression: None
```

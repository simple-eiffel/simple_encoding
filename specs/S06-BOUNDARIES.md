# S06: Boundary Specifications - simple_encoding

## Edge Cases

### Empty Input Cases
| Case | Feature | Behavior | Tested |
|------|---------|----------|--------|
| Empty STRING_32 | utf_32_to_utf_8("") | Returns "" | YES: test_empty_string |
| Empty STRING_8 | utf_8_to_utf_32("") | Returns "" | YES: test_empty_string |

### Single Element Cases
| Case | Feature | Behavior | Tested |
|------|---------|----------|--------|
| Single ASCII | utf_32_to_utf_8("A") | 1 byte | YES: test_utf8_byte_counts |
| Single 2-byte | utf_32_to_utf_8(é) | 2 bytes | YES: test_utf8_byte_counts |
| Single 3-byte | utf_32_to_utf_8(中) | 3 bytes | YES: test_utf8_byte_counts |
| Single 4-byte | utf_32_to_utf_8(😀) | 4 bytes | YES: test_utf8_byte_counts |

### Boundary Value Cases

#### Code Point Boundaries
| Boundary | Value | UTF-8 Bytes | Tested |
|----------|-------|-------------|--------|
| Max ASCII | U+007F (127) | 1 byte | NO |
| Min 2-byte | U+0080 (128) | 2 bytes | NO |
| Max 2-byte | U+07FF (2047) | 2 bytes | NO |
| Min 3-byte | U+0800 (2048) | 3 bytes | NO |
| Max BMP | U+FFFF (65535) | 3 bytes | NO |
| Min supplementary | U+10000 (65536) | 4 bytes | NO |
| Max valid | U+10FFFF (1114111) | 4 bytes | NO |
| Beyond max | U+110000+ | ERROR | NO |

#### UTF-8 Leading Byte Boundaries
| Byte | Meaning | Tested |
|------|---------|--------|
| 0x00-0x7F | ASCII | YES |
| 0x80-0xBF | Continuation only | YES: test_invalid_utf8_sequence |
| 0xC0-0xDF | 2-byte lead | Partial |
| 0xE0-0xEF | 3-byte lead | Partial |
| 0xF0-0xF7 | 4-byte lead | Partial |
| 0xF8-0xFF | Invalid | NO |

## Limits

### Numeric Limits
| Parameter | Type | Min | Max | Default |
|-----------|------|-----|-----|---------|
| Code point | NATURAL_32 | 0 | 0x10FFFF | N/A |
| Position | INTEGER | 1 | string.count | 1 |

### Collection Limits
| Collection | Min Size | Max Practical | Empty Allowed |
|------------|----------|---------------|---------------|
| Input string | 0 | Memory limit | YES |
| Output string | 0 | 4× input | YES |
| last_error | 0 | Unbounded | YES |

### String Limits
| Parameter | Min Length | Max Length | Empty Allowed |
|-----------|------------|------------|---------------|
| a_utf32 | 0 | Unbounded | YES |
| a_utf8 | 0 | Unbounded | YES |
| last_error | 0 | Unbounded | YES (means no error) |

## Error Conditions

### Recoverable Errors

#### Invalid UTF-8 Leading Byte
| Aspect | Value |
|--------|-------|
| Trigger | Byte in range 0x80-0xBF or 0xF8-0xFF as leading |
| Handling | U+FFFD replacement, error logged, continue parsing |
| User notification | has_error = True, last_error contains position |
| Recovery | Automatic - processing continues |
| Tested | YES: test_invalid_utf8_sequence |

#### Truncated UTF-8 Sequence
| Aspect | Value |
|--------|-------|
| Trigger | Multi-byte sequence at end without enough bytes |
| Handling | U+FFFD replacement, error logged |
| User notification | has_error = True, last_error contains position |
| Recovery | Automatic - replacement emitted |
| Tested | YES: test_truncated_utf8 |

#### Invalid Continuation Byte
| Aspect | Value |
|--------|-------|
| Trigger | Expected 10xxxxxx but got other pattern |
| Handling | U+FFFD replacement, error logged, retry from bad byte |
| User notification | has_error = True, last_error contains position |
| Recovery | Automatic - processing continues |
| Tested | YES: test_truncated_utf8 |

#### Invalid Code Point (> U+10FFFF)
| Aspect | Value |
|--------|-------|
| Trigger | STRING_32 character with code > 0x10FFFF |
| Handling | U+FFFD (3 bytes) emitted, error logged |
| User notification | has_error = True, last_error contains position |
| Recovery | Automatic - processing continues |
| Tested | NO |

### Fatal Errors

| Error | Cause | Protection |
|-------|-------|------------|
| Precondition violation | Void input | Caller crash (by design) |
| Out of memory | Huge string | None (system handles) |

## Failure Modes

### 1. Silent Data Corruption
| Aspect | Value |
|--------|-------|
| Cause | Overlong UTF-8 encoding not rejected |
| Symptoms | Different byte sequences decode to same character |
| State after | Result appears valid but source was malformed |
| Recovery | None - caller must validate input |
| Contract | MISSING - should check for overlong |

### 2. Invalid Unicode in Result
| Aspect | Value |
|--------|-------|
| Cause | Surrogate code points not rejected |
| Symptoms | STRING_32 contains U+D800..U+DFFF |
| State after | Invalid Unicode that may break downstream |
| Recovery | None - caller must validate |
| Contract | MISSING - should reject surrogates |

## Test Coverage Gaps

### High Priority (need tests)
| Boundary | Risk | Suggested Test |
|----------|------|----------------|
| Code point > U+10FFFF | Error path untested | test_invalid_code_point |
| Overlong encoding | Security vulnerability | test_overlong_rejected |
| Surrogate code points | Invalid Unicode output | test_surrogates_rejected |
| 0xF8-0xFF leading bytes | Edge of invalid range | test_high_invalid_bytes |

### Medium Priority (should test)
| Boundary | Risk | Suggested Test |
|----------|------|----------------|
| Exact boundary values | Off-by-one errors | test_boundary_values |
| Max valid U+10FFFF | Boundary encoding | test_max_code_point |
| Long sequences of same type | Performance/buffer | test_long_ascii_string |
| All continuations bad | Recovery behavior | test_all_bad_continuation |

### Low Priority (nice to test)
| Boundary | Risk | Suggested Test |
|----------|------|----------------|
| U+0000 (NULL) | Embedded nulls | test_null_character |
| BOM (U+FEFF) | BOM handling | test_bom_handling |
| Very long strings | Memory/performance | test_large_strings |

## Defensive Programming Analysis

### Input Validation
| Measure | Location | Protects Against |
|---------|----------|------------------|
| Void check | Preconditions | Null pointer |

### Missing Defensive Measures
| Missing | Where Needed | Protects Against |
|---------|--------------|------------------|
| Overlong check | utf_8_to_utf_32 | Overlong attack |
| Surrogate check | utf_32_to_utf_8 | Invalid Unicode |
| Range check on decode | utf_8_to_utf_32 | Out-of-range code point |
| Input length check | Both features | Pathological input |

## Summary

| Category | Tested | Untested | Gap Priority |
|----------|--------|----------|--------------|
| Empty inputs | 2 | 0 | - |
| Single elements | 4 | 0 | - |
| Boundary values | 4 | 8 | HIGH |
| Error conditions | 3 | 1 | HIGH |
| Failure modes | 0 | 2 | HIGH |

# Formal Specification: simple_encoding

## Version: 1.0
## Date: 2026-01-18
## Status: DRAFT (based on deep research)

## 1. Purpose

SIMPLE_ENCODING provides bidirectional conversion between UTF-32 and UTF-8 encoded strings in Eiffel, following RFC 3629 and Unicode Standard requirements.

## 2. Scope

### In Scope
- UTF-32 to UTF-8 conversion
- UTF-8 to UTF-32 conversion
- Error detection and reporting
- Invalid input handling with replacement characters

### Out of Scope
- UTF-16 encoding/decoding
- Byte order mark handling (pass-through only)
- Normalization (NFC, NFD, etc.)
- Locale-specific operations

## 3. Definitions

| Term | Definition |
|------|------------|
| Code Point | A value in the Unicode code space (0 to 0x10FFFF) |
| UTF-8 | Variable-length encoding using 1-4 bytes per code point |
| UTF-32 | Fixed-length encoding using 4 bytes per code point |
| Surrogate | Code points U+D800..U+DFFF reserved for UTF-16 |
| Overlong | UTF-8 sequence using more bytes than necessary |
| Replacement | U+FFFD, used for unrepresentable/invalid characters |

## 4. Functional Requirements

### FR-01: UTF-32 to UTF-8 Encoding

**Input**: READABLE_STRING_32 (UTF-32 encoded)
**Output**: STRING_8 (UTF-8 encoded)

**Encoding Rules**:
| Input Range | Output Bytes |
|-------------|--------------|
| U+0000..U+007F | 1 byte: 0xxxxxxx |
| U+0080..U+07FF | 2 bytes: 110xxxxx 10xxxxxx |
| U+0800..U+FFFF | 3 bytes: 1110xxxx 10xxxxxx 10xxxxxx |
| U+10000..U+10FFFF | 4 bytes: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx |

**Error Handling**:
- Code points > U+10FFFF: Output U+FFFD, set has_error
- Surrogate code points (U+D800..U+DFFF): [CURRENT: encode; SPEC: should output U+FFFD]

### FR-02: UTF-8 to UTF-32 Decoding

**Input**: READABLE_STRING_8 (UTF-8 encoded)
**Output**: STRING_32 (UTF-32 encoded)

**Decoding Rules**:
| Leading Byte | Sequence Length | Code Point Range |
|--------------|-----------------|------------------|
| 00-7F | 1 byte | U+0000..U+007F |
| C2-DF | 2 bytes | U+0080..U+07FF |
| E0-EF | 3 bytes | U+0800..U+FFFF |
| F0-F4 | 4 bytes | U+10000..U+10FFFF |

**Error Handling**:
- Invalid leading byte (80-BF, C0-C1, F5-FF): Output U+FFFD, set has_error
- Truncated sequence: Output U+FFFD, set has_error
- Invalid continuation byte: Output U+FFFD, set has_error
- Overlong encoding: [CURRENT: decode; SPEC: should output U+FFFD]

### FR-03: Error State Management

- `has_error`: Boolean indicating any error occurred during last conversion
- `last_error`: String describing error (includes position)
- State resets on each new conversion call

## 5. Non-Functional Requirements

### NFR-01: Performance
- Handle strings up to 10,000+ characters without degradation
- No memory leaks on repeated conversions

### NFR-02: Thread Safety
- SCOOP-compatible design
- No shared mutable state between instances

### NFR-03: Void Safety
- All code is void-safe
- No detachable attributes left uninitialized

## 6. Security Requirements (RFC 3629 Section 10)

### SR-01: Overlong Rejection (NOT YET IMPLEMENTED)
- MUST reject overlong sequences
- C0 80 MUST NOT decode to U+0000
- E0 80 AF MUST NOT decode to U+002F

### SR-02: Surrogate Rejection (NOT YET IMPLEMENTED)  
- SHOULD reject surrogate code points in UTF-32 input
- SHOULD reject surrogate byte sequences (ED A0-BF) in UTF-8 input

### SR-03: Range Validation (IMPLEMENTED)
- MUST reject code points > U+10FFFF
- MUST reject bytes F5-FF as leading bytes

## 7. Contracts (Design by Contract)

### Class Invariant
```
last_error /= Void
```

### utf_32_to_utf_8
**Precondition**: `a_string /= Void`
**Postcondition**: `Result /= Void`, output reflects error state

### utf_8_to_utf_32
**Precondition**: `a_string /= Void`
**Postcondition**: `Result /= Void`, output reflects error state

## 8. Compliance Matrix

| Requirement | RFC 3629 | Unicode Std | Status |
|-------------|----------|-------------|--------|
| Valid encoding | 3.1 | Chapter 3 | COMPLIANT |
| Valid decoding | 3.1 | Chapter 3 | COMPLIANT |
| Reject > U+10FFFF | 3.1 | 3.9 | COMPLIANT |
| Reject overlong | 10 | 3.9 | NON-COMPLIANT |
| Reject surrogates | 3 | 3.9 | NON-COMPLIANT |
| Error indication | 10 | - | COMPLIANT |

## 9. Test Coverage Requirements

| Category | Required Tests | Status |
|----------|----------------|--------|
| Basic conversion | Roundtrip for all byte lengths | COVERED (10 tests) |
| Boundary values | All byte-length transitions | COVERED (5 tests) |
| Invalid input | Leading bytes, truncation | COVERED (6 tests) |
| Overlong detection | 2-byte, 3-byte overlong | COVERED (2 tests) |
| Surrogate handling | High/low surrogates | COVERED (2 tests) |
| Stress/volume | Large strings, repetition | COVERED (10 tests) |

## 10. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-18 | Claude | Initial formal specification |

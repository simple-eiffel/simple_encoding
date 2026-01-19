# Deep Research: UTF-8/UTF-32 Encoding Standards

## Date: 2026-01-18

## Research Focus

Understanding the authoritative standards for UTF-8 and UTF-32 encoding to verify simple_encoding compliance.

## Source Documents

### Primary Sources
1. **RFC 3629** - UTF-8, a transformation format of ISO 10646 (November 2003)
   - Author: F. Yergeau, Alis Technologies
   - Status: Internet Standard (STD 63)
   - URL: https://www.rfc-editor.org/rfc/rfc3629.html

2. **Unicode Standard** - Chapter 2: General Structure
   - Version: Unicode 16.0.0 (2024)
   - URL: https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-2/

3. **Unicode FAQ** - UTF-8, UTF-16, UTF-32 & BOM
   - URL: https://unicode.org/faq/utf_bom

## UTF-8 Encoding Rules (RFC 3629)

### Valid Byte Sequences

| Code Point Range | Byte 1 | Byte 2 | Byte 3 | Byte 4 |
|------------------|--------|--------|--------|--------|
| U+0000..U+007F | 00-7F | - | - | - |
| U+0080..U+07FF | C2-DF | 80-BF | - | - |
| U+0800..U+0FFF | E0 | A0-BF | 80-BF | - |
| U+1000..U+CFFF | E1-EC | 80-BF | 80-BF | - |
| U+D000..U+D7FF | ED | 80-9F | 80-BF | - |
| U+E000..U+FFFF | EE-EF | 80-BF | 80-BF | - |
| U+10000..U+3FFFF | F0 | 90-BF | 80-BF | 80-BF |
| U+40000..U+FFFFF | F1-F3 | 80-BF | 80-BF | 80-BF |
| U+100000..U+10FFFF | F4 | 80-8F | 80-BF | 80-BF |

### Invalid Byte Values

The following byte values NEVER appear in valid UTF-8:
- **C0, C1**: Would produce overlong encodings of ASCII
- **F5-FF**: Would produce code points > U+10FFFF

### Surrogate Code Points

U+D800..U+DFFF are **explicitly prohibited** in UTF-8:
- These are reserved for UTF-16 surrogate pairs
- RFC 3629: "the definition of UTF-8 prohibits encoding character numbers between U+D800 and U+DFFF"
- ED leading byte must be followed by 80-9F (not A0-BF) to avoid surrogates

## UTF-32 Encoding Rules

### Value Range
- Valid: 0x00000000..0x0010FFFF
- Invalid: > 0x10FFFF
- Invalid: 0xD800..0xDFFF (surrogates)

### Byte Order
- UTF-32BE: Big-endian (most significant byte first)
- UTF-32LE: Little-endian (least significant byte first)
- BOM 0x0000FEFF indicates big-endian
- BOM 0xFFFE0000 indicates little-endian

### Conformance Requirements
- "When a process generates data in a Unicode Transformation Format, it shall not emit ill-formed byte sequences"
- "When a process interprets data in a Unicode Transformation Format, it shall treat illegal byte sequences as an error condition"

## Security Considerations

### Overlong Encoding Attacks

**Mechanism**: Characters encoded with more bytes than necessary.

| Character | Correct | Overlong 2-byte | Overlong 3-byte |
|-----------|---------|-----------------|-----------------|
| NUL (U+0000) | 00 | C0 80 | E0 80 80 |
| / (U+002F) | 2F | C0 AF | E0 80 AF |
| . (U+002E) | 2E | C0 AE | E0 80 AE |

**Attack Example**: Directory traversal
- Normal: `../` = `2F 2E 2E 2F`
- Overlong: `2F C0 AE C0 AE 2F` (bypasses filter looking for `../`)

**CVE Examples**:
- CVE-2000-0884: IIS 4.0/5.0 path traversal via overlong encoding
- CVE-2007-6284: libxml2 vulnerability
- CVE-2017-1000028: GlassFish arbitrary file read

**RFC 3629 Requirement**: "Implementations of the decoding algorithm MUST protect against decoding invalid sequences"

### Surrogate Attack Vectors

UTF-16 surrogates (U+D800..U+DFFF) should NEVER appear in:
- UTF-8 streams
- UTF-32 streams (except as part of surrogate pair in UTF-16)

**Risk**: Accepting surrogates can produce invalid Unicode that causes issues downstream.

## Compliance Analysis for simple_encoding

### Current Behavior (from adversarial tests)

| Requirement | RFC Compliant | simple_encoding |
|-------------|---------------|-----------------|
| Reject overlong sequences | MUST | NO - accepts C0 80 |
| Reject surrogates in UTF-32→UTF-8 | SHOULD | NO - encodes them |
| Reject > U+10FFFF | MUST | YES - produces error |
| Invalid leading bytes produce error | MUST | YES - has_error set |
| Replacement character for errors | SHOULD | YES - uses U+FFFD |

### Findings

**FINDING-001: Overlong Encodings Accepted**
- RFC 3629 Section 10: "Implementations... MUST protect against decoding invalid sequences"
- Risk: MEDIUM - Security vulnerability
- Status: NON-COMPLIANT

**FINDING-002: Surrogate Code Points Encoded**
- Unicode Standard Section 3.9: Forbids isolated surrogates
- Risk: LOW - Produces invalid Unicode
- Status: NON-COMPLIANT (but common behavior)

## Recommendations

### High Priority
1. **Detect overlong sequences**: Check that decoded value couldn't be encoded with fewer bytes
2. **Check second byte after E0**: Must be A0-BF (not 80-9F)
3. **Check second byte after F0**: Must be 90-BF (not 80-8F)

### Medium Priority
1. **Reject surrogates in UTF-32→UTF-8**: Check for D800-DFFF before encoding
2. **Detect surrogates in UTF-8→UTF-32**: Check ED followed by A0-BF

### Low Priority
1. **Add error detail**: Indicate error type (overlong, surrogate, truncated, invalid)

## References

- [RFC 3629](https://www.rfc-editor.org/rfc/rfc3629.html) - UTF-8 Specification
- [Unicode FAQ on UTF](https://unicode.org/faq/utf_bom) - UTF-8/16/32 Q&A
- [UTF-32 Wikipedia](https://en.wikipedia.org/wiki/UTF-32) - UTF-32 Overview
- [Overlong Security Risks](https://herolab.usd.de/en/the-security-risks-of-overlong-utf-8-encodings/) - Security Analysis
- [CAPEC-80](https://capec.mitre.org/data/definitions/80.html) - Attack Pattern Documentation

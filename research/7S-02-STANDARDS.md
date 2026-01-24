# 7S-02: STANDARDS - simple_encoding

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Applicable Standards

### RFC 3629 - UTF-8
- Variable-length encoding for Unicode
- 1-4 bytes per character
- Byte patterns: 0xxxxxxx, 110xxxxx 10xxxxxx, etc.
- Implementation: SIMPLE_ENCODING

### Unicode Standard (15.0)
- Code points U+0000 to U+10FFFF
- Replacement character U+FFFD
- Character categories (Lu, Ll, Nd, etc.)
- Implementation: SIMPLE_CHARACTER_PROPERTIES

### ISO 8859-1 (Latin-1)
- Western European characters
- 256 code points (0x00-0xFF)
- Direct mapping to Unicode U+0000-U+00FF
- Implementation: SIMPLE_ISO_8859_1_CODEC

### ISO 8859-15 (Latin-9)
- Updated Latin-1 with Euro sign
- Replaces 8 characters from ISO-8859-1
- Implementation: SIMPLE_ISO_8859_15_CODEC

### Windows-1252 (CP1252)
- Microsoft's Latin-1 extension
- Extra characters in 0x80-0x9F range
- Implementation: SIMPLE_WINDOWS_1252_CODEC

### BOM (Byte Order Mark)
- UTF-8: EF BB BF
- UTF-16 LE: FF FE
- UTF-16 BE: FE FF
- UTF-32 LE: FF FE 00 00
- UTF-32 BE: 00 00 FE FF
- Implementation: SIMPLE_ENCODING_DETECTOR

## Implementation Status

| Standard | Coverage | Notes |
|----------|----------|-------|
| RFC 3629 | Complete | Full UTF-8 support |
| Unicode 15.0 | Partial | Basic categories |
| ISO 8859-1 | Complete | Full codec |
| ISO 8859-15 | Complete | Full codec |
| Windows-1252 | Complete | Full codec |
| BOM Detection | Complete | All major BOMs |

## Compliance Notes

- Invalid UTF-8 sequences use U+FFFD replacement
- Overlong encodings rejected
- Code points > U+10FFFF rejected
- Surrogate pairs (U+D800-U+DFFF) handled

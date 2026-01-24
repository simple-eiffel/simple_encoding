# 7S-01: SCOPE - simple_encoding


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Problem Domain

Character encoding conversion and detection. The library addresses the need for handling different text encodings in Eiffel applications, particularly UTF-8 and legacy single-byte encodings.

## Target Users

- Eiffel developers processing international text
- Applications reading files with unknown encodings
- Systems interfacing with legacy data sources
- Email and web applications requiring encoding conversion

## Problem Statement

Text data comes in many encodings. Developers need to:
1. Convert between UTF-8 and legacy encodings (ISO-8859-1, Windows-1252)
2. Detect unknown encodings automatically
3. Validate UTF-8 data
4. Query character properties (letter, digit, whitespace)

## Boundaries

### In Scope
- UTF-8 to UTF-32 conversion (bidirectional)
- Single-byte codec framework (ISO-8859-1, ISO-8859-15, Windows-1252)
- Encoding detection via BOM and heuristics
- Character property queries
- Codec registry for lookup by name

### Out of Scope
- UTF-16 conversion (multi-byte variable)
- Asian encodings (Shift-JIS, GB2312, Big5)
- Unicode normalization (NFC, NFD)
- Collation/sorting
- Full Unicode property database

## Success Criteria

1. Accurate UTF-8/UTF-32 conversion
2. Correct handling of replacement character (U+FFFD)
3. Reliable BOM detection
4. Valid character classification
5. Extensible codec architecture

## Dependencies

- EiffelBase (STRING_8, STRING_32)
- MML (Mathematical Model Library) for contracts

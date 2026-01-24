# 7S-03: SOLUTIONS - simple_encoding


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Existing Solutions Comparison

### Python codecs
- **Pros:** Extensive encoding support, streaming API
- **Cons:** Python-specific, complex error handling
- **Approach:** Registry-based, pluggable codecs

### Java Charset
- **Pros:** Standardized, well-tested
- **Cons:** Complex API, heavyweight
- **Approach:** CharsetEncoder/CharsetDecoder

### ICU (International Components for Unicode)
- **Pros:** Most comprehensive, all encodings
- **Cons:** Large dependency, complex API
- **Approach:** C/C++ library with bindings

### iconv (GNU)
- **Pros:** Standard Unix tool, many encodings
- **Cons:** C library, platform-specific
- **Approach:** Conversion descriptors

## simple_encoding Approach

### Design Philosophy
- Pure Eiffel implementation
- No external dependencies
- Focus on common encodings
- Extensible codec architecture

### Key Differentiators

1. **Pure Eiffel:** No C code, portable
2. **DBC Integration:** Contracts validate input/output
3. **Simple API:** Clear conversion methods
4. **Ecosystem Focus:** Common Western encodings

### Architecture

```
SIMPLE_ENCODING (UTF-8 <-> UTF-32)
    |
SIMPLE_ENCODING_DETECTOR (BOM/heuristic detection)
    |
SIMPLE_CODEC_REGISTRY
    |
    +-- SIMPLE_ISO_8859_1_CODEC
    +-- SIMPLE_ISO_8859_15_CODEC
    +-- SIMPLE_WINDOWS_1252_CODEC
    |
SIMPLE_CHARACTER_PROPERTIES (Unicode categories)
```

### Trade-offs Made

| Decision | Benefit | Cost |
|----------|---------|------|
| Pure Eiffel | No deps | Slower than C |
| Limited encodings | Simple | No Asian |
| Simplified categories | Fast | Incomplete |
| String-based | Easy API | Memory copies |

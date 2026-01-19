# S02: Domain Model - simple_encoding

## PROBLEM DOMAIN

This library addresses the problem of **character encoding conversion** between Unicode representations. Specifically, it converts text between UTF-32 (Eiffel's internal STRING_32 representation where each character is a 32-bit code point) and UTF-8 (the variable-length byte encoding used for I/O, network transmission, and file storage).

## CORE CONCEPTS

| Concept | Definition | Source |
|---------|------------|--------|
| UTF-32 | Fixed-width Unicode encoding where each code point is 4 bytes (STRING_32) | simple_encoding.e note clause line 5 |
| UTF-8 | Variable-width encoding using 1-4 bytes per code point (STRING_8) | simple_encoding.e note clause lines 12-16 |
| Code Point | A Unicode character value (U+0000 to U+10FFFF) | simple_encoding.e line 50, variable `code` |
| Replacement Character | U+FFFD, used when invalid sequences are encountered | simple_encoding.e lines 73-76, 188 |
| Encoding Error | Detection of malformed UTF-8 sequences | simple_encoding.e lines 116, 120, 133, 137, etc. |

## RELATIONSHIPS

```
SIMPLE_ENCODING (Facade)
    │
    ├──produces──> STRING_8 (UTF-8 output)
    │
    ├──produces──> STRING_32 (UTF-32 output)
    │
    ├──maintains──> last_error: STRING_32 (error state)
    │
    └──uses──> NATURAL_32 (for bit manipulation)
```

**Relationship Details:**
- `SIMPLE_ENCODING` --converts--> `STRING_32` to `STRING_8`
- `SIMPLE_ENCODING` --converts--> `STRING_8` to `STRING_32`
- `SIMPLE_ENCODING` --tracks--> encoding errors
- `utf_32_to_utf_8` --produces--> `STRING_8`
- `utf_8_to_utf_32` --produces--> `STRING_32`

## DOMAIN VOCABULARY

| Term | Source | Definition |
|------|--------|------------|
| utf_32 | Parameter names | Unicode code points as 32-bit values (STRING_32) |
| utf_8 | Parameter names | Byte sequences encoding Unicode (STRING_8) |
| code | Local variable | A single Unicode code point value |
| byte1..byte4 | Local variables | Individual bytes in a UTF-8 sequence |
| sequence | Comments | A multi-byte UTF-8 encoding of a single code point |
| leading byte | Comment line 159 | First byte of a multi-byte UTF-8 sequence |
| continuation byte | Implicit in code | Following bytes (10xxxxxx pattern) in multi-byte sequences |
| replacement | Feature name | Substitution for invalid sequences (U+FFFD) |

## RESPONSIBILITIES

### SIMPLE_ENCODING
| Aspect | Description |
|--------|-------------|
| Domain Concept | Character Encoding Converter |
| Primary Responsibility | Bidirectional conversion between UTF-32 and UTF-8 |
| Collaborators | None (standalone) |
| State | `last_error: STRING_32` - accumulated error messages |
| Behavior | Convert strings, detect invalid sequences, track errors |

## DOMAIN RULES

### From Class Invariant (line 195-196)
| Rule | Code | Meaning |
|------|------|---------|
| Error state always valid | `last_error_not_void: last_error /= Void` | Error tracking is always available, never null |

### From UTF-8 Encoding Rules (note clause lines 12-16)
| Code Point Range | UTF-8 Bytes | Pattern |
|------------------|-------------|---------|
| U+0000..U+007F | 1 byte | 0xxxxxxx |
| U+0080..U+07FF | 2 bytes | 110xxxxx 10xxxxxx |
| U+0800..U+FFFF | 3 bytes | 1110xxxx 10xxxxxx 10xxxxxx |
| U+10000..U+10FFFF | 4 bytes | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx |

### From Implementation (inferred)
1. **Invalid code points above U+10FFFF**: Replaced with U+FFFD, error recorded (lines 70-77)
2. **Invalid leading bytes**: Replaced with U+FFFD, error recorded (lines 158-161)
3. **Truncated sequences**: Replaced with U+FFFD, error recorded (lines 119-121, 136-138, 154-156)
4. **Invalid continuation bytes**: Replaced with U+FFFD, error recorded (lines 115-117, 132-134, 150-152)
5. **Error state reset**: Each conversion clears previous errors (lines 47, 98)

## DOMAIN MODEL DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                    CHARACTER ENCODING DOMAIN                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐                    ┌─────────────┐       │
│   │  STRING_32  │                    │  STRING_8   │       │
│   │  (UTF-32)   │                    │  (UTF-8)    │       │
│   │             │                    │             │       │
│   │ Fixed-width │                    │ Variable    │       │
│   │ 4 bytes/cp  │                    │ 1-4 bytes   │       │
│   └──────┬──────┘                    └──────┬──────┘       │
│          │                                  │               │
│          │    ┌───────────────────┐        │               │
│          └───>│ SIMPLE_ENCODING   │<───────┘               │
│               │                   │                        │
│               │ utf_32_to_utf_8() │                        │
│               │ utf_8_to_utf_32() │                        │
│               │                   │                        │
│               │ has_error         │                        │
│               │ last_error        │                        │
│               └─────────┬─────────┘                        │
│                         │                                  │
│                         v                                  │
│               ┌───────────────────┐                        │
│               │ Error Handling    │                        │
│               │                   │                        │
│               │ U+FFFD replacement│                        │
│               │ Error message log │                        │
│               └───────────────────┘                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## OPEN QUESTIONS

1. **BOM handling**: Should the library handle UTF-8 BOM (Byte Order Mark, EF BB BF)?
2. **Overlong encodings**: Are overlong UTF-8 encodings detected and rejected? (e.g., encoding ASCII 'A' as C0 81 instead of 41)
3. **Surrogate pairs**: Are UTF-16 surrogate code points (U+D800..U+DFFF) rejected in UTF-32 input?
4. **NULL handling**: How are embedded NULL bytes (U+0000) handled?
5. **Performance**: Is there caching or optimization for repeated conversions?

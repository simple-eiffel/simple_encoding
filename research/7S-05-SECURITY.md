# 7S-05: SECURITY - simple_encoding

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Security Considerations

### Threat Model

| Threat | Mitigation | Status |
|--------|------------|--------|
| Overlong UTF-8 | Rejected | Implemented |
| Invalid sequences | U+FFFD replacement | Implemented |
| Buffer overflow | Eiffel bounds checking | Automatic |
| Code point injection | Validation | Implemented |

### UTF-8 Security

#### Overlong Encoding Attack
Malicious input could use overlong sequences to bypass filters.

```
Example: "/" can be encoded as:
- 0x2F (valid 1-byte)
- 0xC0 0xAF (invalid overlong 2-byte)
- 0xE0 0x80 0xAF (invalid overlong 3-byte)
```

**Mitigation:** Library rejects overlong encodings, outputs replacement character.

#### Invalid Sequence Handling
- Unexpected continuation bytes -> U+FFFD
- Truncated sequences -> U+FFFD
- Invalid start bytes (0xF5-0xFF) -> U+FFFD

### Code Point Validation

#### Out-of-Range Values
- Code points > U+10FFFF rejected
- Surrogate pairs (U+D800-U+DFFF) handled

#### Null Byte Handling
- Null (U+0000) is valid Unicode
- No special treatment, passes through

### Input Validation

All public APIs validate input:
```eiffel
require
    string_not_void: a_utf8 /= Void
ensure
    result_not_void: Result /= Void
```

### Known Limitations

1. **No normalization:** Different representations of same character not unified
2. **No homoglyph detection:** Similar-looking characters pass through
3. **No string length limits:** Very long strings accepted

### Recommendations

1. Always validate encoding at input boundaries
2. Use UTF-8 as canonical internal format
3. Be aware of normalization issues for comparison
4. Consider content filtering at application level

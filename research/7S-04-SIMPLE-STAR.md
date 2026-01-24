# 7S-04: SIMPLE-STAR - simple_encoding


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Ecosystem Integration

### Used By

| Library | Purpose |
|---------|---------|
| simple_email | UTF-8 validation in messages |
| simple_json | String encoding |
| simple_csv | File encoding detection |
| simple_http | Content-Type charset |

### Dependencies

| Library | Purpose |
|---------|---------|
| EiffelBase | STRING_8, STRING_32 |
| MML | Model contracts |

## API Consistency

### Naming Conventions
- Classes: SIMPLE_* prefix
- Codecs: SIMPLE_{encoding}_CODEC
- Features: Verb-object pattern

### Error Handling Pattern
```eiffel
-- Consistent with ecosystem
has_error: BOOLEAN
last_error: STRING_32

-- Error recovery
-- Invalid sequences -> U+FFFD replacement
```

### Creation Pattern
```eiffel
-- Simple creation
create encoder.make
result := encoder.utf_32_to_utf_8 (my_string_32)

-- Codec usage
registry: SIMPLE_CODEC_REGISTRY
codec := registry.codec_by_name ("ISO-8859-1")
```

## Ecosystem Patterns Applied

### Deferred Class Pattern
SIMPLE_CODEC is deferred, concrete codecs inherit:
- SIMPLE_ISO_8859_1_CODEC
- SIMPLE_ISO_8859_15_CODEC
- SIMPLE_WINDOWS_1252_CODEC

### Registry Pattern
SIMPLE_CODEC_REGISTRY provides lookup by name with aliases.

### Design by Contract
- Preconditions validate input strings
- Postconditions guarantee output validity
- Invariants maintain codec state

### Model-Based Specification
Uses MML_MAP for registry model in contracts.

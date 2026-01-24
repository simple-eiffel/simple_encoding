# S02: CLASS CATALOG - simple_encoding

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Class Hierarchy

```
ANY
    +-- SIMPLE_ENCODING                 # UTF-8 converter
    +-- SIMPLE_ENCODING_DETECTOR        # Encoding detection
    +-- SIMPLE_CHARACTER_PROPERTIES     # Unicode properties
    +-- SIMPLE_CODEC_REGISTRY          # Codec lookup
    +-- SIMPLE_CODEC (deferred)        # Abstract codec
            +-- SIMPLE_ISO_8859_1_CODEC
            +-- SIMPLE_ISO_8859_15_CODEC
            +-- SIMPLE_WINDOWS_1252_CODEC
```

## Class Details

### SIMPLE_ENCODING

**Purpose:** Convert between UTF-8 and UTF-32
**Responsibility:** Encode/decode Unicode strings

| Feature Category | Count |
|-----------------|-------|
| Conversion | 2 |
| Status | 2 |
| Internal | 1 |

**Key Features:**
- `utf_32_to_utf_8`: STRING_32 -> STRING_8
- `utf_8_to_utf_32`: STRING_8 -> STRING_32

---

### SIMPLE_ENCODING_DETECTOR

**Purpose:** Detect text encoding
**Responsibility:** BOM detection, heuristic analysis

| Feature Category | Count |
|-----------------|-------|
| Detection | 2 |
| BOM checking | 5 |
| Validation | 1 |
| Heuristics | 3 |

**Key Features:**
- `detect_encoding`: Returns encoding name
- `detect_encoding_with_confidence`: Returns confidence level
- `is_valid_utf8`: Validate UTF-8

---

### SIMPLE_CODEC (deferred)

**Purpose:** Abstract base for single-byte codecs
**Responsibility:** Define codec interface

| Feature Category | Count |
|-----------------|-------|
| Properties | 2 |
| Encoding | 3 |
| Decoding | 2 |
| Status | 2 |

**Deferred Features:**
- `name`: Codec name
- `encode_character`: Char -> byte
- `decode_byte`: Byte -> char

---

### SIMPLE_CODEC_REGISTRY

**Purpose:** Registry for codec lookup
**Responsibility:** Find codecs by name/alias

| Feature Category | Count |
|-----------------|-------|
| Access | 4 |
| Built-in | 3 |
| Registration | 2 |
| Enumeration | 4 |
| Model | 1 |

**Key Features:**
- `codec_by_name`: Lookup by name
- `register`: Add custom codec
- `all_codec_names`: List all codecs

---

### SIMPLE_CHARACTER_PROPERTIES

**Purpose:** Unicode character classification
**Responsibility:** Query character categories

| Feature Category | Count |
|-----------------|-------|
| Classification | 7 |
| Case | 4 |
| Unicode | 1 |
| ASCII | 2 |

**Key Features:**
- `is_letter`, `is_digit`, `is_whitespace`
- `to_upper`, `to_lower`
- `general_category`

## Class Dependencies

```
SIMPLE_ENCODING_DETECTOR
    |
    +-- uses heuristics from SIMPLE_ENCODING

SIMPLE_CODEC_REGISTRY
    |
    +-- SIMPLE_ISO_8859_1_CODEC
    +-- SIMPLE_ISO_8859_15_CODEC
    +-- SIMPLE_WINDOWS_1252_CODEC
```

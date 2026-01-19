<p align="center">
  <img src="docs/images/logo.png" alt="simple_encoding logo" width="128">
</p>

<h1 align="center">simple_encoding</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_encoding/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_encoding">GitHub</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Eiffel-25.02-purple.svg" alt="Eiffel 25.02">
  <img src="https://img.shields.io/badge/DBC-Contracts-green.svg" alt="Design by Contract">
</p>

Character encoding library for Eiffel with UTF-8/UTF-32 conversion and single-byte codec support.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Production Ready** - v2.0.0
- 83 tests passing
- UTF-8/UTF-32 bidirectional conversion
- ISO-8859-1, ISO-8859-15, Windows-1252 codecs
- Encoding detection with BOM support
- Design by Contract throughout

## Overview

SIMPLE_ENCODING provides character encoding conversion for Eiffel applications:

- **UTF-8 <-> UTF-32** - Bidirectional conversion with error handling
- **Single-byte codecs** - ISO-8859-1 (Latin-1), ISO-8859-15 (Latin-9), Windows-1252
- **Encoding detection** - BOM detection and heuristic analysis
- **Character properties** - Unicode character classification

## Quick Start

### UTF-8 Conversion

```eiffel
local
    enc: SIMPLE_ENCODING
    utf8: STRING_8
    text: STRING_32
do
    create enc.make

    -- Encode to UTF-8
    utf8 := enc.utf_32_to_utf_8 ("Hello World")

    -- Decode from UTF-8
    text := enc.utf_8_to_utf_32 (utf8)

    -- Check for errors
    if enc.has_error then
        print (enc.last_error)
    end
end
```

### Single-Byte Codecs

```eiffel
local
    codec: SIMPLE_ISO_8859_1_CODEC
    bytes: STRING_8
    text: STRING_32
do
    create codec.make

    -- Encode to Latin-1
    bytes := codec.encode_string ("Hello")

    -- Decode from Latin-1
    text := codec.decode_string (bytes)
end
```

### Codec Registry

```eiffel
local
    registry: SIMPLE_CODEC_REGISTRY
    codec: detachable SIMPLE_CODEC
do
    create registry.make

    -- Lookup by name (supports aliases)
    codec := registry.codec_by_name ("latin1")      -- ISO-8859-1
    codec := registry.codec_by_name ("cp1252")      -- Windows-1252
    codec := registry.codec_by_name ("ISO-8859-15") -- Latin-9
end
```

### Encoding Detection

```eiffel
local
    detector: SIMPLE_ENCODING_DETECTOR
    encoding: detachable STRING_32
do
    create detector.make

    -- Detect encoding from bytes
    encoding := detector.detect_encoding (file_bytes)

    -- Check for BOM
    if detector.has_utf8_bom (file_bytes) then
        -- Strip BOM before processing
        file_bytes := detector.strip_bom (file_bytes)
    end
end
```

### Character Properties

```eiffel
local
    props: SIMPLE_CHARACTER_PROPERTIES
do
    create props.make

    if props.is_letter ('A') then ...
    if props.is_digit ('5') then ...
    if props.is_whitespace (' ') then ...

    -- Get Unicode category
    print (props.general_category ('A'))  -- "Lu" (uppercase letter)
end
```

## Classes

| Class | Purpose |
|-------|---------|
| SIMPLE_ENCODING | UTF-8 <-> UTF-32 conversion |
| SIMPLE_CODEC | Abstract base for single-byte codecs |
| SIMPLE_ISO_8859_1_CODEC | Latin-1 codec (Western European) |
| SIMPLE_ISO_8859_15_CODEC | Latin-9 codec (Euro sign support) |
| SIMPLE_WINDOWS_1252_CODEC | Windows-1252 codec |
| SIMPLE_CODEC_REGISTRY | Codec lookup by name |
| SIMPLE_CHARACTER_PROPERTIES | Unicode character classification |
| SIMPLE_ENCODING_DETECTOR | Automatic encoding detection |

## Installation

1. Set the ecosystem environment variable:
```
SIMPLE_EIFFEL=D:\prod
```

2. Add to ECF:
```xml
<library name="simple_encoding" location="$SIMPLE_EIFFEL/simple_encoding/simple_encoding.ecf"/>
```

## Dependencies

- EiffelBase (base)

## Error Handling

Invalid input produces replacement characters (U+FFFD) rather than failing:

```eiffel
local
    enc: SIMPLE_ENCODING
do
    create enc.make

    -- Invalid UTF-8 byte
    text := enc.utf_8_to_utf_32 (invalid_bytes)

    if enc.has_error then
        print ("Errors: " + enc.last_error)
    end
    -- Result contains U+FFFD for each invalid sequence
end
```

## Supported Encodings

| Encoding | Aliases |
|----------|---------|
| ISO-8859-1 | latin1, latin-1 |
| ISO-8859-15 | latin9, latin-9 |
| Windows-1252 | cp1252, win1252 |

## License

MIT License - see [LICENSE](LICENSE) file.

---

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

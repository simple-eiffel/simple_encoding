# S01: PROJECT INVENTORY - simple_encoding

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Project Structure

```
simple_encoding/
    +-- src/
    |   +-- simple_encoding.e            # UTF-8 <-> UTF-32 conversion
    |   +-- simple_codec.e               # Abstract codec base
    |   +-- simple_iso_8859_1_codec.e    # Latin-1 codec
    |   +-- simple_iso_8859_15_codec.e   # Latin-9 codec
    |   +-- simple_windows_1252_codec.e  # CP1252 codec
    |   +-- simple_encoding_detector.e   # Encoding detection
    |   +-- simple_character_properties.e # Unicode properties
    |   +-- simple_codec_registry.e      # Codec lookup
    |
    +-- testing/
    |   +-- test_app.e
    |   +-- lib_tests.e
    |   +-- encoding_tests.e
    |   +-- codec_tests.e
    |   +-- utility_tests.e
    |   +-- adversarial_tests.e
    |   +-- stress_tests.e
    |   +-- bug_hunt_tests.e
    |
    +-- research/
    |   +-- 7S-01-SCOPE.md through 7S-07-RECOMMENDATION.md
    |
    +-- specs/
    |   +-- S01-PROJECT-INVENTORY.md through S08-VALIDATION-REPORT.md
    |
    +-- simple_encoding.ecf
    +-- README.md
    +-- CHANGELOG.md
```

## File Inventory

| File | Lines | Purpose |
|------|-------|---------|
| simple_encoding.e | 210 | UTF-8/UTF-32 conversion |
| simple_codec.e | 115 | Abstract codec |
| simple_iso_8859_1_codec.e | 150 | Latin-1 codec |
| simple_iso_8859_15_codec.e | 180 | Latin-9 codec |
| simple_windows_1252_codec.e | 200 | Windows-1252 codec |
| simple_encoding_detector.e | 245 | Encoding detection |
| simple_character_properties.e | 225 | Char properties |
| simple_codec_registry.e | 240 | Codec registry |

## Dependencies

### Internal
- None (foundational library)

### External
- EiffelBase
- MML (Mathematical Model Library)

## Build Targets

| Target | Purpose |
|--------|---------|
| simple_encoding | Library |
| simple_encoding_tests | Test suite |

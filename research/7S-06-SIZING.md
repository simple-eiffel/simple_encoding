# 7S-06: SIZING - simple_encoding


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## Implementation Size

### Actual Implementation

| Component | Lines | Complexity |
|-----------|-------|------------|
| SIMPLE_ENCODING | ~210 | Medium |
| SIMPLE_CODEC | ~115 | Low (deferred) |
| SIMPLE_ISO_8859_1_CODEC | ~150 | Low |
| SIMPLE_ISO_8859_15_CODEC | ~180 | Low |
| SIMPLE_WINDOWS_1252_CODEC | ~200 | Low |
| SIMPLE_ENCODING_DETECTOR | ~245 | Medium |
| SIMPLE_CHARACTER_PROPERTIES | ~225 | Low |
| SIMPLE_CODEC_REGISTRY | ~240 | Medium |
| **Total Source** | **~1565** | **Medium** |

### Test Coverage

| Test File | Lines | Tests |
|-----------|-------|-------|
| encoding_tests.e | ~200 | UTF-8 conversion |
| codec_tests.e | ~150 | Single-byte codecs |
| utility_tests.e | ~100 | Detector/properties |
| adversarial_tests.e | ~100 | Edge cases |
| stress_tests.e | ~100 | Performance |
| bug_hunt_tests.e | ~80 | Regression |
| **Total Tests** | **~730** | |

### Complexity Breakdown

#### Simple (data/lookup)
- Single-byte codecs: Table-based conversion
- Character properties: Range checks

#### Medium (algorithms)
- SIMPLE_ENCODING: UTF-8 state machine
- SIMPLE_ENCODING_DETECTOR: Multi-strategy detection
- SIMPLE_CODEC_REGISTRY: Hash table management

### Dependencies

```
simple_encoding
    +-- EiffelBase
    |   +-- STRING_8
    |   +-- STRING_32
    |   +-- HASH_TABLE
    |   +-- ARRAYED_LIST
    +-- MML (for contracts)
```

### Build Time Impact
- Clean build: ~8 seconds
- Incremental: ~3 seconds
- No C compilation

### Runtime Footprint
- Memory: ~20KB base
- Per-codec: ~1KB (lookup tables)
- Conversion: O(n) memory for result string

## Estimation vs Actual

| Aspect | Estimated | Actual |
|--------|-----------|--------|
| Development time | 2 days | 2 days |
| Core classes | 6-8 | 8 |
| Lines of code | 1200 | 1565 |
| Test coverage | 80% | ~75% |

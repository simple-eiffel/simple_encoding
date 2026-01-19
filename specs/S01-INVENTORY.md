# S01: Project Inventory - simple_encoding

## PROJECT IDENTITY

| Field | Value | Source |
|-------|-------|--------|
| Library name | simple_encoding | ECF line 2 |
| UUID | E3A8F9C2-5B7D-4A6E-8F1C-D2B3E4A5F6C7 | ECF line 2 |
| Purpose | UTF-8/UTF-32 conversion library | simple_encoding.e note clause lines 2-16 |
| Version | Not specified | - |

## DEPENDENCY ANALYSIS

### Library Target Dependencies
| Dependency | Location | Category | Purpose |
|------------|----------|----------|---------|
| base | $ISE_LIBRARY\library\base\base.ecf | Core | STRING_8, STRING_32, NATURAL_32 |

### Test Target Additional Dependencies
| Dependency | Location | Category | Purpose |
|------------|----------|----------|---------|
| simple_testing | $SIMPLE_EIFFEL/simple_testing/simple_testing.ecf | Simple ecosystem | TEST_SET_BASE, assertions |
| testing | $ISE_LIBRARY\library\testing\testing.ecf | Core | EQA_TEST_SET |

**Dependency Count:** 1 (library), 3 (tests)

## CLUSTER ANALYSIS

| Cluster | Location | Classes | Purpose |
|---------|----------|---------|---------|
| src | .\src\ | 1 | Main implementation |
| test | .\testing\ | 2 | Test classes |

## CLASS INVENTORY

### CLASS: SIMPLE_ENCODING
| Attribute | Value |
|-----------|-------|
| File | src/simple_encoding.e |
| Cluster | src |
| Has note clause | YES (lines 1-20) |
| Creation procedures | make |
| Public features | 4 (utf_32_to_utf_8, utf_8_to_utf_32, has_error, last_error) |
| Has invariant | YES (line 195-196) |
| Inherits from | ANY (implicit) |
| Role | FACADE |

**Public Feature List:**
1. `utf_32_to_utf_8 (READABLE_STRING_32): STRING_8` - Conversion command
2. `utf_8_to_utf_32 (READABLE_STRING_8): STRING_32` - Conversion command
3. `has_error: BOOLEAN` - Status query
4. `last_error: STRING_32` - Status query

**Private Features:**
1. `make` - Creation
2. `append_replacement_and_error` - Helper

### CLASS: ENCODING_TESTS
| Attribute | Value |
|-----------|-------|
| File | testing/encoding_tests.e |
| Cluster | test |
| Has note clause | YES (lines 1-4) |
| Creation procedures | (inherited default_create) |
| Public features | 10 test features |
| Has invariant | NO |
| Inherits from | TEST_SET_BASE |
| Role | TEST |

### CLASS: TEST_APP
| Attribute | Value |
|-----------|-------|
| File | testing/test_app.e |
| Cluster | test |
| Has note clause | YES (lines 1-4) |
| Creation procedures | make |
| Public features | 0 (all features are {NONE}) |
| Has invariant | NO |
| Inherits from | ANY (implicit) |
| Role | TEST (runner) |

## FACADE IDENTIFICATION

| Class | Evidence |
|-------|----------|
| SIMPLE_ENCODING | Name matches library name; contains all public API features; note clause describes library purpose |

## TEST INVENTORY

### ENCODING_TESTS (10 tests)
| Feature Group | Tests |
|---------------|-------|
| ASCII Tests | test_ascii_roundtrip |
| Extended Latin Tests | test_latin_extended |
| CJK Tests | test_cjk_characters |
| 4-byte Tests | test_emoji_4byte |
| Edge Case Tests | test_empty_string, test_mixed_content |
| Byte Count Verification | test_utf8_byte_counts |
| Error Handling Tests | test_invalid_utf8_sequence, test_truncated_utf8, test_error_tracking |

## SUMMARY

```
PROJECT INVENTORY:
  Name: simple_encoding
  Purpose: UTF-8/UTF-32 bidirectional conversion

DEPENDENCIES: 1 (library mode)
  - base: STRING_8, STRING_32, NATURAL_32 types

CLUSTERS: 2
  - src: 1 class - main implementation
  - test: 2 classes - test infrastructure

CLASSES: 3
  Facades: SIMPLE_ENCODING
  Engines: (none)
  Data: (none)
  Helpers: (none)
  Tests: ENCODING_TESTS, TEST_APP

TEST COVERAGE:
  Test classes: 1 (ENCODING_TESTS)
  Total tests: 10
  Features tested:
    - utf_32_to_utf_8: 7 tests
    - utf_8_to_utf_32: 7 tests
    - has_error: 5 tests
    - last_error: 1 test

DOCUMENTATION STATUS:
  README: ABSENT
  Note clauses: 100% of classes (3/3)
  Header comments: 100% of public features
```

## ECF CONFIGURATION DETAILS

### Compiler Settings
- void_safety: all
- concurrency: scoop support, thread use
- assertions: all enabled (precondition, postcondition, check, invariant, loop, supplier_precondition)
- dead_code_removal: feature level

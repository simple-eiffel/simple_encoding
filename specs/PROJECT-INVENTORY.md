# Project Inventory: simple_encoding

**Generated:** 2026-01-19
**Phase:** DISCOVERY (Spec Extraction - Step 1)

---

## PROJECT IDENTITY

| Item | Value |
|------|-------|
| **Library Name** | simple_encoding |
| **UUID** | E3A8F9C2-5B7D-4A6E-8F1C-D2B3E4A5F6C7 |
| **Purpose** | UTF-8 <-> UTF-32 encoding/decoding |
| **Version** | 1.0 (implied from WORKFLOW-COMPLETE.md) |
| **Location** | D:\prod\simple_encoding |

**Stated Purpose (from note clause):**
> Simple UTF encoding/decoding library. Provides conversion between STRING_32 (UTF-32/Unicode) and STRING_8 (UTF-8). This is a pure Eiffel implementation without external dependencies.

---

## DEPENDENCY ANALYSIS

### Dependencies: 2

| Dependency | Location | Category | Purpose |
|------------|----------|----------|---------|
| base | $ISE_LIBRARY\library\base\base.ecf | Core | EiffelBase (STRING, NATURAL_32, etc.) |
| simple_testing | $SIMPLE_EIFFEL/simple_testing/simple_testing.ecf | Simple ecosystem | TEST_SET_BASE for test classes |

**Additional test-only dependency:**
- testing | $ISE_LIBRARY\library\testing\testing.ecf | Core | ISE testing framework

---

## CLUSTER ANALYSIS

### Clusters: 2

| Cluster | Location | Classes | Purpose |
|---------|----------|---------|---------|
| src | .\src\ | 1 | Main implementation |
| test | .\testing\ | 5 | Test classes |

---

## CLASS INVENTORY

### Source Classes: 1

| Class | File | Role | Has Note | Creation | Public Features | Invariant | Inherits |
|-------|------|------|----------|----------|-----------------|-----------|----------|
| SIMPLE_ENCODING | src/simple_encoding.e | FACADE | YES | make | 4 | YES | None |

**SIMPLE_ENCODING Features:**
- `make` - Creation procedure
- `utf_32_to_utf_8 (a_utf32: READABLE_STRING_32): STRING_8` - Convert UTF-32 to UTF-8
- `utf_8_to_utf_32 (a_utf8: READABLE_STRING_8): STRING_32` - Convert UTF-8 to UTF-32
- `has_error: BOOLEAN` - Query error state
- `last_error: STRING_32` - Error message

**Contracts:**
- Preconditions: string_not_void on both conversion features
- Postconditions: result_not_void, empty_preserved on both conversion features
- Invariant: last_error_not_void

### Test Classes: 5

| Class | File | Test Count | Purpose |
|-------|------|------------|---------|
| ENCODING_TESTS | testing/encoding_tests.e | 10 | Basic UTF-8/UTF-32 conversion tests |
| ADVERSARIAL_TESTS | testing/adversarial_tests.e | 18 | Boundary values, invalid sequences, attack vectors |
| STRESS_TESTS | testing/stress_tests.e | 10 | Long strings, repeated conversions |
| BUG_HUNT_TESTS | testing/bug_hunt_tests.e | 4 | Edge cases around F4/F5/F6/F7 leading bytes |
| TEST_APP | testing/test_app.e | - | Test runner |

---

## FACADE IDENTIFICATION

**Primary Facade:** SIMPLE_ENCODING

**Evidence:**
1. Name matches library pattern (SIMPLE_{X})
2. Only source class in src/ cluster
3. Contains all public API features
4. Has comprehensive note clause describing purpose

---

## TEST INVENTORY

### Test Coverage Summary

| Test Suite | Tests | Categories |
|------------|-------|------------|
| ENCODING_TESTS | 10 | ASCII, Latin, CJK, emoji, empty, mixed, byte counts, errors |
| ADVERSARIAL_TESTS | 18 | Boundaries, overlong, surrogates, invalid bytes, BOM |
| STRESS_TESTS | 10 | Long strings, repeated ops, error sequences |
| BUG_HUNT_TESTS | 4 | F4-F7 leading byte edge cases |
| **TOTAL** | **42** | |

### Test Results (Actual Run)
```
Results: 42 passed, 0 failed
ALL TESTS PASSED
```

---

## DOCUMENTATION STATUS

| Item | Status |
|------|--------|
| README | ABSENT |
| Note clauses | 100% of classes |
| Header comments | ~80% of features |
| docs/ folder | PRESENT (but minimal) |
| MAINTENANCE-REPORT.md | PRESENT |
| WORKFLOW-COMPLETE.md | PRESENT |

---

## ECF CONFIGURATION

```xml
<capability>
    <concurrency support="scoop" use="thread"/>
    <void_safety support="all"/>
</capability>
```

- **Void Safety:** ALL (full void safety)
- **Concurrency:** SCOOP supported, thread used
- **Assertions:** All enabled (precondition, postcondition, check, invariant, loop, supplier_precondition)

---

## SUMMARY

| Metric | Value |
|--------|-------|
| Source Classes | 1 |
| Test Classes | 5 |
| Total Tests | 42 |
| Tests Passing | 42 (100%) |
| Dependencies | 2 (base, simple_testing) |
| Facades | 1 (SIMPLE_ENCODING) |

**Current State:** Library provides UTF-8 <-> UTF-32 conversion only. Ready for enhancement to add:
- ISO-8859-x codecs
- Windows codecs
- Character properties
- Codec registry
- Encoding detector

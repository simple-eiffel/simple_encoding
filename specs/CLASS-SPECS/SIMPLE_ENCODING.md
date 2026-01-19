# CLASS SPECIFICATION: SIMPLE_ENCODING

**Generated:** 2026-01-19
**Phase:** Spec Extraction (Steps 3-6)

---

## Identity

| Item | Value |
|------|-------|
| **Name** | SIMPLE_ENCODING |
| **Role** | FACADE |
| **Domain Concept** | Character encoding converter |
| **File** | src/simple_encoding.e |

---

## Purpose

This class represents a **UTF-8/UTF-32 converter** - a bidirectional transformer between Eiffel's native STRING_32 (which holds Unicode code points) and STRING_8 (which holds raw bytes in UTF-8 format).

**Responsibilities:**
- Convert STRING_32 to UTF-8 encoded STRING_8
- Convert UTF-8 encoded STRING_8 to STRING_32
- Track conversion errors with detailed messages
- Handle invalid input gracefully with replacement characters

**Guarantees:**
- Output is never Void (even for empty input)
- Empty input produces empty output
- Error state is always available to query
- Invalid sequences produce replacement character (U+FFFD) instead of crashing

---

## Creation

### CREATION: make

| Aspect | Value |
|--------|-------|
| **Signature** | make |
| **Purpose** | Initialize converter with empty error state |
| **Preconditions** | NONE |
| **Postconditions** | NONE (implicit: last_error initialized to empty string) |

**Initial State:**
- last_error = empty STRING_32

---

## Queries

### QUERY: has_error

| Aspect | Value |
|--------|-------|
| **Signature** | has_error: BOOLEAN |
| **Purpose** | Query whether last conversion had errors |
| **Preconditions** | NONE |
| **Postconditions** | NONE |
| **Pure** | YES (no state modification) |

**Semantics:** Returns True if last_error is not empty.

### QUERY: last_error

| Aspect | Value |
|--------|-------|
| **Signature** | last_error: STRING_32 |
| **Purpose** | Access error message from last conversion |
| **Preconditions** | NONE |
| **Postconditions** | NONE |
| **Pure** | YES |

**Invariant:** Never Void (protected by class invariant).

---

## Commands (Conversion Operations)

### COMMAND: utf_32_to_utf_8

| Aspect | Value |
|--------|-------|
| **Signature** | utf_32_to_utf_8 (a_utf32: READABLE_STRING_32): STRING_8 |
| **Purpose** | Encode Unicode code points as UTF-8 bytes |
| **Preconditions** | string_not_void: a_utf32 /= Void |
| **Postconditions** | result_not_void, empty_preserved |
| **Modifies** | last_error |

### COMMAND: utf_8_to_utf_32

| Aspect | Value |
|--------|-------|
| **Signature** | utf_8_to_utf_32 (a_utf8: READABLE_STRING_8): STRING_32 |
| **Purpose** | Decode UTF-8 bytes to Unicode code points |
| **Preconditions** | string_not_void: a_utf8 /= Void |
| **Postconditions** | result_not_void, empty_preserved |
| **Modifies** | last_error |

---

## Invariants

| Invariant | Meaning |
|-----------|---------|
| last_error_not_void | Error message is always accessible |

---

## Contract Coverage Analysis

| Metric | Value |
|--------|-------|
| Features with preconditions | 3/5 (60%) |
| Features with postconditions | 3/5 (60%) |
| Has class invariant | YES |
| **Overall Quality** | MODERATE |

### Contract Gaps

| Feature | Gap |
|---------|-----|
| make | Missing postcondition: error_empty |
| has_error | Missing postcondition for Result definition |

---

## Boundary Specifications (from tests)

| Boundary | Value | Expected |
|----------|-------|----------|
| Max 1-byte | U+007F | 1 byte |
| Min 2-byte | U+0080 | 2 bytes |
| Max 2-byte | U+07FF | 2 bytes |
| Min 3-byte | U+0800 | 3 bytes |
| Max 3-byte | U+FFFF | 3 bytes |
| Min 4-byte | U+10000 | 4 bytes |
| Max valid | U+10FFFF | 4 bytes |
| First invalid | U+110000 | U+FFFD + error |

---

## Test Coverage

| Category | Tests |
|----------|-------|
| Basic | 10 |
| Adversarial | 18 |
| Stress | 10 |
| Bug hunt | 4 |
| **TOTAL** | **42** |

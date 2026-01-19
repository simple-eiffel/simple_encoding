# S05: System Constraints - simple_encoding

## Data Integrity Rules

| Rule | Where Enforced | Expression |
|------|----------------|------------|
| Error state always attached | SIMPLE_ENCODING invariant | `last_error /= Void` |
| Input strings never void | utf_32_to_utf_8 require | `a_utf32 /= Void` |
| Input strings never void | utf_8_to_utf_32 require | `a_utf8 /= Void` |
| Result strings never void | Both ensure clauses | `Result /= Void` |

## State Validity Rules

| Rule | Description | Enforcement |
|------|-------------|-------------|
| Error cleared on new conversion | Each conversion starts fresh | `last_error.wipe_out` at start |
| Consistent error state | has_error reflects last_error | `has_error = not last_error.is_empty` |

## Relationship Rules

| Rule | Description |
|------|-------------|
| Roundtrip identity (valid input) | `utf_8_to_utf_32(utf_32_to_utf_8(s)) = s` when all code points valid |
| Roundtrip identity (valid input) | `utf_32_to_utf_8(utf_8_to_utf_32(s)) = s` when s is valid UTF-8 |

## Business Rules (UTF-8 Standard)

| Rule | Code Reference | Standard |
|------|----------------|----------|
| ASCII unchanged | code <= 0x7F → 1 byte | RFC 3629 |
| Valid code point range | code <= 0x10FFFF | Unicode Standard |
| Replacement for invalid | U+FFFD (0xFFFD) | Unicode Standard |
| Continuation byte pattern | 10xxxxxx | RFC 3629 |
| 2-byte leading pattern | 110xxxxx | RFC 3629 |
| 3-byte leading pattern | 1110xxxx | RFC 3629 |
| 4-byte leading pattern | 11110xxx | RFC 3629 |

## Void Safety Rules

| Attribute | Type | Can be Void | When |
|-----------|------|-------------|------|
| last_error | STRING_32 | NO (invariant) | Never |

**All parameters are attached types - void safety is enforced by preconditions.**

## Temporal Rules

| Rule | Before | After | Enforcement |
|------|--------|-------|-------------|
| Create before use | - | make called | Creation procedure |
| Error state per-conversion | Any state | Fresh state | wipe_out at start |

## Implicit Constraints (NEEDS FORMALIZATION)

### 1. Overlong Encoding Detection
**Evidence:** Not checked in utf_8_to_utf_32 (lines 112, 129, 147)
- Code accepts overlong encodings (e.g., C0 80 for U+0000)
- RFC 3629 Section 3 forbids overlong forms
- **Risk:** Security vulnerability (overlong attack)
- **Should be:** Reject overlong sequences with error

### 2. Surrogate Code Points
**Evidence:** Not checked in utf_32_to_utf_8 (lines 59-63)
- Code would encode U+D800..U+DFFF as 3-byte UTF-8
- These are reserved for UTF-16 surrogate pairs
- **Risk:** Invalid Unicode output
- **Should be:** Reject or replace surrogates

### 3. Code Point Upper Bound in UTF-8
**Evidence:** Not checked in utf_8_to_utf_32 (line 147)
- Decoded 4-byte sequences not verified <= 0x10FFFF
- Could decode invalid code points > 0x10FFFF
- **Risk:** Invalid Unicode in result
- **Should be:** Validate decoded value

## Constraint Gaps (NEEDS CONTRACTS)

### Missing Invariants
None identified - single invariant is sufficient for this simple class.

### Missing Preconditions
None identified - void checks are appropriate.

### Missing Postconditions

1. **utf_32_to_utf_8:**
   - No guarantee about output being valid UTF-8
   - Should ensure: all output bytes form valid sequences

2. **utf_8_to_utf_32:**
   - No guarantee about output code point validity
   - Should ensure: all output code points <= 0x10FFFF

3. **Both conversions:**
   - No contract linking has_error to input validity
   - Should ensure: error state reflects actual errors found

### Missing Cross-Class Constraints
N/A - only one non-test class exists.

## Summary

| Category | Count | Status |
|----------|-------|--------|
| Data Integrity | 4 | ENFORCED |
| State Validity | 2 | ENFORCED |
| Relationship | 2 | IMPLICIT (not in contracts) |
| Business Rules | 7 | ENFORCED |
| Void Safety | 1 | ENFORCED |
| Temporal | 2 | ENFORCED |
| **Implicit (Gaps)** | **3** | **NEEDS FORMALIZATION** |

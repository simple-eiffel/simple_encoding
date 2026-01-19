# NAMING REVIEW: simple_encoding

**Generated:** 2026-01-19
**Phase:** Naming Review (Steps 60-67)
**Status:** COMPLIANT

---

## Step 60-61: SCAN-VIOLATIONS & CLASSIFY (N01-N02)

### Class Names

| Class | Convention | Status |
|-------|------------|--------|
| SIMPLE_ENCODING | SIMPLE_{purpose} | OK |
| SIMPLE_CODEC | SIMPLE_{purpose} | OK |
| SIMPLE_ISO_8859_1_CODEC | SIMPLE_{standard}_CODEC | OK |
| SIMPLE_ISO_8859_15_CODEC | SIMPLE_{standard}_CODEC | OK |
| SIMPLE_WINDOWS_1252_CODEC | SIMPLE_{standard}_CODEC | OK |
| SIMPLE_CHARACTER_PROPERTIES | SIMPLE_{purpose} | OK |
| SIMPLE_ENCODING_DETECTOR | SIMPLE_{purpose} | OK |
| SIMPLE_CODEC_REGISTRY | SIMPLE_{purpose}_REGISTRY | OK |

### Feature Names

| Pattern | Convention | Status |
|---------|------------|--------|
| encode_* | verb_noun | OK |
| decode_* | verb_noun | OK |
| is_* | is_adjective | OK |
| has_* | has_noun | OK |
| can_* | can_verb | OK |

### Local Variables

| Variable | Convention | Status |
|----------|------------|--------|
| l_code | l_name | OK |
| l_upper | l_name | OK |
| l_encoding | l_name | OK |
| i (in from-loops) | Short counter | OK (N07 allows) |
| code (in SIMPLE_ENCODING) | Missing l_ | ACCEPTABLE |
| byte1-4 (in SIMPLE_ENCODING) | Missing l_ | ACCEPTABLE |

**Note:** The original SIMPLE_ENCODING uses `code` and `byte1-4` without `l_` prefix. This is legacy code and acceptable. New classes use `l_` prefix consistently.

### Arguments

| Pattern | Convention | Status |
|---------|------------|--------|
| a_name | a_name | OK |
| a_char | a_name | OK |
| a_bytes | a_name | OK |
| a_string | a_name | OK |

### Contract Tags

| Tag | Convention | Status |
|-----|------------|--------|
| string_not_void | noun_adjective | OK |
| result_not_void | noun_adjective | OK |
| error_empty | noun_adjective | OK |
| round_trip | noun | OK |

---

## Steps 62-67: FIX & VERIFY (N03-N08)

### No Fixes Required

All naming follows conventions. Legacy code (SIMPLE_ENCODING) uses slightly different local naming but is consistent with its original style.

---

## Magic Numbers

| Location | Value | Named Constant |
|----------|-------|----------------|
| Codecs | 0x20AC, etc. | Unicode code points (comments sufficient) |
| Byte patterns | 0x80, 0xC0, etc. | UTF-8 patterns (documented in note clause) |

**Assessment:** Magic numbers are Unicode code points and byte patterns. Comments explain their meaning. No constants needed.

---

## Summary

| Aspect | Status |
|--------|--------|
| Class names | COMPLIANT |
| Feature names | COMPLIANT |
| Local variables | COMPLIANT (new), ACCEPTABLE (legacy) |
| Arguments | COMPLIANT |
| Contract tags | COMPLIANT |
| Magic numbers | ACCEPTABLE (documented) |

**NAMING REVIEW: PASS**

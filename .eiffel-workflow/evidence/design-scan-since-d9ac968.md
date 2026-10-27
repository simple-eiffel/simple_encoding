# Design Scan (diff mode): simple_encoding since d9ac968
# Date: 2026-10-27
# Subjects: src/simple_character_properties.e, src/unicode/simple_unicode.e, src/unicode/simple_unicode_tables.e, src/unicode/simple_unicode_data.e (GENERATED: the generator tools/generate_unicode_data.py was reviewed, not the data)
# Compared against: all of src/ (8 classes besides the unicode folder) plus testing/unicode_tests.e
# Read-only. Nothing was compiled.

## Summary

| Priority | Findings |
|----------|----------|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 4 |
| **Total** | **7** |

| # | Priority | Category | Classes | Opportunity |
|---|----------|----------|---------|-------------|
| 1 | HIGH | D1 drift | SIMPLE_CHARACTER_PROPERTIES, SIMPLE_UNICODE | Two classification routes in one class now disagree; the range guesses must delegate to the tables |
| 2 | MEDIUM | A4 / safety | SIMPLE_UNICODE, SIMPLE_CHARACTER_PROPERTIES | `general_category` hands out the table's own mutable string |
| 3 | MEDIUM | contract cost | SIMPLE_UNICODE, SIMPLE_UNICODE_TABLES | Hot-path postconditions: three extra linear passes per `nfd`, a tautology on `is_combining_mark`, and a binary-search postcondition per character |
| 4 | LOW | generator | tools/generate_unicode_data.py | Version constant is not checked against the input; conformance sample is by file line |
| 5 | LOW | cleanup | SIMPLE_UNICODE_TABLES | Tables created twice in `make` |
| 6 | LOW | perf | SIMPLE_UNICODE | Combining class lookup is a hash table probe per character; `simple_lower` / `simple_upper` probe twice |
| 7 | LOW | structure | SIMPLE_CHARACTER_PROPERTIES | Private `once` for a stateless service; two `feature {NONE} -- Implementation` clauses |

## Detailed Findings

### Finding 1: SIMPLE_CHARACTER_PROPERTIES answers the same question two ways, and the answers differ
**Priority:** HIGH (D1, drift)
**Category:** D1 / A1
**Classes:** src/simple_character_properties.e, src/unicode/simple_unicode.e
**Description:** This change made `general_category` answer from the full Unicode tables, but every other query in the same class is still the old hand-written range guess. The class now contradicts itself, and SIMPLE_UNICODE has a second feature named `is_letter` with a different answer. The tables copy should win (the Unicode Character Database is the specification); the range copies are the stale ones.
**Evidence (divergences that exist today):**
- src/simple_character_properties.e:207 treats U+0590..U+05FF as letters, so `is_letter` is True for the Hebrew point sheva (U+05B0). `general_category` of the same character is "Mn" (line 168 delegating to src/unicode/simple_unicode.e:39), and testing/unicode_tests.e:45 asserts "Mn". The same holds for every Hebrew point and accent, and the Greek, Cyrillic, Armenian and Arabic blocks (lines 204 to 209), which contain marks, digits and punctuation.
- src/simple_character_properties.e:118 (`is_punctuation`, U+2000..U+206F) overlaps line 91 (`is_whitespace`, U+2000..U+200A), so U+2000..U+200A is both punctuation and whitespace. The tables say Zs. U+200D (zero-width joiner) is "punctuation" by line 118 and Cf by the tables.
- src/simple_character_properties.e:60 `is_digit` accepts only 0 to 9, while `general_category` now answers "Nd" for every other decimal digit (Arabic-Indic digits, for one), so `is_digit` is False where the category is Nd.
- src/simple_character_properties.e:46-48 (`is_letter` Latin ranges C0..D6, D8..F6, F8..FF) leave out U+00AA, U+00B5 and U+00BA, which the tables classify as letters (Lo, Ll, Lo).
- Two classes, same name, different answers: src/simple_character_properties.e:38 `is_letter` versus src/unicode/simple_unicode.e:58 `is_letter` (category L*).
- Case: src/simple_character_properties.e:137-158 delegate to ISE `CHARACTER_32.is_upper / is_lower / upper / lower`, while src/unicode/simple_unicode.e:72-88 `simple_lower` / `simple_upper` answer from the UCD. Two case maps in one library.
**Suggested Action:** Make `is_letter`, `is_digit`, `is_whitespace`, `is_punctuation`, `is_symbol`, `is_control`, `is_upper`, `is_lower`, `to_upper`, `to_lower` derive from `unicode.general_category` / `simple_lower` / `simple_upper` (keep the ASCII fast path where it is exact: code below 128). Or inherit SIMPLE_UNICODE side by side so there is one definition per name, and keep SIMPLE_CHARACTER_PROPERTIES only for the genuinely different convenience queries (`is_hex_digit`, `is_ascii`, `is_printable_ascii`). Add tests that fix each disagreement above. Clients to check before changing behavior: anything calling these through simple_encoding (this repository has none inside src/ apart from the class itself; other simple_* libraries were not scanned).
**Effort:** 10 features

### Finding 2: `general_category` returns the table's own mutable string
**Priority:** MEDIUM
**Category:** A4 (contract/safety gap on shared behavior)
**Classes:** src/unicode/simple_unicode.e, src/simple_character_properties.e
**Description:** `Result := tables.category_codes [index]` returns the very STRING_8 stored in the once-per-processor table. Any caller that appends to, lowercases or `wipe_out`s the result corrupts the category of every code point in that run for the whole process. Before this change the old routine returned manifest literals (a fresh string each call). It is now a silent behavior change with action at a distance, and the second delegation layer (BIB_SIMPLE_UNICODE in simple_bible, scanned separately) hands it on again.
**Evidence:**
- src/unicode/simple_unicode.e:39 returns the shared object; the postcondition at line 41 checks only the length.
- src/simple_character_properties.e:168 hands it on; postcondition at line 170 is the same.
- src/unicode/simple_unicode_tables.e:49 `category_codes: SPECIAL [STRING_8]` is exported to all clients, and line 109 stores one string per run.
**Suggested Action:** Return `READABLE_STRING_8` (the clients only compare), or `.twin` (an allocation per call on a hot path, so prefer the type change), and narrow `category_codes` export to `{SIMPLE_UNICODE}`. Alternatively, store a small INTEGER code per run and build constants.
**Effort:** 2 features

### Finding 3: Contract cost on the Unicode hot paths
**Priority:** MEDIUM
**Category:** contract strength vs cost (memory rule: hot paths keep only cheap contracts)
**Classes:** src/unicode/simple_unicode.e, src/unicode/simple_unicode_tables.e
**Description:** SIMPLE_UNICODE is called per character and per verse by clients (simple_bible normalizes 362,607 texts in one build). In a fat or test build (contracts kept) these postconditions repeat work already done:
- `nfd` (src/unicode/simple_unicode.e:97) and `nfkd` (line 105) assert `is_canonically_ordered (Result)`, a linear scan with one hash probe per character (`class_of`, lines 144-150). `decomposed` calls `put_in_canonical_order`, whose own postcondition (lines 220-222) runs the same `is_canonically_ordered` scan again, plus `old a_text.count`. So every `nfd` pays the scan twice, every `nfkd` too. Keep the check in exactly one place: `put_in_canonical_order` already guarantees it for every caller; the two public postconditions add nothing.
- `is_combining_mark` (line 47-50): the postcondition `definition: Result = (general_category (a_char) [1] = 'M')` is the body, line for line, so it doubles the binary search for no information.
- `SIMPLE_UNICODE_TABLES.run_index` (src/unicode/simple_unicode_tables.e:86-88) checks two assertions on every category lookup, and every character-level query goes through it. The checks are O(1) but are on the single hottest path; `starts_at_or_before` is the loop's own invariant.
- `general_category` postcondition `two_letters` (line 41) is cheap and fine; it stays.
**Suggested Action:** Delete the ordering postconditions on `nfd` / `nfkd` (leave the one on `put_in_canonical_order`), delete the tautology on `is_combining_mark`, and move the `run_index` assertions into a test (testing/unicode_tests.e already covers boundaries at lines 21-33). Per the timing note, tests that measure time run inside `without_contracts`.
**Effort:** 5 assertions

### Finding 4: Generator: version constant and conformance sampling
**Priority:** LOW
**Category:** build tool hygiene
**Classes:** tools/generate_unicode_data.py
**Evidence:**
- tools/generate_unicode_data.py:15 hardcodes `VERSION = '15.1.0'` and writes it into the class (line 144). Nothing reads the version from the UCD folder passed on the command line, so running it on another Unicode release's files would emit new data labelled 15.1.0 (`SIMPLE_UNICODE.unicode_version`, simple_unicode.e:28-32). The `DerivedNormalizationProps.txt` header line carries the version and could be asserted.
- tools/generate_unicode_data.py:162 samples NormalizationTest Part 1 by file line number (`i % 20 != 0`), which depends on comment lines and blank lines in the file, not on case count. It is deterministic for one file but not stable across versions. The header of src/unicode/simple_unicode.e (line 7) says "runs NormalizationTest.txt cases"; the truth is every case of parts 0, 2, 3 and one twentieth of part 1 (generator docstring lines 167-171, written into testing/unicode_normalization_cases.e).
- No finding on correctness of the data logic: read_unicode_data (lines 58-73), the First/Last range handling (64-71), field indexes 12 and 13 for upper and lower (72, 119), the compatibility `~` marker (123), the `Full_Composition_Exclusion` filter (83) and ASCII-only CRLF output (193-196) all match the UnicodeData.txt and DerivedNormalizationProps.txt layouts. The 30,000 character part limit (36-37) stays under the 32,767 manifest limit.
**Suggested Action:** Parse the version from the props header and fail if it differs from VERSION; sample by `len(cases) % 20`; reword the class note to say "a sample".
**Effort:** 3 small edits

### Finding 5: Tables are created and then created again
**Priority:** LOW
**Category:** cleanup
**Classes:** src/unicode/simple_unicode_tables.e
**Evidence:** lines 26-27 create `category_starts` / `category_codes`, and lines 105-106 (in `decode_categories`) create them again; lines 31-32 create `lower_map` / `upper_map`, and lines 37-38 replace them with `mappings (...)`, which creates its own (line 186). Four dead allocations (a few thousand slots) at first use. The postcondition at lines 40-41 is cheap and correct.
**Suggested Action:** Declare the attributes and let the decoders own creation, or let the decoders fill tables created once in `make`.
**Effort:** 4 lines

### Finding 6: Hash probes where a range table or one probe would do
**Priority:** LOW
**Category:** perf
**Classes:** src/unicode/simple_unicode.e
**Evidence:** `class_of` (lines 144-150) probes a HASH_TABLE for every character at or above U+0300, which is every Hebrew and Greek letter, to learn "class 0". The categories use a binary search over run starts; combining classes are stored as ranges in the data (generator lines 105-115) and could use the same shape. `simple_lower` / `simple_upper` (lines 75-87) call `has` then `item`, two probes; `item` already returns 0 as the default for NATURAL_32, so a single probe with a zero test is enough.
**Suggested Action:** Combining-class range table with `run_index`-style search, or a bit-set for "is a nonzero class" in front of the hash. Not urgent: measure first (the library has timing tests under `without_contracts`).
**Effort:** 3 features

### Finding 7: Private once object and feature clause layout
**Priority:** LOW
**Category:** M2 / layout
**Classes:** src/simple_character_properties.e
**Evidence:** lines 173-179 hold a `once` `SIMPLE_UNICODE` (stateless: its only attribute is the shared `tables` once, simple_unicode.e:138-142), and the file now has two `feature {NONE} -- Implementation` clauses (lines 173 and 198) with `feature -- ASCII` between them. Resolved naturally by Finding 1 if SIMPLE_CHARACTER_PROPERTIES inherits or delegates once.
**Effort:** 1 feature moved

## Checked and clean
- `composed` (simple_unicode.e:225-253) blocking rule, Hangul arithmetic (152-160, 181-186, 260-266) and the `nfc` / `nfkc` paths follow UAX #15; no divergence found by reading (conformance tests cover them; not executed here).
- `run_index` binary search (tables.e:67-89) handles code points above U+10FFFF by returning the last run, which the data ends with as Cn (src/unicode/simple_unicode_data.e line 293, `10fffeCn`).
- Hex decoding (tables.e:211-228) relies on lowercase digits, which the generator guarantees (`hx`, generator line 19-20) and the category token split (tables.e:108-109) works because category letters are uppercase.

## Recommended Order
1. Finding 1: a live disagreement, and it is the reason the delegation was started.
2. Finding 2: a one-type-change fix that closes a corruption path before more clients arrive.
3. Finding 3: remove the duplicate postconditions while the class is still small.
4. Findings 4 to 7 as convenience.

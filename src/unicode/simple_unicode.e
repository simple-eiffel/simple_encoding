note
	description: "[
		Full Unicode character properties and normalization forms, from the
		Unicode Character Database (SIMPLE_UNICODE_DATA, generated): the general
		category of every code point, canonical combining classes, simple case
		mappings, and NFD, NFC, NFKD and NFKC (UAX #15, Hangul included).
		Conformance: testing/unicode_tests.e runs NormalizationTest.txt cases.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_UNICODE

create
	make

feature {NONE} -- Initialization

	make
			-- Create a Unicode service (the tables decode once per processor, on first use).
		do
		end

feature -- Access

	unicode_version: STRING_8
			-- The Unicode version of the tables ("15.1.0").
		do
			Result := tables.Unicode_version
		end

feature -- Character properties

	general_category (a_char: CHARACTER_32): STRING_8
			-- The two-letter general category of `a_char': "Lu", "Mn", "Cf", "Cn" (unassigned), ...
			-- A new string each call: the tables stay out of reach (design scan, 2026-10-27).
		do
			Result := category_of (a_char).twin
		ensure
			two_letters: Result.count = 2
		end

	is_combining_mark (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char' a mark (category Mn, Mc or Me)?
		do
			Result := category_of (a_char) [1] = 'M'
		end

	is_format_character (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char' a format character (category Cf: joiners, direction marks, soft hyphen)?
		do
			Result := category_of (a_char).same_string ("Cf")
		end

	is_letter (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char' a letter (category L*)?
		do
			Result := category_of (a_char) [1] = 'L'
		end

	is_letter_or_digit (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char' a letter or a number (category L* or N*)?
		local
			l_kind: CHARACTER_8
		do
			l_kind := category_of (a_char) [1]
			Result := l_kind = 'L' or l_kind = 'N'
		end

	is_in_category (a_char: CHARACTER_32; a_kind: CHARACTER_8): BOOLEAN
			-- Is `a_char''s general category of kind `a_kind' (its first letter: 'L', 'M', 'N', 'P',
			-- 'S', 'Z' or 'C')?
		do
			Result := category_of (a_char) [1] = a_kind
		end

	combining_class (a_char: CHARACTER_32): INTEGER
			-- The canonical combining class of `a_char' (0 for a starter).
		do
			Result := class_of (a_char.natural_32_code)
		ensure
			in_range: Result >= 0 and Result <= 254
		end

	simple_lower (a_char: CHARACTER_32): CHARACTER_32
			-- The simple (one code point) lowercase of `a_char'; itself when it has none.
		do
			Result := a_char
			if tables.lower_map.has (a_char.natural_32_code) then
				Result := tables.lower_map.item (a_char.natural_32_code).to_character_32
			end
		end

	simple_upper (a_char: CHARACTER_32): CHARACTER_32
			-- The simple (one code point) uppercase of `a_char'; itself when it has none.
		do
			Result := a_char
			if tables.upper_map.has (a_char.natural_32_code) then
				Result := tables.upper_map.item (a_char.natural_32_code).to_character_32
			end
		end

feature -- Normalization forms

	nfd (a_text: READABLE_STRING_GENERAL): STRING_32
			-- Canonical decomposition of `a_text' (marks in canonical order: `put_in_canonical_order').
		do
			Result := decomposed (a_text, False)
		end

	nfkd (a_text: READABLE_STRING_GENERAL): STRING_32
			-- Compatibility decomposition of `a_text' (marks in canonical order).
		do
			Result := decomposed (a_text, True)
		end

	nfc (a_text: READABLE_STRING_GENERAL): STRING_32
			-- Canonical composition of `a_text'.
		do
			Result := composed (decomposed (a_text, False))
		end

	nfkc (a_text: READABLE_STRING_GENERAL): STRING_32
			-- Compatibility composition of `a_text'.
		do
			Result := composed (decomposed (a_text, True))
		end

feature -- Status

	is_canonically_ordered (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Does no mark in `a_text' follow a mark of a higher combining class?
		local
			i, l_class, l_previous: INTEGER
		do
			Result := True
			from i := 1 until i > a_text.count or not Result loop
				l_class := class_of (a_text.code (i))
				Result := l_class = 0 or l_previous <= l_class
				l_previous := l_class
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	tables: SIMPLE_UNICODE_TABLES
			-- The decoded tables, one set per processor.
		once
			create Result.make
		end

	category_of (a_char: CHARACTER_32): STRING_8
			-- The table's own category string for `a_char' (never handed out).
		do
			Result := tables.category_codes [tables.run_index (a_char.natural_32_code)]
		end

	class_of (a_code: NATURAL_32): INTEGER
			-- The combining class of code point `a_code'.
		do
			if a_code >= 0x300 then
				Result := tables.combining_classes.item (a_code)
			end
		end

	Hangul_base: NATURAL_32 = 0xAC00
	Hangul_lead: NATURAL_32 = 0x1100
	Hangul_vowel: NATURAL_32 = 0x1161
	Hangul_trail: NATURAL_32 = 0x11A7
	Hangul_lead_count: NATURAL_32 = 19
	Hangul_vowel_count: NATURAL_32 = 21
	Hangul_trail_count: NATURAL_32 = 28
	Hangul_count: NATURAL_32 = 11172
			-- UAX #15's Hangul syllable arithmetic.

	decomposed (a_text: READABLE_STRING_GENERAL; a_compatibility: BOOLEAN): STRING_32
			-- `a_text' fully decomposed (compatibility ones too when `a_compatibility'), marks put in
			-- canonical order.
		local
			i: INTEGER
		do
			create Result.make (a_text.count + a_text.count // 4)
			from i := 1 until i > a_text.count loop
				append_decomposition (Result, a_text.code (i), a_compatibility)
				i := i + 1
			end
			put_in_canonical_order (Result)
		end

	append_decomposition (a_result: STRING_32; a_code: NATURAL_32; a_compatibility: BOOLEAN)
			-- Append the full decomposition of `a_code' to `a_result'.
		local
			l_index, l_trail: NATURAL_32
		do
			if a_code >= Hangul_base and a_code < Hangul_base + Hangul_count then
				l_index := a_code - Hangul_base
				a_result.append_character ((Hangul_lead + l_index // (Hangul_vowel_count * Hangul_trail_count)).to_character_32)
				a_result.append_character ((Hangul_vowel + (l_index \\ (Hangul_vowel_count * Hangul_trail_count)) // Hangul_trail_count).to_character_32)
				l_trail := l_index \\ Hangul_trail_count
				if l_trail > 0 then
					a_result.append_character ((Hangul_trail + l_trail).to_character_32)
				end
			elseif a_compatibility and then attached tables.compatibility_decompositions.item (a_code) as al_parts then
				across al_parts as ic loop
					append_decomposition (a_result, ic, a_compatibility)
				end
			elseif attached tables.canonical_decompositions.item (a_code) as al_parts then
				across al_parts as ic loop
					append_decomposition (a_result, ic, a_compatibility)
				end
			else
				a_result.append_character (a_code.to_character_32)
			end
		end

	put_in_canonical_order (a_text: STRING_32)
			-- Sort each run of marks by combining class, keeping equal classes in order.
		local
			i, j, l_class: INTEGER
			c: CHARACTER_32
		do
			from i := 2 until i > a_text.count loop
				l_class := class_of (a_text.code (i))
				if l_class > 0 then
					c := a_text [i]
					from j := i - 1 until j < 1 or else class_of (a_text.code (j)) <= l_class or else class_of (a_text.code (j)) = 0 loop
						a_text [j + 1] := a_text [j]
						j := j - 1
					end
					a_text [j + 1] := c
				end
				i := i + 1
			end
		ensure
			ordered: is_canonically_ordered (a_text)
			same_length: a_text.count = old a_text.count
		end

	composed (a_text: STRING_32): STRING_32
			-- Canonical composition of the decomposed `a_text' (UAX #15).
		local
			i, l_starter, l_class, l_last_class: INTEGER
			l_code, l_composite: NATURAL_32
		do
			create Result.make (a_text.count)
			from i := 1 until i > a_text.count loop
				l_code := a_text.code (i)
				l_class := class_of (l_code)
				if l_starter > 0 then
					l_composite := composite (Result.code (l_starter), l_code)
				else
					l_composite := 0
				end
				if l_composite > 0 and then (l_last_class < l_class or l_last_class = 0) then
					Result [l_starter] := l_composite.to_character_32
				else
					if l_class = 0 then
						l_starter := Result.count + 1
						l_last_class := 0
					else
						l_last_class := l_class
					end
					Result.append_character (l_code.to_character_32)
				end
				i := i + 1
			end
		end

	composite (a_first, a_second: NATURAL_32): NATURAL_32
			-- The primary composite of the pair, or 0 for none.
		local
			l_index: NATURAL_32
		do
			if a_first >= Hangul_lead and a_first < Hangul_lead + Hangul_lead_count and a_second >= Hangul_vowel and a_second < Hangul_vowel + Hangul_vowel_count then
				Result := Hangul_base + ((a_first - Hangul_lead) * Hangul_vowel_count + (a_second - Hangul_vowel)) * Hangul_trail_count
			elseif a_first >= Hangul_base and a_first < Hangul_base + Hangul_count and a_second > Hangul_trail and a_second < Hangul_trail + Hangul_trail_count then
				l_index := a_first - Hangul_base
				if l_index \\ Hangul_trail_count = 0 then
					Result := a_first + (a_second - Hangul_trail)
				end
			else
				Result := tables.compositions.item (tables.pair_key (a_first, a_second))
			end
		end

end

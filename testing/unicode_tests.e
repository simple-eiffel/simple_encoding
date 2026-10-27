note
	description: "Tests for SIMPLE_UNICODE: general categories, combining classes, simple case mappings, and NFD/NFC/NFKD/NFKC against NormalizationTest.txt"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	UNICODE_TESTS

inherit
	TEST_SET_BASE

feature -- Tests

	test_general_category_full
			-- Every category kind, including the ones the simplified table could not tell.
		local
			u: SIMPLE_UNICODE
		do
			create u.make
			assert ("A is Lu", u.general_category ('A').same_string ("Lu"))
			assert ("a is Ll", u.general_category ('a').same_string ("Ll"))
			assert ("alef is Lo", u.general_category ((0x05D0).to_character_32).same_string ("Lo"))
			assert ("sheva is Mn", u.general_category ((0x05B0).to_character_32).same_string ("Mn"))
			assert ("visarga is Mc", u.general_category ((0x0903).to_character_32).same_string ("Mc"))
			assert ("enclosing circle is Me", u.general_category ((0x20DD).to_character_32).same_string ("Me"))
			assert ("zero-width joiner is Cf", u.general_category ((0x200D).to_character_32).same_string ("Cf"))
			assert ("U+0378 is unassigned", u.general_category ((0x0378).to_character_32).same_string ("Cn"))
			assert ("private use is Co", u.general_category ((0xE000).to_character_32).same_string ("Co"))
			assert ("a surrogate is Cs", u.general_category ((0xD800).to_character_32).same_string ("Cs"))
			assert ("CJK inside a range is Lo", u.general_category ((0x4E2D).to_character_32).same_string ("Lo"))
			assert ("the last code point is Cn", u.general_category ((0x10FFFF).to_character_32).same_string ("Cn"))
			assert ("copyright is So", u.general_category ((0xA9).to_character_32).same_string ("So"))
			assert ("marks", u.is_combining_mark ((0x0301).to_character_32) and not u.is_combining_mark ('e'))
			assert ("version", u.unicode_version.same_string ("15.1.0"))
		end

	test_character_properties_use_the_full_table
			-- SIMPLE_CHARACTER_PROPERTIES.general_category answers from the full table. Before: its
			-- simplified ranges called a Hebrew vowel point "Cn" and a joiner "Cn".
		local
			l_props: SIMPLE_CHARACTER_PROPERTIES
		do
			create l_props.make
			assert ("sheva is Mn", l_props.general_category ((0x05B0).to_character_32).same_string ("Mn"))
			assert ("zero-width joiner is Cf", l_props.general_category ((0x200D).to_character_32).same_string ("Cf"))
			assert ("A is still Lu", l_props.general_category ('A').same_string ("Lu"))
		end

	test_combining_classes
		local
			u: SIMPLE_UNICODE
		do
			create u.make
			assert_integers_equal ("acute", 230, u.combining_class ((0x0301).to_character_32))
			assert_integers_equal ("dot below", 220, u.combining_class ((0x0323).to_character_32))
			assert_integers_equal ("sheva", 10, u.combining_class ((0x05B0).to_character_32))
			assert_integers_equal ("a starter", 0, u.combining_class ('a'))
		end

	test_simple_case_mappings
		local
			u: SIMPLE_UNICODE
		do
			create u.make
			assert ("capital sigma", u.simple_lower ((0x03A3).to_character_32).natural_32_code = 0x03C3)
			assert ("dotted capital I lowers to i", u.simple_lower ((0x0130).to_character_32) = 'i')
			assert ("sharp s has no simple upper", u.simple_upper ((0xDF).to_character_32).natural_32_code = 0xDF)
			assert ("titlecase dz", u.simple_upper ((0x01C5).to_character_32).natural_32_code = 0x01C4)
			assert ("alpha with ypogegrammeni", u.simple_upper ((0x1FB3).to_character_32).natural_32_code = 0x1FBC)
			assert ("Deseret", u.simple_lower ((0x10400).to_character_32).natural_32_code = 0x10428)
			assert ("a digit stays", u.simple_upper ('7') = '7')
		end

	test_normalization_conformance
			-- UAX #15's conformance rules over every generated NormalizationTest.txt case.
		local
			u: SIMPLE_UNICODE
			l_cases: UNICODE_NORMALIZATION_CASES
			c: ARRAY [STRING_32]
			l_read, l_failures: INTEGER
			l_first: STRING_8
		do
			create u.make
			create l_cases
			create l_first.make_empty
			across l_cases.case_lines as ic loop
				if not ic.is_empty then
					l_read := l_read + 1
					c := columns (ic)
					if not (
						same (c [2], u.nfc (c [1])) and same (c [2], u.nfc (c [2])) and same (c [2], u.nfc (c [3])) and
						same (c [4], u.nfc (c [4])) and same (c [4], u.nfc (c [5])) and
						same (c [3], u.nfd (c [1])) and same (c [3], u.nfd (c [2])) and same (c [3], u.nfd (c [3])) and
						same (c [5], u.nfd (c [4])) and same (c [5], u.nfd (c [5])) and
						same (c [4], u.nfkc (c [1])) and same (c [4], u.nfkc (c [2])) and same (c [4], u.nfkc (c [3])) and
						same (c [4], u.nfkc (c [4])) and same (c [4], u.nfkc (c [5])) and
						same (c [5], u.nfkd (c [1])) and same (c [5], u.nfkd (c [2])) and same (c [5], u.nfkd (c [3])) and
						same (c [5], u.nfkd (c [4])) and same (c [5], u.nfkd (c [5])))
					then
						l_failures := l_failures + 1
						if l_first.is_empty then
							l_first := ic
						end
					end
				end
			end
			assert_integers_equal ("every case read", l_cases.case_count, l_read)
			assert_integers_equal ({STRING_8} "no case fails (first: " + l_first + ")", 0, l_failures)
		end

	test_hangul_round_trip
		local
			u: SIMPLE_UNICODE
			l_syllable: STRING_32
		do
			create u.make
			create l_syllable.make_empty
			l_syllable.append_character ((0xAC01).to_character_32)
			assert_integers_equal ("three jamo", 3, u.nfd (l_syllable).count)
			assert ("composed back", same (l_syllable, u.nfc (u.nfd (l_syllable))))
		end

feature {NONE} -- Implementation

	columns (a_line: STRING_8): ARRAY [STRING_32]
			-- The five columns of a case line as text.
		local
			l_column: STRING_32
			i: INTEGER
		do
			create Result.make_filled (create {STRING_32}.make_empty, 1, 5)
			i := 1
			across a_line.split (';') as ic loop
				create l_column.make_empty
				across ic.split ('.') as jc loop
					l_column.append_character (hex (jc).to_character_32)
				end
				if i <= 5 then
					Result [i] := l_column
				end
				i := i + 1
			end
		end

	hex (a_text: STRING_8): NATURAL_32
			-- Lowercase hexadecimal `a_text'.
		do
			across a_text as ic loop
				if ic >= 'a' then
					Result := Result * 16 + (ic.code - ('a').code + 10).to_natural_32
				else
					Result := Result * 16 + (ic.code - ('0').code).to_natural_32
				end
			end
		end

	same (a, b: STRING_32): BOOLEAN
		do
			Result := a.same_string (b)
		end

end

note
	description: "Tests for utility classes: SIMPLE_CHARACTER_PROPERTIES, SIMPLE_ENCODING_DETECTOR, SIMPLE_CODEC_REGISTRY"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	UTILITY_TESTS

inherit
	TEST_SET_BASE
		redefine
			on_prepare
		end

feature {NONE} -- Initialization

	on_prepare
			-- Setup
		do
			create props.make
			create detector.make
			create registry.make
		end

feature -- Access

	props: SIMPLE_CHARACTER_PROPERTIES
	detector: SIMPLE_ENCODING_DETECTOR
	registry: SIMPLE_CODEC_REGISTRY

feature -- Character Properties Tests

	test_is_letter_ascii
			-- Test ASCII letter detection
		do
			assert ("A is letter", props.is_letter ('A'))
			assert ("z is letter", props.is_letter ('z'))
			assert ("5 is not letter", not props.is_letter ('5'))
			assert ("exclaim is not letter", not props.is_letter ('!'))
		end

	test_is_letter_extended
			-- Test extended letter detection
		do
			assert ("e-acute is letter", props.is_letter ((0xE9).to_character_32))
			assert ("Alpha is letter", props.is_letter ((0x03B1).to_character_32))
			assert ("CJK is letter", props.is_letter ((0x4E00).to_character_32))
		end

	test_is_digit
			-- Test digit detection
		do
			assert ("0 is digit", props.is_digit ('0'))
			assert ("9 is digit", props.is_digit ('9'))
			assert ("A is not digit", not props.is_digit ('A'))
		end

	test_is_hex_digit
			-- Test hex digit detection
		do
			assert ("0 is hex", props.is_hex_digit ('0'))
			assert ("F is hex", props.is_hex_digit ('F'))
			assert ("a is hex", props.is_hex_digit ('a'))
			assert ("G is not hex", not props.is_hex_digit ('G'))
		end

	test_is_alphanumeric
			-- Test alphanumeric detection
		do
			assert ("A is alphanum", props.is_alphanumeric ('A'))
			assert ("5 is alphanum", props.is_alphanumeric ('5'))
			assert ("exclaim is not alphanum", not props.is_alphanumeric ('!'))
		end

	test_is_whitespace
			-- Test whitespace detection
		do
			assert ("Space is whitespace", props.is_whitespace (' '))
			assert ("Tab is whitespace", props.is_whitespace ('%T'))
			assert ("LF is whitespace", props.is_whitespace ('%N'))
			assert ("NBSP is whitespace", props.is_whitespace ((0xA0).to_character_32))
			assert ("A is not whitespace", not props.is_whitespace ('A'))
		end

	test_is_control
			-- Test control character detection
		do
			assert ("NUL is control", props.is_control ((0).to_character_32))
			assert ("DEL is control", props.is_control ((0x7F).to_character_32))
			assert ("0x90 is control", props.is_control ((0x90).to_character_32))
			assert ("A is not control", not props.is_control ('A'))
		end

	test_is_punctuation
			-- Test punctuation detection
		do
			assert ("dot is punctuation", props.is_punctuation ('.'))
			assert ("exclaim is punctuation", props.is_punctuation ('!'))
			assert ("question is punctuation", props.is_punctuation ('?'))
			assert ("A is not punctuation", not props.is_punctuation ('A'))
		end

	test_is_ascii
			-- Test ASCII detection
		do
			assert ("A is ASCII", props.is_ascii ('A'))
			assert ("DEL is ASCII", props.is_ascii ((127).to_character_32))
			assert ("128 is not ASCII", not props.is_ascii ((128).to_character_32))
		end

	test_is_printable_ascii
			-- Test printable ASCII detection
		do
			assert ("A is printable", props.is_printable_ascii ('A'))
			assert ("Space is printable", props.is_printable_ascii (' '))
			assert ("NUL is not printable", not props.is_printable_ascii ((0).to_character_32))
			assert ("DEL is not printable", not props.is_printable_ascii ((127).to_character_32))
		end

	test_case_functions
			-- Test case detection and conversion
		do
			assert ("A is upper", props.is_upper ('A'))
			assert ("a is lower", props.is_lower ('a'))
			assert ("to_upper a", props.to_upper ('a') = 'A')
			assert ("to_lower A", props.to_lower ('A') = 'a')
		end

	test_general_category
			-- Test Unicode general category
		do
			assert ("A is Lu", props.general_category ('A').same_string ("Lu"))
			assert ("a is Ll", props.general_category ('a').same_string ("Ll"))
			assert ("5 is Nd", props.general_category ('5').same_string ("Nd"))
			assert ("Space is Zs", props.general_category (' ').same_string ("Zs"))
		end

feature -- Encoding Detector Tests

	test_detect_utf8_bom
			-- Test UTF-8 BOM detection
		local
			l_bytes: STRING_8
			l_detected: detachable STRING_32
		do
			create l_bytes.make (10)
			l_bytes.append_character ((0xEF).to_character_8)
			l_bytes.append_character ((0xBB).to_character_8)
			l_bytes.append_character ((0xBF).to_character_8)
			l_bytes.append ("Hello")
			assert ("Has UTF-8 BOM", detector.has_utf8_bom (l_bytes))
			l_detected := detector.detect_encoding (l_bytes)
			assert ("Detected UTF-8", l_detected /= Void and then l_detected.same_string ("UTF-8"))
		end

	test_detect_utf16_le_bom
			-- Test UTF-16 LE BOM detection
		local
			l_bytes: STRING_8
		do
			create l_bytes.make (4)
			l_bytes.append_character ((0xFF).to_character_8)
			l_bytes.append_character ((0xFE).to_character_8)
			l_bytes.append ("AB")
			assert ("Has UTF-16 LE BOM", detector.has_utf16_le_bom (l_bytes))
		end

	test_detect_utf16_be_bom
			-- Test UTF-16 BE BOM detection
		local
			l_bytes: STRING_8
		do
			create l_bytes.make (4)
			l_bytes.append_character ((0xFE).to_character_8)
			l_bytes.append_character ((0xFF).to_character_8)
			assert ("Has UTF-16 BE BOM", detector.has_utf16_be_bom (l_bytes))
		end

	test_detect_valid_utf8
			-- Test valid UTF-8 detection (no BOM)
		local
			l_bytes: STRING_8
			l_detected: detachable STRING_32
		do
			create l_bytes.make (10)
			l_bytes.append ("caf")
			l_bytes.append_character ((0xC3).to_character_8)
			l_bytes.append_character ((0xA9).to_character_8)
			assert ("Is valid UTF-8", detector.is_valid_utf8 (l_bytes))
			l_detected := detector.detect_encoding (l_bytes)
			assert ("Detected UTF-8", l_detected /= Void and then l_detected.same_string ("UTF-8"))
		end

	test_detect_ascii
			-- Test ASCII detection
		local
			l_bytes: STRING_8
		do
			l_bytes := "Hello World 123"
			assert ("Looks like ASCII", detector.looks_like_ascii (l_bytes))
			assert ("ASCII is valid UTF-8", detector.is_valid_utf8 (l_bytes))
		end

	test_detect_invalid_utf8
			-- Test invalid UTF-8 detection
		local
			l_bytes: STRING_8
			l_detected: detachable STRING_32
		do
			create l_bytes.make (5)
			l_bytes.append_character ((0x80).to_character_8)
			l_bytes.append ("test")
			assert ("Invalid UTF-8", not detector.is_valid_utf8 (l_bytes))
			l_detected := detector.detect_encoding (l_bytes)
			assert ("Falls back to ISO-8859-1", l_detected /= Void and then l_detected.same_string ("ISO-8859-1"))
		end

	test_strip_bom
			-- Test BOM stripping
		local
			l_bytes, l_stripped: STRING_8
		do
			create l_bytes.make (10)
			l_bytes.append_character ((0xEF).to_character_8)
			l_bytes.append_character ((0xBB).to_character_8)
			l_bytes.append_character ((0xBF).to_character_8)
			l_bytes.append ("Hello")
			l_stripped := detector.strip_bom (l_bytes)
			assert ("BOM stripped", l_stripped.same_string ("Hello"))
		end

	test_has_multibyte_utf8
			-- Test multibyte detection
		local
			l_bytes: STRING_8
		do
			assert ("ASCII no multibyte", not detector.has_multibyte_utf8 ("Hello"))
			create l_bytes.make (5)
			l_bytes.append_character ((0xC3).to_character_8)
			l_bytes.append_character ((0xA9).to_character_8)
			assert ("Has multibyte", detector.has_multibyte_utf8 (l_bytes))
		end

	test_high_byte_percentage
			-- Test high byte percentage calculation
		local
			l_bytes: STRING_8
			l_pct: REAL_64
		do
			l_bytes := "AAAA"
			l_pct := detector.high_byte_percentage (l_bytes)
			assert ("All ASCII = 0 percent", l_pct.abs < 0.001)
			create l_bytes.make (4)
			l_bytes.append_character ((0x80).to_character_8)
			l_bytes.append_character ((0x80).to_character_8)
			l_bytes.append_character ('A')
			l_bytes.append_character ('B')
			l_pct := detector.high_byte_percentage (l_bytes)
			assert ("Half high = 50 percent", (l_pct - 0.5).abs < 0.001)
		end

feature -- Codec Registry Tests

	test_registry_has_builtins
			-- Test built-in codecs are available
		do
			assert ("Has ISO-8859-1", registry.has_codec ("ISO-8859-1"))
			assert ("Has ISO-8859-15", registry.has_codec ("ISO-8859-15"))
			assert ("Has Windows-1252", registry.has_codec ("Windows-1252"))
		end

	test_registry_aliases
			-- Test codec name aliases
		do
			assert ("Has latin1 alias", registry.has_codec ("latin1"))
			assert ("Has LATIN-1 alias", registry.has_codec ("LATIN-1"))
			assert ("Has cp1252 alias", registry.has_codec ("cp1252"))
			assert ("Has WIN1252 alias", registry.has_codec ("WIN1252"))
		end

	test_registry_codec_by_name
			-- Test retrieving codecs by name
		do
			assert ("ISO-8859-1 exists", registry.codec_by_name ("ISO-8859-1") /= Void)
			assert ("latin1 exists", registry.codec_by_name ("latin1") /= Void)
		end

	test_registry_unknown_codec
			-- Test unknown codec returns Void
		do
			assert ("Unknown codec is Void", registry.codec_by_name ("UNKNOWN-ENCODING") = Void)
		end

	test_registry_all_codec_names
			-- Test listing all codecs
		local
			l_names: ARRAYED_LIST [STRING_32]
		do
			l_names := registry.all_codec_names
			assert ("At least 3 codecs", l_names.count >= 3)
		end

	test_registry_counts
			-- Test codec counting
		do
			assert ("3 built-in codecs", registry.builtin_codec_count = 3)
			assert ("Total >= 3", registry.total_codec_count >= 3)
		end

end

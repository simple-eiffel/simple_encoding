note
	description: "Tests for codec classes: SIMPLE_ISO_8859_1_CODEC, SIMPLE_ISO_8859_15_CODEC, SIMPLE_WINDOWS_1252_CODEC"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	CODEC_TESTS

inherit
	TEST_SET_BASE
		redefine
			on_prepare
		end

feature {NONE} -- Initialization

	on_prepare
			-- Setup
		do
			create latin1.make
			create latin9.make
			create win1252.make
		end

feature -- Access

	latin1: SIMPLE_ISO_8859_1_CODEC
	latin9: SIMPLE_ISO_8859_15_CODEC
	win1252: SIMPLE_WINDOWS_1252_CODEC

feature -- ISO-8859-1 Tests

	test_latin1_ascii_roundtrip
			-- Test ASCII roundtrip through Latin-1
		local
			l_input: STRING_32
			l_encoded: STRING_8
			l_decoded: STRING_32
		do
			l_input := "Hello World 123"
			l_encoded := latin1.encode_string (l_input)
			l_decoded := latin1.decode_string (l_encoded)
			assert ("ASCII roundtrip", l_decoded.same_string (l_input))
			assert ("No error", not latin1.has_error)
		end

	test_latin1_high_chars
			-- Test Latin-1 characters above 127
		local
			l_input: STRING_32
			l_encoded: STRING_8
			l_decoded: STRING_32
		do
			create l_input.make (4)
			l_input.append ("caf")
			l_input.append_code (233)  -- e-acute (U+00E9)
			l_encoded := latin1.encode_string (l_input)
			l_decoded := latin1.decode_string (l_encoded)
			assert ("High chars roundtrip", l_decoded.same_string (l_input))
		end

	test_latin1_full_range
			-- Test all 256 Latin-1 characters
		local
			l_input: STRING_32
			i: INTEGER
		do
			create l_input.make (256)
			from i := 0 until i > 255 loop
				l_input.append_code (i.to_natural_32)
				i := i + 1
			end
			assert ("Full range encoding", latin1.encode_string (l_input).count = 256)
		end

	test_latin1_unencodable
			-- Test character outside Latin-1 range
		local
			l_input: STRING_32
			l_encoded: STRING_8
		do
			create l_input.make (10)
			l_input.append ("Euro: ")
			l_input.append_code (0x20AC)  -- Euro sign (not in Latin-1)
			l_encoded := latin1.encode_string (l_input)
			assert ("Has error", latin1.has_error)
			assert ("Replacement used", l_encoded.has ('?'))
		end

	test_latin1_can_encode
			-- Test can_encode queries
		do
			assert ("Can encode A", latin1.can_encode ('A'))
			assert ("Can encode 255", latin1.can_encode ((255).to_character_32))
			assert ("Cannot encode Euro", not latin1.can_encode ((0x20AC).to_character_32))
		end

feature -- ISO-8859-15 Tests

	test_latin9_euro_sign
			-- Test Euro sign encoding (key Latin-9 addition)
		local
			l_input: STRING_32
			l_encoded: STRING_8
			l_decoded: STRING_32
		do
			create l_input.make (10)
			l_input.append ("Price: 50")
			l_input.append_code (0x20AC)  -- Euro
			l_encoded := latin9.encode_string (l_input)
			assert ("Euro encoded as 0xA4", l_encoded [l_encoded.count].code = 0xA4)
			l_decoded := latin9.decode_string (l_encoded)
			assert ("Euro roundtrip", l_decoded.same_string (l_input))
		end

	test_latin9_special_chars
			-- Test all 8 special Latin-9 characters
		local
			l_specials: STRING_32
			l_encoded: STRING_8
			l_decoded: STRING_32
		do
			create l_specials.make (8)
			l_specials.append_code (0x20AC)  -- Euro
			l_specials.append_code (0x0160)  -- S caron
			l_specials.append_code (0x0161)  -- s caron
			l_specials.append_code (0x017D)  -- Z caron
			l_specials.append_code (0x017E)  -- z caron
			l_specials.append_code (0x0152)  -- OE
			l_specials.append_code (0x0153)  -- oe
			l_specials.append_code (0x0178)  -- Y diaeresis
			l_encoded := latin9.encode_string (l_specials)
			assert ("8 special chars", l_encoded.count = 8)
			l_decoded := latin9.decode_string (l_encoded)
			assert ("Special chars roundtrip", l_decoded.same_string (l_specials))
		end

	test_latin9_replaced_positions
			-- Test Latin-1 positions replaced in Latin-9
		local
			l_byte: STRING_8
			l_decoded: CHARACTER_32
		do
			-- 0xA4 in Latin-1 is currency sign, in Latin-9 is Euro
			create l_byte.make (1)
			l_byte.append_character ((0xA4).to_character_8)
			l_decoded := latin9.decode_string (l_byte).item (1)
			assert ("0xA4 decodes to Euro", l_decoded.natural_32_code = 0x20AC)
		end

feature -- Windows-1252 Tests

	test_win1252_smart_quotes
			-- Test smart quote encoding
		local
			l_input: STRING_32
			l_encoded: STRING_8
			l_decoded: STRING_32
		do
			create l_input.make (4)
			l_input.append_code (0x201C)  -- Left double quote
			l_input.append_code (0x2018)  -- Left single quote
			l_input.append_code (0x2019)  -- Right single quote
			l_input.append_code (0x201D)  -- Right double quote
			l_encoded := win1252.encode_string (l_input)
			assert ("4 quotes", l_encoded.count = 4)
			l_decoded := win1252.decode_string (l_encoded)
			assert ("Smart quotes roundtrip", l_decoded.same_string (l_input))
		end

	test_win1252_extended_chars
			-- Test Windows-1252 extended range (0x80-0x9F)
		local
			l_input: STRING_32
			l_encoded: STRING_8
			l_decoded: STRING_32
		do
			create l_input.make (5)
			l_input.append_code (0x20AC)  -- Euro (0x80)
			l_input.append_code (0x2022)  -- Bullet (0x95)
			l_input.append_code (0x2013)  -- En dash (0x96)
			l_input.append_code (0x2014)  -- Em dash (0x97)
			l_input.append_code (0x2122)  -- Trademark (0x99)
			l_encoded := win1252.encode_string (l_input)
			l_decoded := win1252.decode_string (l_encoded)
			assert ("Extended chars roundtrip", l_decoded.same_string (l_input))
		end

	test_win1252_undefined_bytes
			-- Test undefined bytes (0x81, 0x8D, etc.) decode to replacement
		local
			l_byte: STRING_8
			l_decoded: STRING_32
		do
			create l_byte.make (1)
			l_byte.append_character ((0x81).to_character_8)  -- Undefined
			l_decoded := win1252.decode_string (l_byte)
			assert ("Undefined decodes to replacement", l_decoded.item (1).natural_32_code = 0xFFFD)
		end

	test_win1252_ascii_pass_through
			-- Test ASCII unchanged
		local
			l_input: STRING_32
			l_encoded: STRING_8
		do
			l_input := "ABC 123"
			l_encoded := win1252.encode_string (l_input)
			assert ("ASCII pass-through", l_encoded.same_string ("ABC 123"))
		end

feature -- Codec Properties Tests

	test_codec_names
			-- Test codec name properties
		do
			assert ("Latin-1 name", latin1.name.same_string ("ISO-8859-1"))
			assert ("Latin-9 name", latin9.name.same_string ("ISO-8859-15"))
			assert ("Win1252 name", win1252.name.same_string ("Windows-1252"))
		end

	test_codec_single_byte
			-- Test is_single_byte property
		do
			assert ("Latin-1 is single byte", latin1.is_single_byte)
			assert ("Latin-9 is single byte", latin9.is_single_byte)
			assert ("Win1252 is single byte", win1252.is_single_byte)
		end

end

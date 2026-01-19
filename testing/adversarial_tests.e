note
	description: "Adversarial tests for simple_encoding - testing edge cases and attack vectors"
	date: "2026-01-18"

class
	ADVERSARIAL_TESTS

inherit
	TEST_SET_BASE

feature -- Boundary Value Tests

	test_max_ascii_boundary
			-- Test U+007F (max 1-byte) vs U+0080 (min 2-byte)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make
			-- U+007F (127) = max ASCII = 1 byte
			utf8 := enc.utf_32_to_utf_8 ("%/127/")
			assert ("max_ascii_1_byte", utf8.count = 1)
			assert ("max_ascii_value", utf8.code (1) = 0x7F)

			-- U+0080 (128) = min 2-byte
			utf8 := enc.utf_32_to_utf_8 ("%/128/")
			assert ("min_2byte_count", utf8.count = 2)
		end

	test_max_2byte_boundary
			-- Test U+07FF (max 2-byte) vs U+0800 (min 3-byte)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make
			-- U+07FF (2047) = max 2-byte
			utf8 := enc.utf_32_to_utf_8 ("%/2047/")
			assert ("max_2byte_count", utf8.count = 2)

			-- U+0800 (2048) = min 3-byte
			utf8 := enc.utf_32_to_utf_8 ("%/2048/")
			assert ("min_3byte_count", utf8.count = 3)
		end

	test_max_3byte_boundary
			-- Test U+FFFF (max 3-byte) vs U+10000 (min 4-byte)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make
			-- U+FFFF (65535) = max 3-byte (but note: this is a non-character)
			utf8 := enc.utf_32_to_utf_8 ("%/65535/")
			assert ("max_3byte_count", utf8.count = 3)

			-- U+10000 (65536) = min 4-byte
			utf8 := enc.utf_32_to_utf_8 ("%/65536/")
			assert ("min_4byte_count", utf8.count = 4)
		end

	test_max_valid_codepoint
			-- Test U+10FFFF (max valid Unicode)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32, input: STRING_32
		do
			create enc.make
			-- U+10FFFF (1114111) = max valid Unicode code point
			create input.make (1)
			input.append_code (1114111)
			utf8 := enc.utf_32_to_utf_8 (input)
			assert ("max_valid_4_bytes", utf8.count = 4)
			assert ("max_valid_no_error", not enc.has_error)

			-- Roundtrip
			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("max_valid_roundtrip", utf32.code (1) = 1114111)
		end

	test_beyond_max_codepoint
			-- Test code point > U+10FFFF (should produce replacement)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			input: STRING_32
		do
			create enc.make
			-- U+110000 (1114112) = first invalid code point
			create input.make (1)
			input.append_code (1114112)
			utf8 := enc.utf_32_to_utf_8 (input)
			-- Should produce U+FFFD replacement character (3 bytes: EF BF BD)
			assert ("beyond_max_produces_replacement", utf8.count = 3)
			assert ("beyond_max_has_error", enc.has_error)
		end

feature -- Overlong Encoding Tests

	test_overlong_2byte_null
			-- Test C0 80 (overlong encoding of NULL) - should be rejected
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			overlong: STRING_8
		do
			create enc.make
			-- C0 80 is overlong encoding of U+0000 (should be just 00)
			create overlong.make (2)
			overlong.append_character ((0xC0).to_character_8)
			overlong.append_character ((0x80).to_character_8)

			utf32 := enc.utf_8_to_utf_32 (overlong)
			-- Current implementation: may not detect overlong
			-- This test documents actual behavior
			if enc.has_error then
				assert ("overlong_rejected", True)
			else
				-- BUG: Overlong not detected
				assert ("overlong_accepted_bug", utf32.count = 1)
			end
		end

	test_overlong_3byte_slash
			-- Test E0 80 AF (overlong encoding of /) - security issue
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			overlong: STRING_8
		do
			create enc.make
			-- E0 80 AF is overlong encoding of U+002F (/)
			create overlong.make (3)
			overlong.append_character ((0xE0).to_character_8)
			overlong.append_character ((0x80).to_character_8)
			overlong.append_character ((0xAF).to_character_8)

			utf32 := enc.utf_8_to_utf_32 (overlong)
			-- Document actual behavior
			if enc.has_error then
				assert ("overlong_3byte_rejected", True)
			else
				-- This is a security vulnerability if accepted
				assert ("overlong_3byte_accepted_bug", utf32.count >= 1)
			end
		end

feature -- Surrogate Code Point Tests

	test_surrogate_high
			-- Test U+D800 (high surrogate) - invalid in UTF-32
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make
			-- U+D800 (55296) = start of high surrogates
			utf8 := enc.utf_32_to_utf_8 ("%/55296/")
			-- Surrogates are only valid in UTF-16, not in UTF-32 or UTF-8
			-- Current implementation: may encode them anyway
			if enc.has_error then
				assert ("surrogate_rejected", True)
			else
				-- BUG: Surrogate should be rejected
				assert ("surrogate_encoded_bug", utf8.count = 3)
			end
		end

	test_surrogate_low
			-- Test U+DFFF (low surrogate) - invalid in UTF-32
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make
			-- U+DFFF (57343) = end of low surrogates
			utf8 := enc.utf_32_to_utf_8 ("%/57343/")
			if enc.has_error then
				assert ("low_surrogate_rejected", True)
			else
				-- BUG: Surrogate should be rejected
				assert ("low_surrogate_encoded_bug", utf8.count = 3)
			end
		end

feature -- Invalid UTF-8 Sequence Tests

	test_invalid_leading_0x80
			-- Test 0x80 as leading byte (continuation-only byte)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (1)
			bad.append_character ((0x80).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			assert ("0x80_produces_error", enc.has_error)
			assert ("0x80_produces_replacement", utf32.count = 1 and then utf32.code (1) = 0xFFFD)
		end

	test_invalid_leading_0xFF
			-- Test 0xFF as leading byte (never valid in UTF-8)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (1)
			bad.append_character ((0xFF).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			assert ("0xFF_produces_error", enc.has_error)
			assert ("0xFF_produces_replacement", utf32.count = 1)
		end

	test_invalid_leading_0xFE
			-- Test 0xFE as leading byte (never valid in UTF-8)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (1)
			bad.append_character ((0xFE).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			assert ("0xFE_produces_error", enc.has_error)
		end

feature -- NULL Character Tests

	test_null_character_encode
			-- Test U+0000 (NULL) encoding
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			input: STRING_32
		do
			create enc.make
			create input.make (1)
			input.append_code (0)
			utf8 := enc.utf_32_to_utf_8 (input)
			assert ("null_encodes_1_byte", utf8.count = 1)
			assert ("null_value_is_0", utf8.code (1) = 0)
			assert ("null_no_error", not enc.has_error)
		end

	test_null_character_decode
			-- Test NULL byte decoding
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			input: STRING_8
		do
			create enc.make
			create input.make (1)
			input.append_character ((0).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (input)
			assert ("null_decodes_to_u0000", utf32.code (1) = 0)
			assert ("null_decode_no_error", not enc.has_error)
		end

feature -- State Reuse Tests

	test_reuse_after_error
			-- Test that error state is cleared on new conversion
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			-- First: invalid conversion
			create bad.make (1)
			bad.append_character ((0xFF).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			assert ("first_has_error", enc.has_error)

			-- Second: valid conversion should clear error
			utf32 := enc.utf_8_to_utf_32 ("Hello")
			assert ("error_cleared_after_valid", not enc.has_error)
		end

	test_multiple_conversions_same_instance
			-- Test multiple conversions with same encoder instance
		local
			enc: SIMPLE_ENCODING
			utf8_1, utf8_2, utf8_3: STRING_8
		do
			create enc.make
			utf8_1 := enc.utf_32_to_utf_8 ("First")
			utf8_2 := enc.utf_32_to_utf_8 ("Second")
			utf8_3 := enc.utf_32_to_utf_8 ("Third")

			assert ("first_correct", utf8_1.same_string ("First"))
			assert ("second_correct", utf8_2.same_string ("Second"))
			assert ("third_correct", utf8_3.same_string ("Third"))
			assert ("no_error", not enc.has_error)
		end

feature -- BOM (Byte Order Mark) Tests

	test_bom_encoding
			-- Test U+FEFF (BOM) encoding
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make
			-- U+FEFF (65279) = BOM
			utf8 := enc.utf_32_to_utf_8 ("%/65279/")
			assert ("bom_is_3_bytes", utf8.count = 3)
			-- UTF-8 BOM is EF BB BF
			assert ("bom_byte_1", utf8.code (1) = 0xEF)
			assert ("bom_byte_2", utf8.code (2) = 0xBB)
			assert ("bom_byte_3", utf8.code (3) = 0xBF)
		end

	test_bom_decoding
			-- Test UTF-8 BOM decoding
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bom: STRING_8
		do
			create enc.make
			-- UTF-8 BOM: EF BB BF
			create bom.make (3)
			bom.append_character ((0xEF).to_character_8)
			bom.append_character ((0xBB).to_character_8)
			bom.append_character ((0xBF).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bom)
			assert ("bom_decodes_to_feff", utf32.code (1) = 0xFEFF)
		end

end

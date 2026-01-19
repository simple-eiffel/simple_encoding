note
	description: "Tests for SIMPLE_ENCODING UTF conversion"
	date: "$Date$"
	revision: "$Revision$"

class
	ENCODING_TESTS

inherit
	TEST_SET_BASE

feature -- ASCII Tests

	test_ascii_roundtrip
			-- Test ASCII characters roundtrip UTF-32 -> UTF-8 -> UTF-32
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
		do
			create enc.make
			utf8 := enc.utf_32_to_utf_8 ("Hello, World!")
			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("ascii_roundtrip", utf32.same_string ("Hello, World!"))
			assert ("ascii_length", utf8.count = 13)
			assert ("no_error", not enc.has_error)
		end

feature -- Extended Latin Tests

	test_latin_extended
			-- Test Latin extended characters (2-byte UTF-8)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
		do
			create enc.make
			create input.make_from_string ("Caf%/233/ na%/239/ve")  -- Cafe naive with accents
			utf8 := enc.utf_32_to_utf_8 (input)
			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("latin_roundtrip", utf32.same_string (input))
			assert ("no_error", not enc.has_error)
		end

feature -- CJK Tests

	test_cjk_characters
			-- Test CJK characters (3-byte UTF-8)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
		do
			create enc.make
			create input.make_from_string ("%/20013/%/25991/")  -- Chinese characters
			utf8 := enc.utf_32_to_utf_8 (input)
			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("cjk_roundtrip", utf32.same_string (input))
			assert ("cjk_utf8_length", utf8.count = 6)  -- 2 chars * 3 bytes
			assert ("no_error", not enc.has_error)
		end

feature -- 4-byte Tests

	test_emoji_4byte
			-- Test emoji (4-byte UTF-8 characters)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
		do
			create enc.make
			create input.make_from_string ("%/128512/")  -- Grinning face emoji
			utf8 := enc.utf_32_to_utf_8 (input)
			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("emoji_roundtrip", utf32.same_string (input))
			assert ("emoji_utf8_length", utf8.count = 4)  -- 4 bytes for emoji
			assert ("no_error", not enc.has_error)
		end

feature -- Edge Case Tests

	test_empty_string
			-- Test empty string conversion
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
		do
			create enc.make
			utf8 := enc.utf_32_to_utf_8 ("")
			utf32 := enc.utf_8_to_utf_32 ("")
			assert ("empty_to_utf8", utf8.is_empty)
			assert ("empty_to_utf32", utf32.is_empty)
			assert ("no_error", not enc.has_error)
		end

	test_mixed_content
			-- Test string with ASCII, Latin, CJK, and emoji
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
		do
			create enc.make
			-- Mix: "Hi" + e-acute + Chinese + emoji
			create input.make_from_string ("Hi%/233/%/20013/%/128512/")
			utf8 := enc.utf_32_to_utf_8 (input)
			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("mixed_roundtrip", utf32.same_string (input))
			-- 2 ASCII (2) + 1 Latin (2) + 1 CJK (3) + 1 emoji (4) = 11 bytes
			assert ("mixed_utf8_length", utf8.count = 11)
			assert ("no_error", not enc.has_error)
		end

feature -- Byte Count Verification

	test_utf8_byte_counts
			-- Verify correct byte counts for different character ranges
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
		do
			create enc.make

			-- ASCII (1 byte)
			utf8 := enc.utf_32_to_utf_8 ("A")
			assert ("ascii_1_byte", utf8.count = 1)

			-- Latin extended (2 bytes)
			utf8 := enc.utf_32_to_utf_8 ("%/233/")  -- e-acute
			assert ("latin_2_bytes", utf8.count = 2)

			-- CJK (3 bytes)
			utf8 := enc.utf_32_to_utf_8 ("%/20013/")  -- Chinese character
			assert ("cjk_3_bytes", utf8.count = 3)

			-- Emoji (4 bytes)
			utf8 := enc.utf_32_to_utf_8 ("%/128512/")  -- Grinning face
			assert ("emoji_4_bytes", utf8.count = 4)

			assert ("no_error", not enc.has_error)
		end

feature -- Error Handling Tests

	test_invalid_utf8_sequence
			-- Test handling of invalid UTF-8 sequences
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			invalid_utf8: STRING_8
		do
			create enc.make
			-- Create invalid UTF-8: 0x80 is not a valid leading byte
			create invalid_utf8.make (3)
			invalid_utf8.append_character ((0x80).to_character_8)
			invalid_utf8.append_character ('A')
			invalid_utf8.append_character ('B')

			utf32 := enc.utf_8_to_utf_32 (invalid_utf8)
			assert ("has_error", enc.has_error)
			-- Should have replacement character followed by A and B
			assert ("correct_length", utf32.count = 3)
		end

	test_truncated_utf8
			-- Test handling of truncated UTF-8 sequences
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			truncated: STRING_8
		do
			create enc.make
			-- Create truncated 2-byte sequence (missing continuation byte)
			create truncated.make (2)
			truncated.append_character ((0xC3).to_character_8)  -- Start of 2-byte seq
			truncated.append_character ('X')                    -- Not a continuation

			utf32 := enc.utf_8_to_utf_32 (truncated)
			assert ("has_error", enc.has_error)
			-- Should have replacement character followed by X
			assert ("correct_length", utf32.count = 2)
		end

	test_error_tracking
			-- Test error message tracking
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			invalid_utf8: STRING_8
		do
			create enc.make

			-- First: valid conversion clears errors
			utf32 := enc.utf_8_to_utf_32 ("Hello")
			assert ("no_error_valid", not enc.has_error)

			-- Second: invalid conversion sets error
			create invalid_utf8.make (1)
			invalid_utf8.append_character ((0xFF).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (invalid_utf8)
			assert ("has_error_invalid", enc.has_error)
			assert ("error_has_content", not enc.last_error.is_empty)

			-- Third: new valid conversion clears error
			utf32 := enc.utf_8_to_utf_32 ("World")
			assert ("error_cleared", not enc.has_error)
		end

end

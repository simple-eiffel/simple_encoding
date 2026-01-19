note
	description: "Stress tests for simple_encoding - testing volume and performance"
	date: "2026-01-18"

class
	STRESS_TESTS

inherit
	TEST_SET_BASE

feature -- Volume Tests

	test_long_ascii_string
			-- Test encoding/decoding long ASCII string (10000 chars)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
			i: INTEGER
		do
			create enc.make
			create input.make (10000)
			from i := 1 until i > 10000 loop
				input.append_character (('A').to_character_32)
				i := i + 1
			end

			utf8 := enc.utf_32_to_utf_8 (input)
			assert ("long_ascii_correct_length", utf8.count = 10000)

			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("long_ascii_roundtrip", utf32.same_string (input))
			assert ("long_ascii_no_error", not enc.has_error)
		end

	test_long_unicode_string
			-- Test encoding/decoding long Unicode string (5000 CJK chars = 15000 bytes)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
			i: INTEGER
		do
			create enc.make
			create input.make (5000)
			from i := 1 until i > 5000 loop
				input.append_code (0x4E2D)  -- Chinese character
				i := i + 1
			end

			utf8 := enc.utf_32_to_utf_8 (input)
			assert ("long_unicode_correct_length", utf8.count = 15000)  -- 5000 * 3 bytes

			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("long_unicode_roundtrip", utf32.same_string (input))
			assert ("long_unicode_no_error", not enc.has_error)
		end

	test_long_4byte_string
			-- Test encoding/decoding long 4-byte character string (2500 emoji = 10000 bytes)
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
			i: INTEGER
		do
			create enc.make
			create input.make (2500)
			from i := 1 until i > 2500 loop
				input.append_code (0x1F600)  -- Grinning face emoji
				i := i + 1
			end

			utf8 := enc.utf_32_to_utf_8 (input)
			assert ("long_4byte_correct_length", utf8.count = 10000)  -- 2500 * 4 bytes

			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("long_4byte_roundtrip", utf32.same_string (input))
			assert ("long_4byte_no_error", not enc.has_error)
		end

feature -- Repeated Operations Tests

	test_repeated_conversions
			-- Test 100 conversions with same encoder
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			i: INTEGER
		do
			create enc.make
			from i := 1 until i > 100 loop
				utf8 := enc.utf_32_to_utf_8 ("Test string " + i.out)
				i := i + 1
			end
			assert ("100_conversions_no_error", not enc.has_error)
		end

	test_alternating_valid_invalid
			-- Test alternating valid and invalid inputs
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			valid, invalid: STRING_8
			i: INTEGER
		do
			create enc.make
			valid := "Hello"
			create invalid.make (1)
			invalid.append_character ((0xFF).to_character_8)

			from i := 1 until i > 50 loop
				utf32 := enc.utf_8_to_utf_32 (valid)
				assert ("valid_no_error_" + i.out, not enc.has_error)

				utf32 := enc.utf_8_to_utf_32 (invalid)
				assert ("invalid_has_error_" + i.out, enc.has_error)
				i := i + 1
			end
		end

feature -- Mixed Content Stress Tests

	test_mixed_content_large
			-- Test large string with mixed content types
		local
			enc: SIMPLE_ENCODING
			utf8: STRING_8
			utf32: STRING_32
			input: STRING_32
			i: INTEGER
		do
			create enc.make
			create input.make (4000)

			-- Mix: ASCII, Latin extended, CJK, emoji repeated
			from i := 1 until i > 1000 loop
				input.append_character ('A')           -- 1 byte
				input.append_code (0x00E9)            -- 2 bytes (e-acute)
				input.append_code (0x4E2D)            -- 3 bytes (Chinese)
				input.append_code (0x1F600)           -- 4 bytes (emoji)
				i := i + 1
			end

			utf8 := enc.utf_32_to_utf_8 (input)
			-- 1000 * (1 + 2 + 3 + 4) = 10000 bytes
			assert ("mixed_large_correct_length", utf8.count = 10000)

			utf32 := enc.utf_8_to_utf_32 (utf8)
			assert ("mixed_large_roundtrip", utf32.same_string (input))
			assert ("mixed_large_no_error", not enc.has_error)
		end

feature -- Error Recovery Stress Tests

	test_many_errors_in_sequence
			-- Test sequence with many invalid bytes
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
			i: INTEGER
		do
			create enc.make
			create bad.make (100)
			from i := 1 until i > 100 loop
				bad.append_character ((0xFF).to_character_8)
				i := i + 1
			end

			utf32 := enc.utf_8_to_utf_32 (bad)
			assert ("many_errors_has_error", enc.has_error)
			-- Should have 100 replacement characters
			assert ("many_errors_100_replacements", utf32.count = 100)
		end

	test_interleaved_valid_invalid_bytes
			-- Test bytes alternating between valid ASCII and invalid
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			mixed: STRING_8
			i: INTEGER
		do
			create enc.make
			create mixed.make (200)
			from i := 1 until i > 100 loop
				mixed.append_character ('A')                      -- valid ASCII
				mixed.append_character ((0x80).to_character_8)    -- invalid (continuation as lead)
				i := i + 1
			end

			utf32 := enc.utf_8_to_utf_32 (mixed)
			assert ("interleaved_has_error", enc.has_error)
			-- 100 'A' + 100 replacement chars = 200 chars
			assert ("interleaved_correct_count", utf32.count = 200)
		end

feature -- Determinism Tests

	test_deterministic_output
			-- Same input should always produce same output
		local
			enc: SIMPLE_ENCODING
			utf8_1, utf8_2, utf8_3: STRING_8
		do
			create enc.make
			utf8_1 := enc.utf_32_to_utf_8 ("Test determinism")
			utf8_2 := enc.utf_32_to_utf_8 ("Test determinism")
			utf8_3 := enc.utf_32_to_utf_8 ("Test determinism")

			assert ("deterministic_1_2", utf8_1.same_string (utf8_2))
			assert ("deterministic_2_3", utf8_2.same_string (utf8_3))
		end

	test_different_input_different_output
			-- Different inputs must produce different outputs
		local
			enc: SIMPLE_ENCODING
			utf8_a, utf8_b: STRING_8
		do
			create enc.make
			utf8_a := enc.utf_32_to_utf_8 ("Input A")
			utf8_b := enc.utf_32_to_utf_8 ("Input B")

			assert ("different_inputs_different_outputs", not utf8_a.same_string (utf8_b))
		end

end

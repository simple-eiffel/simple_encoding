note
	description: "Test application for simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run all tests
		do
			print ("Running SIMPLE_ENCODING tests...%N%N")
			passed := 0
			failed := 0

			run_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Setup

	encoding_tests: ENCODING_TESTS
			-- Encoding test suite
		once
			create Result
		end

	adversarial_tests: ADVERSARIAL_TESTS
			-- Adversarial test suite
		once
			create Result
		end

	stress_tests: STRESS_TESTS
			-- Stress test suite
		once
			create Result
		end

	bug_hunt_tests: BUG_HUNT_TESTS
			-- Bug hunt test suite
		once
			create Result
		end

	codec_tests: CODEC_TESTS
			-- Codec test suite
		once
			create Result
		end

	utility_tests: UTILITY_TESTS
			-- Utility test suite
		once
			create Result
		end

feature {NONE} -- Test Execution

	run_tests
			-- Run all test suites
		do
			print ("=== UTF-8/UTF-32 Conversion Tests ===%N")
			run_test (agent encoding_tests.test_ascii_roundtrip, "test_ascii_roundtrip")
			run_test (agent encoding_tests.test_latin_extended, "test_latin_extended")
			run_test (agent encoding_tests.test_cjk_characters, "test_cjk_characters")
			run_test (agent encoding_tests.test_emoji_4byte, "test_emoji_4byte")
			run_test (agent encoding_tests.test_empty_string, "test_empty_string")
			run_test (agent encoding_tests.test_mixed_content, "test_mixed_content")
			run_test (agent encoding_tests.test_utf8_byte_counts, "test_utf8_byte_counts")
			run_test (agent encoding_tests.test_invalid_utf8_sequence, "test_invalid_utf8_sequence")
			run_test (agent encoding_tests.test_truncated_utf8, "test_truncated_utf8")
			run_test (agent encoding_tests.test_error_tracking, "test_error_tracking")

			print ("%N=== ADVERSARIAL TESTS ===%N")
			run_test (agent adversarial_tests.test_max_ascii_boundary, "test_max_ascii_boundary")
			run_test (agent adversarial_tests.test_max_2byte_boundary, "test_max_2byte_boundary")
			run_test (agent adversarial_tests.test_max_3byte_boundary, "test_max_3byte_boundary")
			run_test (agent adversarial_tests.test_max_valid_codepoint, "test_max_valid_codepoint")
			run_test (agent adversarial_tests.test_beyond_max_codepoint, "test_beyond_max_codepoint")
			run_test (agent adversarial_tests.test_overlong_2byte_null, "test_overlong_2byte_null")
			run_test (agent adversarial_tests.test_overlong_3byte_slash, "test_overlong_3byte_slash")
			run_test (agent adversarial_tests.test_surrogate_high, "test_surrogate_high")
			run_test (agent adversarial_tests.test_surrogate_low, "test_surrogate_low")
			run_test (agent adversarial_tests.test_invalid_leading_0x80, "test_invalid_leading_0x80")
			run_test (agent adversarial_tests.test_invalid_leading_0xFF, "test_invalid_leading_0xFF")
			run_test (agent adversarial_tests.test_invalid_leading_0xFE, "test_invalid_leading_0xFE")
			run_test (agent adversarial_tests.test_null_character_encode, "test_null_character_encode")
			run_test (agent adversarial_tests.test_null_character_decode, "test_null_character_decode")
			run_test (agent adversarial_tests.test_reuse_after_error, "test_reuse_after_error")
			run_test (agent adversarial_tests.test_multiple_conversions_same_instance, "test_multiple_conversions_same_instance")
			run_test (agent adversarial_tests.test_bom_encoding, "test_bom_encoding")
			run_test (agent adversarial_tests.test_bom_decoding, "test_bom_decoding")

			print ("%N=== STRESS TESTS ===%N")
			run_test (agent stress_tests.test_long_ascii_string, "test_long_ascii_string")
			run_test (agent stress_tests.test_long_unicode_string, "test_long_unicode_string")
			run_test (agent stress_tests.test_long_4byte_string, "test_long_4byte_string")
			run_test (agent stress_tests.test_repeated_conversions, "test_repeated_conversions")
			run_test (agent stress_tests.test_alternating_valid_invalid, "test_alternating_valid_invalid")
			run_test (agent stress_tests.test_mixed_content_large, "test_mixed_content_large")
			run_test (agent stress_tests.test_many_errors_in_sequence, "test_many_errors_in_sequence")
			run_test (agent stress_tests.test_interleaved_valid_invalid_bytes, "test_interleaved_valid_invalid_bytes")
			run_test (agent stress_tests.test_deterministic_output, "test_deterministic_output")
			run_test (agent stress_tests.test_different_input_different_output, "test_different_input_different_output")

			print ("%N=== BUG HUNT TESTS ===%N")
			run_test (agent bug_hunt_tests.test_f5_leading_byte, "test_f5_leading_byte")
			run_test (agent bug_hunt_tests.test_f4_90_boundary, "test_f4_90_boundary")
			run_test (agent bug_hunt_tests.test_f6_leading_byte, "test_f6_leading_byte")
			run_test (agent bug_hunt_tests.test_f7_leading_byte, "test_f7_leading_byte")

			print ("%N=== CODEC TESTS ===%N")
			run_test (agent codec_tests.test_latin1_ascii_roundtrip, "test_latin1_ascii_roundtrip")
			run_test (agent codec_tests.test_latin1_high_chars, "test_latin1_high_chars")
			run_test (agent codec_tests.test_latin1_full_range, "test_latin1_full_range")
			run_test (agent codec_tests.test_latin1_unencodable, "test_latin1_unencodable")
			run_test (agent codec_tests.test_latin1_can_encode, "test_latin1_can_encode")
			run_test (agent codec_tests.test_latin9_euro_sign, "test_latin9_euro_sign")
			run_test (agent codec_tests.test_latin9_special_chars, "test_latin9_special_chars")
			run_test (agent codec_tests.test_latin9_replaced_positions, "test_latin9_replaced_positions")
			run_test (agent codec_tests.test_win1252_smart_quotes, "test_win1252_smart_quotes")
			run_test (agent codec_tests.test_win1252_extended_chars, "test_win1252_extended_chars")
			run_test (agent codec_tests.test_win1252_undefined_bytes, "test_win1252_undefined_bytes")
			run_test (agent codec_tests.test_win1252_ascii_pass_through, "test_win1252_ascii_pass_through")
			run_test (agent codec_tests.test_codec_names, "test_codec_names")
			run_test (agent codec_tests.test_codec_single_byte, "test_codec_single_byte")

			print ("%N=== UTILITY TESTS ===%N")
			run_test (agent utility_tests.test_is_letter_ascii, "test_is_letter_ascii")
			run_test (agent utility_tests.test_is_letter_extended, "test_is_letter_extended")
			run_test (agent utility_tests.test_is_digit, "test_is_digit")
			run_test (agent utility_tests.test_is_hex_digit, "test_is_hex_digit")
			run_test (agent utility_tests.test_is_alphanumeric, "test_is_alphanumeric")
			run_test (agent utility_tests.test_is_whitespace, "test_is_whitespace")
			run_test (agent utility_tests.test_is_control, "test_is_control")
			run_test (agent utility_tests.test_is_punctuation, "test_is_punctuation")
			run_test (agent utility_tests.test_is_ascii, "test_is_ascii")
			run_test (agent utility_tests.test_is_printable_ascii, "test_is_printable_ascii")
			run_test (agent utility_tests.test_case_functions, "test_case_functions")
			run_test (agent utility_tests.test_general_category, "test_general_category")
			run_test (agent utility_tests.test_detect_utf8_bom, "test_detect_utf8_bom")
			run_test (agent utility_tests.test_detect_utf16_le_bom, "test_detect_utf16_le_bom")
			run_test (agent utility_tests.test_detect_utf16_be_bom, "test_detect_utf16_be_bom")
			run_test (agent utility_tests.test_detect_valid_utf8, "test_detect_valid_utf8")
			run_test (agent utility_tests.test_detect_ascii, "test_detect_ascii")
			run_test (agent utility_tests.test_detect_invalid_utf8, "test_detect_invalid_utf8")
			run_test (agent utility_tests.test_strip_bom, "test_strip_bom")
			run_test (agent utility_tests.test_has_multibyte_utf8, "test_has_multibyte_utf8")
			run_test (agent utility_tests.test_high_byte_percentage, "test_high_byte_percentage")
			run_test (agent utility_tests.test_registry_has_builtins, "test_registry_has_builtins")
			run_test (agent utility_tests.test_registry_aliases, "test_registry_aliases")
			run_test (agent utility_tests.test_registry_codec_by_name, "test_registry_codec_by_name")
			run_test (agent utility_tests.test_registry_unknown_codec, "test_registry_unknown_codec")
			run_test (agent utility_tests.test_registry_all_codec_names, "test_registry_all_codec_names")
			run_test (agent utility_tests.test_registry_counts, "test_registry_counts")
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end

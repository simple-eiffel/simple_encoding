note
	description: "Bug hunting tests - probing for implementation defects"
	date: "2026-01-18"

class
	BUG_HUNT_TESTS

inherit
	TEST_SET_BASE

feature -- Bug Tests

	test_f5_leading_byte
			-- F5 90 80 80 should be rejected (produces code point > U+10FFFF)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (4)
			bad.append_character ((0xF5).to_character_8)
			bad.append_character ((0x90).to_character_8)
			bad.append_character ((0x80).to_character_8)
			bad.append_character ((0x80).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			-- F5 would produce code point 0x150000 > 0x10FFFF
			-- Current behavior: accepts it without error
			-- Expected: should reject with error
			if enc.has_error then
				assert ("f5_correctly_rejected", True)
			else
				-- BUG: F5 leading byte accepted
				print ("  BUG: F5 90 80 80 accepted, produced: " + utf32.code (1).out + "%N")
				assert ("f5_should_be_rejected_BUG", False)
			end
		end

	test_f4_90_boundary
			-- F4 90 80 80 should be rejected (produces U+110000)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (4)
			bad.append_character ((0xF4).to_character_8)
			bad.append_character ((0x90).to_character_8)
			bad.append_character ((0x80).to_character_8)
			bad.append_character ((0x80).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			-- F4 90 80 80 produces 0x110000 > 0x10FFFF
			if enc.has_error then
				assert ("f4_90_correctly_rejected", True)
			else
				-- BUG: Invalid code point accepted
				print ("  BUG: F4 90 80 80 accepted, produced: " + utf32.code (1).out + "%N")
				assert ("f4_90_should_be_rejected_BUG", False)
			end
		end

	test_f6_leading_byte
			-- F6 should be rejected (would produce > U+10FFFF)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (4)
			bad.append_character ((0xF6).to_character_8)
			bad.append_character ((0x80).to_character_8)
			bad.append_character ((0x80).to_character_8)
			bad.append_character ((0x80).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			if enc.has_error then
				assert ("f6_correctly_rejected", True)
			else
				print ("  BUG: F6 80 80 80 accepted, produced: " + utf32.code (1).out + "%N")
				assert ("f6_should_be_rejected_BUG", False)
			end
		end

	test_f7_leading_byte
			-- F7 should be rejected (would produce > U+10FFFF)
		local
			enc: SIMPLE_ENCODING
			utf32: STRING_32
			bad: STRING_8
		do
			create enc.make
			create bad.make (4)
			bad.append_character ((0xF7).to_character_8)
			bad.append_character ((0x80).to_character_8)
			bad.append_character ((0x80).to_character_8)
			bad.append_character ((0x80).to_character_8)
			utf32 := enc.utf_8_to_utf_32 (bad)
			if enc.has_error then
				assert ("f7_correctly_rejected", True)
			else
				print ("  BUG: F7 80 80 80 accepted, produced: " + utf32.code (1).out + "%N")
				assert ("f7_should_be_rejected_BUG", False)
			end
		end

end

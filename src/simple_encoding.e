note
	description: "[
		Simple UTF encoding/decoding library.

		Provides conversion between STRING_32 (UTF-32/Unicode) and STRING_8 (UTF-8).
		This is a pure Eiffel implementation without external dependencies.

		Primary features:
		- utf_32_to_utf_8: Convert STRING_32 to UTF-8 encoded STRING_8
		- utf_8_to_utf_32: Convert UTF-8 encoded STRING_8 to STRING_32

		UTF-8 encoding rules:
		- U+0000..U+007F: 1 byte (0xxxxxxx)
		- U+0080..U+07FF: 2 bytes (110xxxxx 10xxxxxx)
		- U+0800..U+FFFF: 3 bytes (1110xxxx 10xxxxxx 10xxxxxx)
		- U+10000..U+10FFFF: 4 bytes (11110xxx 10xxxxxx 10xxxxxx 10xxxxxx)
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_ENCODING

create
	make

feature {NONE} -- Initialization

	make
			-- Create encoding converter
		do
			create last_error.make_empty
		ensure
			error_empty: last_error.is_empty
		end

feature -- Conversion: UTF-32 to UTF-8

	utf_32_to_utf_8 (a_utf32: READABLE_STRING_32): STRING_8
			-- Convert UTF-32 (STRING_32) to UTF-8 encoded STRING_8
		require
			string_not_void: a_utf32 /= Void
		local
			i: INTEGER
			code: NATURAL_32
		do
			create Result.make (a_utf32.count * 4)
			last_error.wipe_out

			from i := 1 until i > a_utf32.count loop
				code := a_utf32.code (i)

				if code <= 0x7F then
					-- 1-byte ASCII
					Result.append_character (code.to_character_8)
				elseif code <= 0x7FF then
					-- 2-byte sequence
					Result.append_character (((code |>> 6) | 0xC0).to_character_8)
					Result.append_character (((code & 0x3F) | 0x80).to_character_8)
				elseif code <= 0xFFFF then
					-- 3-byte sequence
					Result.append_character (((code |>> 12) | 0xE0).to_character_8)
					Result.append_character ((((code |>> 6) & 0x3F) | 0x80).to_character_8)
					Result.append_character (((code & 0x3F) | 0x80).to_character_8)
				elseif code <= 0x10FFFF then
					-- 4-byte sequence
					Result.append_character (((code |>> 18) | 0xF0).to_character_8)
					Result.append_character ((((code |>> 12) & 0x3F) | 0x80).to_character_8)
					Result.append_character ((((code |>> 6) & 0x3F) | 0x80).to_character_8)
					Result.append_character (((code & 0x3F) | 0x80).to_character_8)
				else
					-- Invalid code point - use replacement character
					last_error.append ("Invalid code point at position " + i.out + "%N")
					-- U+FFFD replacement character (3 bytes)
					Result.append_character ((0xEF).to_character_8)
					Result.append_character ((0xBF).to_character_8)
					Result.append_character ((0xBD).to_character_8)
				end

				i := i + 1
			end
		ensure
			result_not_void: Result /= Void
			empty_preserved: a_utf32.is_empty implies Result.is_empty
		end

feature -- Conversion: UTF-8 to UTF-32

	utf_8_to_utf_32 (a_utf8: READABLE_STRING_8): STRING_32
			-- Convert UTF-8 encoded STRING_8 to UTF-32 (STRING_32)
		require
			string_not_void: a_utf8 /= Void
		local
			i: INTEGER
			byte1, byte2, byte3, byte4: NATURAL_32
			code: NATURAL_32
		do
			create Result.make (a_utf8.count)
			last_error.wipe_out

			from i := 1 until i > a_utf8.count loop
				byte1 := a_utf8.code (i)

				if byte1 <= 0x7F then
					-- 1-byte ASCII
					Result.append_code (byte1)
					i := i + 1
				elseif (byte1 & 0xE0) = 0xC0 then
					-- 2-byte sequence
					if i + 1 <= a_utf8.count then
						byte2 := a_utf8.code (i + 1)
						if (byte2 & 0xC0) = 0x80 then
							code := ((byte1 & 0x1F) |<< 6) | (byte2 & 0x3F)
							Result.append_code (code)
							i := i + 2
						else
							append_replacement_and_error (Result, i)
							i := i + 1
						end
					else
						append_replacement_and_error (Result, i)
						i := i + 1
					end
				elseif (byte1 & 0xF0) = 0xE0 then
					-- 3-byte sequence
					if i + 2 <= a_utf8.count then
						byte2 := a_utf8.code (i + 1)
						byte3 := a_utf8.code (i + 2)
						if ((byte2 & 0xC0) = 0x80) and ((byte3 & 0xC0) = 0x80) then
							code := ((byte1 & 0x0F) |<< 12) | ((byte2 & 0x3F) |<< 6) | (byte3 & 0x3F)
							Result.append_code (code)
							i := i + 3
						else
							append_replacement_and_error (Result, i)
							i := i + 1
						end
					else
						append_replacement_and_error (Result, i)
						i := i + 1
					end
				elseif (byte1 & 0xF8) = 0xF0 and byte1 <= 0xF4 then
					-- 4-byte sequence (F0-F4 only; F5-F7 would exceed U+10FFFF)
					if i + 3 <= a_utf8.count then
						byte2 := a_utf8.code (i + 1)
						byte3 := a_utf8.code (i + 2)
						byte4 := a_utf8.code (i + 3)
						if ((byte2 & 0xC0) = 0x80) and ((byte3 & 0xC0) = 0x80) and ((byte4 & 0xC0) = 0x80) then
							code := ((byte1 & 0x07) |<< 18) | ((byte2 & 0x3F) |<< 12) | ((byte3 & 0x3F) |<< 6) | (byte4 & 0x3F)
							if code > 0x10FFFF then
								-- Code point exceeds max valid Unicode (e.g., F4 90+)
								append_replacement_and_error (Result, i)
								i := i + 4
							else
								Result.append_code (code)
								i := i + 4
							end
						else
							append_replacement_and_error (Result, i)
							i := i + 1
						end
					else
						append_replacement_and_error (Result, i)
						i := i + 1
					end
				else
					-- Invalid leading byte
					append_replacement_and_error (Result, i)
					i := i + 1
				end
			end
		ensure
			result_not_void: Result /= Void
			empty_preserved: a_utf8.is_empty implies Result.is_empty
		end

feature -- Status

	has_error: BOOLEAN
			-- Did last conversion encounter errors?
		do
			Result := not last_error.is_empty
		ensure
			definition: Result = not last_error.is_empty
		end

	last_error: STRING_32
			-- Error message from last conversion (empty if no error)

feature {NONE} -- Implementation

	append_replacement_and_error (a_result: STRING_32; a_position: INTEGER)
			-- Append replacement character and record error
		require
			result_not_void: a_result /= Void
			position_valid: a_position >= 1
		do
			a_result.append_code (0xFFFD) -- Replacement character
			last_error.append ("Invalid UTF-8 sequence at position " + a_position.out + "%N")
		ensure
			result_extended: a_result.count = old a_result.count + 1
			error_recorded: not last_error.is_empty
		end

invariant
	last_error_not_void: last_error /= Void

end

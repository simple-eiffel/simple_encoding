note
	description: "[
		Encoding detector using heuristics and BOM detection.
		
		Detection strategy:
		1. Check for Byte Order Marks (BOM) first
		2. Validate as UTF-8 (strict validation)
		3. Check if pure ASCII
		4. Fall back to ISO-8859-1 (accepts any byte sequence)
		
		Supported BOMs:
		- UTF-8: EF BB BF
		- UTF-16 LE: FF FE
		- UTF-16 BE: FE FF
		- UTF-32 LE: FF FE 00 00
		- UTF-32 BE: 00 00 FE FF
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_ENCODING_DETECTOR

create
	make

feature {NONE} -- Initialization

	make
			-- Create encoding detector
		do
		end

feature -- Detection

	detect_encoding (a_bytes: READABLE_STRING_8): detachable STRING_32
			-- Detected encoding name, or Void if unknown
			-- Returns standardized encoding name
		do
			if has_utf8_bom (a_bytes) then
				Result := "UTF-8"
			elseif has_utf32_le_bom (a_bytes) then
				Result := "UTF-32LE"
			elseif has_utf32_be_bom (a_bytes) then
				Result := "UTF-32BE"
			elseif has_utf16_le_bom (a_bytes) then
				Result := "UTF-16LE"
			elseif has_utf16_be_bom (a_bytes) then
				Result := "UTF-16BE"
			elseif is_valid_utf8 (a_bytes) then
				Result := "UTF-8"
			elseif looks_like_ascii (a_bytes) then
				Result := "ASCII"
			else
				Result := "ISO-8859-1"  -- Default fallback
			end
		ensure
			result_not_empty: Result /= Void implies not Result.is_empty
		end

	detect_encoding_with_confidence (a_bytes: READABLE_STRING_8): TUPLE [encoding: STRING_32; confidence: REAL_64]
			-- Detect encoding with confidence level (0.0 to 1.0)
		local
			l_encoding: STRING_32
			l_confidence: REAL_64
		do
			if has_utf8_bom (a_bytes) then
				l_encoding := "UTF-8"
				l_confidence := 1.0
			elseif has_utf32_le_bom (a_bytes) or has_utf32_be_bom (a_bytes) then
				l_encoding := "UTF-32"
				l_confidence := 1.0
			elseif has_utf16_le_bom (a_bytes) or has_utf16_be_bom (a_bytes) then
				l_encoding := "UTF-16"
				l_confidence := 1.0
			elseif is_valid_utf8 (a_bytes) then
				l_encoding := "UTF-8"
				if has_multibyte_utf8 (a_bytes) then
					l_confidence := 0.95  -- Multi-byte UTF-8 is strong evidence
				else
					l_confidence := 0.7   -- Pure ASCII could be many encodings
				end
			elseif looks_like_ascii (a_bytes) then
				l_encoding := "ASCII"
				l_confidence := 0.8
			else
				l_encoding := "ISO-8859-1"
				l_confidence := 0.5  -- Low confidence - just a fallback
			end
			Result := [l_encoding, l_confidence]
		ensure
			result_not_void: Result /= Void
			confidence_valid: Result.confidence >= 0.0 and Result.confidence <= 1.0
		end

feature -- BOM Detection

	has_utf8_bom (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` start with UTF-8 BOM (EF BB BF)?
		do
			Result := a_bytes.count >= 3
				and then a_bytes [1].code = 0xEF
				and then a_bytes [2].code = 0xBB
				and then a_bytes [3].code = 0xBF
		end

	has_utf16_le_bom (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` start with UTF-16 LE BOM (FF FE)?
		do
			Result := a_bytes.count >= 2
				and then a_bytes [1].code = 0xFF
				and then a_bytes [2].code = 0xFE
				and then not has_utf32_le_bom (a_bytes)  -- Distinguish from UTF-32
		end

	has_utf16_be_bom (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` start with UTF-16 BE BOM (FE FF)?
		do
			Result := a_bytes.count >= 2
				and then a_bytes [1].code = 0xFE
				and then a_bytes [2].code = 0xFF
		end

	has_utf32_le_bom (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` start with UTF-32 LE BOM (FF FE 00 00)?
		do
			Result := a_bytes.count >= 4
				and then a_bytes [1].code = 0xFF
				and then a_bytes [2].code = 0xFE
				and then a_bytes [3].code = 0x00
				and then a_bytes [4].code = 0x00
		end

	has_utf32_be_bom (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` start with UTF-32 BE BOM (00 00 FE FF)?
		do
			Result := a_bytes.count >= 4
				and then a_bytes [1].code = 0x00
				and then a_bytes [2].code = 0x00
				and then a_bytes [3].code = 0xFE
				and then a_bytes [4].code = 0xFF
		end

	strip_bom (a_bytes: READABLE_STRING_8): STRING_8
			-- Return `a_bytes` with BOM removed (if present)
		do
			if has_utf8_bom (a_bytes) then
				create Result.make_from_string (a_bytes.substring (4, a_bytes.count).to_string_8)
			elseif has_utf32_le_bom (a_bytes) or has_utf32_be_bom (a_bytes) then
				create Result.make_from_string (a_bytes.substring (5, a_bytes.count).to_string_8)
			elseif has_utf16_le_bom (a_bytes) or has_utf16_be_bom (a_bytes) then
				create Result.make_from_string (a_bytes.substring (3, a_bytes.count).to_string_8)
			else
				create Result.make_from_string (a_bytes.to_string_8)
			end
		ensure
			result_not_void: Result /= Void
		end

feature -- UTF-8 Validation

	is_valid_utf8 (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Is `a_bytes` valid UTF-8?
		local
			l_pos, l_expected: INTEGER
			l_byte: INTEGER
		do
			Result := True
			from l_pos := 1 until l_pos > a_bytes.count or not Result loop
				l_byte := a_bytes [l_pos].code
				if l_byte < 0x80 then
					l_expected := 0
				elseif l_byte < 0xC0 then
					Result := False  -- Unexpected continuation byte
				elseif l_byte < 0xE0 then
					l_expected := 1
				elseif l_byte < 0xF0 then
					l_expected := 2
				elseif l_byte < 0xF8 then
					l_expected := 3
				else
					Result := False  -- Invalid start byte
				end

				if Result and l_expected > 0 then
					-- Check continuation bytes
					from until l_expected = 0 or not Result loop
						l_pos := l_pos + 1
						if l_pos > a_bytes.count then
							Result := False
						else
							l_byte := a_bytes [l_pos].code
							Result := l_byte >= 0x80 and l_byte < 0xC0
						end
						l_expected := l_expected - 1
					end
				end
				l_pos := l_pos + 1
			end
		end

feature -- Heuristics

	looks_like_ascii (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` appear to be pure ASCII?
		local
			i: INTEGER
		do
			Result := True
			from i := 1 until i > a_bytes.count or not Result loop
				Result := a_bytes [i].code < 128
				i := i + 1
			end
		end

	has_multibyte_utf8 (a_bytes: READABLE_STRING_8): BOOLEAN
			-- Does `a_bytes` contain multi-byte UTF-8 sequences?
		local
			i: INTEGER
		do
			from i := 1 until i > a_bytes.count or Result loop
				Result := a_bytes [i].code >= 0x80
				i := i + 1
			end
		end

	high_byte_percentage (a_bytes: READABLE_STRING_8): REAL_64
			-- Percentage of bytes >= 128
		local
			l_high_count, i: INTEGER
		do
			from i := 1 until i > a_bytes.count loop
				if a_bytes [i].code >= 128 then
					l_high_count := l_high_count + 1
				end
				i := i + 1
			end
			if a_bytes.count > 0 then
				Result := l_high_count / a_bytes.count
			end
		ensure
			valid_range: Result >= 0.0 and Result <= 1.0
		end

end

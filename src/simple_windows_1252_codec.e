note
	description: "[
		Windows-1252 (CP1252) codec.
		
		Windows Western European encoding. Superset of Latin-1 with
		printable characters in the 0x80-0x9F range (which are
		control characters in Latin-1).
		
		Notable additions in 0x80-0x9F:
		- 0x80: Euro sign
		- 0x91-0x94: Smart quotes
		- 0x95: Bullet
		- 0x96-0x97: En/em dash
		- 0x99: Trademark
		
		Undefined positions: 0x81, 0x8D, 0x8F, 0x90, 0x9D
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_WINDOWS_1252_CODEC

inherit
	SIMPLE_CODEC
		redefine
			is_single_byte
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create Windows-1252 codec
		do
			create last_error.make_empty
		end

feature -- Properties

	name: STRING_32
			-- Codec name
		once
			Result := "Windows-1252"
		end

	is_single_byte: BOOLEAN = True
			-- This is a single-byte encoding

feature -- Encoding

	encode_character (a_char: CHARACTER_32): NATURAL_8
			-- Encode Unicode to Windows-1252
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			if l_code < 0x80 or (l_code >= 0xA0 and l_code <= 0xFF) then
				Result := l_code.to_natural_8
			else
				-- Check extended range 0x80-0x9F
				Result := unicode_to_win1252 (l_code)
			end
		ensure then
			round_trip: decode_byte (Result) = a_char
		end

	can_encode (a_char: CHARACTER_32): BOOLEAN
			-- Can character be encoded?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			if l_code < 0x80 or (l_code >= 0xA0 and l_code <= 0xFF) then
				Result := True
			else
				Result := unicode_to_win1252 (l_code) /= 0
			end
		end

	encode_string (a_string: READABLE_STRING_GENERAL): STRING_8
			-- Encode string to Windows-1252 bytes
		local
			i: INTEGER
			l_code: NATURAL_32
		do
			clear_error
			create Result.make (a_string.count)
			from i := 1 until i > a_string.count loop
				l_code := a_string.code (i)
				if can_encode (l_code.to_character_32) then
					Result.append_character (encode_character (l_code.to_character_32).to_character_8)
				else
					Result.append_character ('?')
					set_error ("Cannot encode U+" + l_code.to_hex_string + " at position " + i.out)
				end
				i := i + 1
			end
		ensure then
			same_length: Result.count = a_string.count
		end

feature -- Decoding

	decode_byte (a_byte: NATURAL_8): CHARACTER_32
			-- Decode Windows-1252 byte to Unicode
		do
			if a_byte < 0x80 or a_byte >= 0xA0 then
				Result := a_byte.to_natural_32.to_character_32
			else
				Result := Extended_decode_table [a_byte.to_integer_32 - 0x80 + 1]
			end
		end

	decode_string (a_bytes: READABLE_STRING_8): STRING_32
			-- Decode Windows-1252 bytes to Unicode string
		local
			i: INTEGER
		do
			clear_error
			create Result.make (a_bytes.count)
			from i := 1 until i > a_bytes.count loop
				Result.append_character (decode_byte (a_bytes.code (i).to_natural_8))
				i := i + 1
			end
		ensure then
			same_length: Result.count = a_bytes.count
		end

feature {NONE} -- Implementation

	Extended_decode_table: ARRAY [CHARACTER_32]
			-- Decode table for bytes 0x80-0x9F (32 entries)
		once
			Result := <<
				(0x20AC).to_character_32,  -- 0x80 Euro
				(0xFFFD).to_character_32,  -- 0x81 undefined
				(0x201A).to_character_32,  -- 0x82 single low quote
				(0x0192).to_character_32,  -- 0x83 f with hook
				(0x201E).to_character_32,  -- 0x84 double low quote
				(0x2026).to_character_32,  -- 0x85 ellipsis
				(0x2020).to_character_32,  -- 0x86 dagger
				(0x2021).to_character_32,  -- 0x87 double dagger
				(0x02C6).to_character_32,  -- 0x88 circumflex
				(0x2030).to_character_32,  -- 0x89 per mille
				(0x0160).to_character_32,  -- 0x8A S caron
				(0x2039).to_character_32,  -- 0x8B left single guillemet
				(0x0152).to_character_32,  -- 0x8C OE ligature
				(0xFFFD).to_character_32,  -- 0x8D undefined
				(0x017D).to_character_32,  -- 0x8E Z caron
				(0xFFFD).to_character_32,  -- 0x8F undefined
				(0xFFFD).to_character_32,  -- 0x90 undefined
				(0x2018).to_character_32,  -- 0x91 left single quote
				(0x2019).to_character_32,  -- 0x92 right single quote
				(0x201C).to_character_32,  -- 0x93 left double quote
				(0x201D).to_character_32,  -- 0x94 right double quote
				(0x2022).to_character_32,  -- 0x95 bullet
				(0x2013).to_character_32,  -- 0x96 en dash
				(0x2014).to_character_32,  -- 0x97 em dash
				(0x02DC).to_character_32,  -- 0x98 tilde
				(0x2122).to_character_32,  -- 0x99 trademark
				(0x0161).to_character_32,  -- 0x9A s caron
				(0x203A).to_character_32,  -- 0x9B right single guillemet
				(0x0153).to_character_32,  -- 0x9C oe ligature
				(0xFFFD).to_character_32,  -- 0x9D undefined
				(0x017E).to_character_32,  -- 0x9E z caron
				(0x0178).to_character_32   -- 0x9F Y diaeresis
			>>
		ensure
			correct_size: Result.count = 32
		end

	unicode_to_win1252 (a_code: NATURAL_32): NATURAL_8
			-- Convert Unicode to Windows-1252 byte in extended range
			-- Returns 0 if not encodable
		do
			inspect a_code.to_integer_32
			when 0x20AC then Result := 0x80  -- Euro
			when 0x201A then Result := 0x82  -- single low quote
			when 0x0192 then Result := 0x83  -- f with hook
			when 0x201E then Result := 0x84  -- double low quote
			when 0x2026 then Result := 0x85  -- ellipsis
			when 0x2020 then Result := 0x86  -- dagger
			when 0x2021 then Result := 0x87  -- double dagger
			when 0x02C6 then Result := 0x88  -- circumflex
			when 0x2030 then Result := 0x89  -- per mille
			when 0x0160 then Result := 0x8A  -- S caron
			when 0x2039 then Result := 0x8B  -- left guillemet
			when 0x0152 then Result := 0x8C  -- OE
			when 0x017D then Result := 0x8E  -- Z caron
			when 0x2018 then Result := 0x91  -- left quote
			when 0x2019 then Result := 0x92  -- right quote
			when 0x201C then Result := 0x93  -- left double quote
			when 0x201D then Result := 0x94  -- right double quote
			when 0x2022 then Result := 0x95  -- bullet
			when 0x2013 then Result := 0x96  -- en dash
			when 0x2014 then Result := 0x97  -- em dash
			when 0x02DC then Result := 0x98  -- tilde
			when 0x2122 then Result := 0x99  -- trademark
			when 0x0161 then Result := 0x9A  -- s caron
			when 0x203A then Result := 0x9B  -- right guillemet
			when 0x0153 then Result := 0x9C  -- oe
			when 0x017E then Result := 0x9E  -- z caron
			when 0x0178 then Result := 0x9F  -- Y diaeresis
			else
				Result := 0  -- Not encodable
			end
		end

end

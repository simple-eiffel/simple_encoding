note
	description: "[
		ISO-8859-15 (Latin-9) codec.
		
		Latin-9 is a revision of Latin-1 that adds the Euro sign
		and French/Finnish characters. It differs from Latin-1
		in 8 positions:
		
		Byte  Latin-1      Latin-9
		0xA4  Currency     Euro (U+20AC)
		0xA6  Broken bar   S caron (U+0160)
		0xA8  Diaeresis    s caron (U+0161)
		0xB4  Acute        Z caron (U+017D)
		0xB8  Cedilla      z caron (U+017E)
		0xBC  1/4          OE ligature (U+0152)
		0xBD  1/2          oe ligature (U+0153)
		0xBE  3/4          Y diaeresis (U+0178)
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_ISO_8859_15_CODEC

inherit
	SIMPLE_CODEC
		redefine
			is_single_byte
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create Latin-9 codec
		do
			create last_error.make_empty
		end

feature -- Properties

	name: STRING_32
			-- Codec name
		once
			Result := "ISO-8859-15"
		end

	is_single_byte: BOOLEAN = True
			-- This is a single-byte encoding

feature -- Encoding

	encode_character (a_char: CHARACTER_32): NATURAL_8
			-- Encode Unicode character to Latin-9 byte
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			inspect l_code.to_integer_32
			when 0x20AC then Result := 0xA4  -- Euro sign
			when 0x0160 then Result := 0xA6  -- S with caron
			when 0x0161 then Result := 0xA8  -- s with caron
			when 0x017D then Result := 0xB4  -- Z with caron
			when 0x017E then Result := 0xB8  -- z with caron
			when 0x0152 then Result := 0xBC  -- OE ligature
			when 0x0153 then Result := 0xBD  -- oe ligature
			when 0x0178 then Result := 0xBE  -- Y with diaeresis
			else
				Result := l_code.to_natural_8
			end
		ensure then
			round_trip: decode_byte (Result) = a_char
		end

	can_encode (a_char: CHARACTER_32): BOOLEAN
			-- Can `a_char` be encoded in Latin-9?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			if l_code <= 255 then
				-- Exclude the 8 replaced Latin-1 positions
				inspect l_code.to_integer_32
				when 0xA4, 0xA6, 0xA8, 0xB4, 0xB8, 0xBC, 0xBD, 0xBE then
					Result := False
				else
					Result := True
				end
			else
				-- Check special Latin-9 characters
				inspect l_code.to_integer_32
				when 0x20AC, 0x0160, 0x0161, 0x017D, 0x017E, 0x0152, 0x0153, 0x0178 then
					Result := True
				else
					Result := False
				end
			end
		end

	encode_string (a_string: READABLE_STRING_GENERAL): STRING_8
			-- Encode string to Latin-9 bytes
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
			-- Decode Latin-9 byte to Unicode
		do
			inspect a_byte.to_integer_32
			when 0xA4 then Result := (0x20AC).to_character_32  -- Euro
			when 0xA6 then Result := (0x0160).to_character_32  -- S caron
			when 0xA8 then Result := (0x0161).to_character_32  -- s caron
			when 0xB4 then Result := (0x017D).to_character_32  -- Z caron
			when 0xB8 then Result := (0x017E).to_character_32  -- z caron
			when 0xBC then Result := (0x0152).to_character_32  -- OE
			when 0xBD then Result := (0x0153).to_character_32  -- oe
			when 0xBE then Result := (0x0178).to_character_32  -- Y diaeresis
			else
				Result := a_byte.to_natural_32.to_character_32
			end
		end

	decode_string (a_bytes: READABLE_STRING_8): STRING_32
			-- Decode Latin-9 bytes to Unicode string
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

end

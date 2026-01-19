note
	description: "[
		ISO-8859-1 (Latin-1) codec.
		
		Latin-1 is identical to the first 256 Unicode code points,
		making encoding/decoding trivial. This is the simplest
		single-byte codec.
		
		Supported range: U+0000 to U+00FF (256 characters)
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_ISO_8859_1_CODEC

inherit
	SIMPLE_CODEC
		redefine
			is_single_byte
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create Latin-1 codec
		do
			create last_error.make_empty
		end

feature -- Properties

	name: STRING_32
			-- Codec name
		once
			Result := "ISO-8859-1"
		end

	is_single_byte: BOOLEAN = True
			-- This is a single-byte encoding

feature -- Encoding

	encode_character (a_char: CHARACTER_32): NATURAL_8
			-- Encode Unicode character to Latin-1 byte
		do
			Result := a_char.natural_32_code.to_natural_8
		ensure then
			round_trip: decode_byte (Result) = a_char
		end

	can_encode (a_char: CHARACTER_32): BOOLEAN
			-- Can `a_char` be encoded in Latin-1?
		do
			Result := a_char.natural_32_code <= 255
		end

	encode_string (a_string: READABLE_STRING_GENERAL): STRING_8
			-- Encode string to Latin-1 bytes
		local
			i: INTEGER
			l_code: NATURAL_32
		do
			clear_error
			create Result.make (a_string.count)
			from i := 1 until i > a_string.count loop
				l_code := a_string.code (i)
				if l_code <= 255 then
					Result.append_character (l_code.to_character_8)
				else
					-- Cannot encode - use replacement and record error
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
			-- Decode Latin-1 byte to Unicode character
		do
			Result := a_byte.to_natural_32.to_character_32
		ensure then
			valid_result: Result.natural_32_code = a_byte.to_natural_32
		end

	decode_string (a_bytes: READABLE_STRING_8): STRING_32
			-- Decode Latin-1 bytes to Unicode string
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

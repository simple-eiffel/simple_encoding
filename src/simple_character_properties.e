note
	description: "[
		Unicode character property queries.
		
		Provides classification of characters by type:
		- Letters (alphabetic)
		- Digits (numeric)
		- Whitespace
		- Control characters
		- Punctuation
		- Symbols
		
		Also provides case conversion and ASCII checks.
		
		The classification queries cover the common ranges; general_category
		answers from the full Unicode tables (SIMPLE_UNICODE), which also give
		combining classes, simple case mapping and normalization forms.
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CHARACTER_PROPERTIES

create
	make

feature {NONE} -- Initialization

	make
			-- Create character properties helper
		do
		end

feature -- Classification

	is_letter (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a letter (Unicode category L)?
		do
			Result := unicode.is_letter (a_char)
		end

	is_digit (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a decimal digit (0-9)?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := l_code >= 0x30 and l_code <= 0x39
		end

	is_hex_digit (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a hexadecimal digit (0-9, A-F, a-f)?
		do
			Result := is_digit (a_char)
				or (a_char >= 'A' and a_char <= 'F')
				or (a_char >= 'a' and a_char <= 'f')
		end

	is_alphanumeric (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a letter or digit?
		do
			Result := is_letter (a_char) or is_digit (a_char)
		end

	is_whitespace (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` whitespace (Unicode's White_Space: a separator, Z*, or tab, line feed,
			-- vertical tab, form feed, carriage return or next line)?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := (l_code >= 0x09 and l_code <= 0x0D) or l_code = 0x85 or unicode.is_in_category (a_char, 'Z')
		end

	is_control (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a control character (category Cc: C0, DEL and C1)?
		do
			Result := unicode.general_category (a_char).same_string ("Cc")
		end

	is_punctuation (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` punctuation (Unicode category P)?
		do
			Result := unicode.is_in_category (a_char, 'P')
		end

	is_symbol (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a symbol: math, currency, modifier or other (Unicode category S)?
		do
			Result := unicode.is_in_category (a_char, 'S')
		end

feature -- Case

	is_upper (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` an uppercase letter (category Lu)?
		do
			Result := unicode.general_category (a_char).same_string ("Lu")
		end

	is_lower (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a lowercase letter (category Ll)?
		do
			Result := unicode.general_category (a_char).same_string ("Ll")
		end

	to_upper (a_char: CHARACTER_32): CHARACTER_32
			-- The simple uppercase of `a_char` (itself when it has none).
		do
			Result := unicode.simple_upper (a_char)
		end

	to_lower (a_char: CHARACTER_32): CHARACTER_32
			-- The simple lowercase of `a_char` (itself when it has none).
		do
			Result := unicode.simple_lower (a_char)
		end

feature -- Unicode Categories

	general_category (a_char: CHARACTER_32): STRING_8
			-- The Unicode general category of `a_char' ("Lu", "Mn", "Cf", "Cn" for unassigned, ...),
			-- from the full Unicode Character Database tables of SIMPLE_UNICODE (2026-10-27: was a
			-- simplified guess that called every mark and format character "Cn").
		do
			Result := unicode.general_category (a_char)
		ensure
			two_chars: Result.count = 2
		end

feature -- ASCII

	is_ascii (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` in ASCII range (0-127)?
		do
			Result := a_char.natural_32_code <= 127
		end

	is_printable_ascii (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` printable ASCII (32-126)?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := l_code >= 32 and l_code <= 126
		end

feature {NONE} -- Implementation

	unicode: SIMPLE_UNICODE
			-- The full Unicode tables, one set per processor.
		once
			create Result.make
		end

end

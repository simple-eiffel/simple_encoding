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
		
		Note: This is a simplified implementation covering the most
		common character ranges. Full Unicode property support would
		require much larger lookup tables.
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
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := (l_code >= 0x41 and l_code <= 0x5A)      -- A-Z
				or (l_code >= 0x61 and l_code <= 0x7A)         -- a-z
				or (l_code >= 0xC0 and l_code <= 0xD6)         -- Latin Extended
				or (l_code >= 0xD8 and l_code <= 0xF6)
				or (l_code >= 0xF8 and l_code <= 0xFF)
				or (l_code >= 0x100 and l_code <= 0x17F)       -- Latin Extended-A
				or (l_code >= 0x180 and l_code <= 0x24F)       -- Latin Extended-B
				or is_in_letter_ranges (l_code)
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
			-- Is `a_char` whitespace (space, tab, newline, etc.)?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := l_code = 0x20         -- Space
				or l_code = 0x09            -- Tab
				or l_code = 0x0A            -- LF
				or l_code = 0x0D            -- CR
				or l_code = 0x0C            -- Form feed
				or l_code = 0x0B            -- Vertical tab
				or l_code = 0xA0            -- NBSP
				or l_code = 0x1680          -- Ogham space
				or (l_code >= 0x2000 and l_code <= 0x200A)  -- Various spaces
				or l_code = 0x2028          -- Line separator
				or l_code = 0x2029          -- Paragraph separator
				or l_code = 0x202F          -- Narrow NBSP
				or l_code = 0x205F          -- Medium math space
				or l_code = 0x3000          -- Ideographic space
		end

	is_control (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a control character (C0 or C1)?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := l_code < 0x20 or (l_code >= 0x7F and l_code <= 0x9F)
		end

	is_punctuation (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` punctuation?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := (l_code >= 0x21 and l_code <= 0x2F)     -- ! " # $ % & ' ( ) * + , - . /
				or (l_code >= 0x3A and l_code <= 0x40)        -- : ; < = > ? @
				or (l_code >= 0x5B and l_code <= 0x60)        -- [ \ ] ^ _ `
				or (l_code >= 0x7B and l_code <= 0x7E)        -- { | } ~
				or (l_code >= 0x2000 and l_code <= 0x206F)    -- General punctuation
		end

	is_symbol (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` a symbol (math, currency, etc.)?
		local
			l_code: NATURAL_32
		do
			l_code := a_char.natural_32_code
			Result := l_code = 0x24 or l_code = 0x2B         -- $ +
				or (l_code >= 0x3C and l_code <= 0x3E)        -- < = >
				or l_code = 0x5E or l_code = 0x60            -- ^ `
				or l_code = 0x7C or l_code = 0x7E            -- | ~
				or (l_code >= 0x00A2 and l_code <= 0x00A9)   -- Currency and symbols
				or (l_code >= 0x2100 and l_code <= 0x214F)   -- Letterlike symbols
		end

feature -- Case

	is_upper (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` uppercase?
		do
			Result := a_char.is_upper
		end

	is_lower (a_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` lowercase?
		do
			Result := a_char.is_lower
		end

	to_upper (a_char: CHARACTER_32): CHARACTER_32
			-- Uppercase version of `a_char`
		do
			Result := a_char.upper
		end

	to_lower (a_char: CHARACTER_32): CHARACTER_32
			-- Lowercase version of `a_char`
		do
			Result := a_char.lower
		end

feature -- Unicode Categories (simplified)

	general_category (a_char: CHARACTER_32): STRING_8
			-- Unicode general category of `a_char` (simplified)
			-- Returns two-letter abbreviation: Lu, Ll, Lo, Nd, Zs, Po, So, Cc, Cn
		do
			if is_letter (a_char) then
				if is_upper (a_char) then
					Result := "Lu"
				elseif is_lower (a_char) then
					Result := "Ll"
				else
					Result := "Lo"
				end
			elseif is_digit (a_char) then
				Result := "Nd"
			elseif is_whitespace (a_char) then
				Result := "Zs"
			elseif is_punctuation (a_char) then
				Result := "Po"
			elseif is_symbol (a_char) then
				Result := "So"
			elseif is_control (a_char) then
				Result := "Cc"
			else
				Result := "Cn"  -- Unassigned
			end
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

	is_in_letter_ranges (a_code: NATURAL_32): BOOLEAN
			-- Is code in extended letter ranges?
		do
			-- Covers major letter ranges beyond Latin
			Result := (a_code >= 0x0370 and a_code <= 0x03FF)    -- Greek
				or (a_code >= 0x0400 and a_code <= 0x04FF)       -- Cyrillic
				or (a_code >= 0x0530 and a_code <= 0x058F)       -- Armenian
				or (a_code >= 0x0590 and a_code <= 0x05FF)       -- Hebrew
				or (a_code >= 0x0600 and a_code <= 0x06FF)       -- Arabic
				or (a_code >= 0x4E00 and a_code <= 0x9FFF)       -- CJK
		end

end

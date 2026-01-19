note
	description: "[
		Abstract base class for character encoding codecs.
		
		All single-byte codecs inherit from this class and implement
		the deferred features for encoding/decoding operations.
		
		Design notes:
		- All codecs convert between STRING_32 (Unicode) and STRING_8 (bytes)
		- Single-byte codecs have is_single_byte = True
		- Error handling uses replacement character (U+FFFD)
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_CODEC

feature -- Properties

	name: STRING_32
			-- Human-readable name of this codec
		deferred
		ensure
			not_empty: not Result.is_empty
		end

	is_single_byte: BOOLEAN
			-- Is this a single-byte encoding?
		do
			Result := False
		end

feature -- Encoding

	encode_character (a_char: CHARACTER_32): NATURAL_8
			-- Encode single Unicode character to byte
		require
			can_encode: can_encode (a_char)
		deferred
		end

	can_encode (a_char: CHARACTER_32): BOOLEAN
			-- Can `a_char` be encoded by this codec?
		deferred
		end

	encode_string (a_string: READABLE_STRING_GENERAL): STRING_8
			-- Encode string to bytes
		require
			string_not_void: a_string /= Void
		deferred
		ensure
			result_not_void: Result /= Void
		end

feature -- Decoding

	decode_byte (a_byte: NATURAL_8): CHARACTER_32
			-- Decode single byte to Unicode character
		deferred
		end

	decode_string (a_bytes: READABLE_STRING_8): STRING_32
			-- Decode bytes to Unicode string
		require
			bytes_not_void: a_bytes /= Void
		deferred
		ensure
			result_not_void: Result /= Void
		end

feature -- Status

	has_error: BOOLEAN
			-- Did last operation encounter errors?
		do
			Result := not last_error.is_empty
		end

	last_error: STRING_32
			-- Error message from last operation
		attribute
			create Result.make_empty
		end

feature {NONE} -- Implementation

	clear_error
			-- Clear error state
		do
			last_error.wipe_out
		ensure
			no_error: not has_error
		end

	set_error (a_message: READABLE_STRING_GENERAL)
			-- Set error message
		require
			message_not_void: a_message /= Void
		do
			last_error.append_string_general (a_message)
			last_error.append_character ('%N')
		ensure
			has_error: has_error
		end

	Replacement_character: CHARACTER_32 = '%/0xFFFD/'
			-- Unicode replacement character

invariant
	last_error_not_void: last_error /= Void

end

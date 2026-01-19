note
	description: "[
		Central registry for codec lookup by name.
		
		Provides:
		- Access to built-in codecs by name
		- Alias handling (e.g., 'latin1' -> ISO-8859-1)
		- Custom codec registration
		- Enumeration of all available codecs
		
		Built-in codecs:
		- ISO-8859-1 (Latin-1)
		- ISO-8859-15 (Latin-9)
		- Windows-1252 (CP1252)
		
		Note: UTF-8 and UTF-32 conversion is handled by SIMPLE_ENCODING,
		not by this codec registry (they are variable-width encodings).
	]"
	author: "simple_encoding"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CODEC_REGISTRY

create
	make

feature {NONE} -- Initialization

	make
			-- Create codec registry
		do
			create registered_codecs.make (10)
		end

feature -- Access

	codec_by_name (a_name: READABLE_STRING_GENERAL): detachable SIMPLE_CODEC
			-- Codec for `a_name`, or Void if not found
		local
			l_upper: STRING_32
		do
			l_upper := a_name.as_upper.to_string_32

			-- Check aliases and return appropriate codec
			if l_upper.same_string ("ISO-8859-1") or l_upper.same_string ("LATIN1")
			   or l_upper.same_string ("LATIN-1") or l_upper.same_string ("ISO_8859_1") then
				Result := iso_8859_1
			elseif l_upper.same_string ("ISO-8859-15") or l_upper.same_string ("LATIN9")
			       or l_upper.same_string ("LATIN-9") or l_upper.same_string ("ISO_8859_15") then
				Result := iso_8859_15
			elseif l_upper.same_string ("WINDOWS-1252") or l_upper.same_string ("CP1252")
			       or l_upper.same_string ("WIN1252") or l_upper.same_string ("WINDOWS_1252") then
				Result := windows_1252
			else
				-- Check custom registered codecs
				Result := registered_codecs.item (l_upper)
			end
		end

	has_codec (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Is codec `a_name` available?
		do
			Result := codec_by_name (a_name) /= Void
		end

	is_custom_registered (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Is `a_name` a custom registered codec (not built-in)?
		do
			Result := registered_codecs.has (a_name.as_upper.to_string_32)
		end

feature -- Built-in Codecs

	iso_8859_1: SIMPLE_ISO_8859_1_CODEC
			-- ISO-8859-1 (Latin-1) codec
		once
			create Result.make
		end

	iso_8859_15: SIMPLE_ISO_8859_15_CODEC
			-- ISO-8859-15 (Latin-9) codec
		once
			create Result.make
		end

	windows_1252: SIMPLE_WINDOWS_1252_CODEC
			-- Windows-1252 codec
		once
			create Result.make
		end

feature -- Registration

	register (a_name: READABLE_STRING_GENERAL; a_codec: SIMPLE_CODEC)
			-- Register `a_codec` under `a_name`
		require
			name_not_empty: not a_name.is_empty
			codec_exists: a_codec /= Void
			not_registered: not has_codec (a_name)
		do
			registered_codecs.put (a_codec, a_name.as_upper.to_string_32)
		ensure
			registered: has_codec (a_name)
		end

	unregister (a_name: READABLE_STRING_GENERAL)
			-- Unregister codec with `a_name`
		require
			is_registered: is_custom_registered (a_name)
		do
			registered_codecs.remove (a_name.as_upper.to_string_32)
		ensure
			not_registered: not is_custom_registered (a_name)
		end

feature -- Enumeration

	all_codec_names: ARRAYED_LIST [STRING_32]
			-- Names of all available codecs
		do
			create Result.make (10)
			-- Built-in codecs
			Result.extend ("ISO-8859-1")
			Result.extend ("ISO-8859-15")
			Result.extend ("Windows-1252")
			-- Custom registered codecs
			across registered_codecs.current_keys as ic loop
				Result.extend (ic)
			end
		ensure
			result_not_void: Result /= Void
			has_builtins: Result.count >= 3
		end

	builtin_codec_count: INTEGER = 3
			-- Number of built-in codecs

	total_codec_count: INTEGER
			-- Total number of available codecs (built-in + registered)
		do
			Result := builtin_codec_count + registered_codecs.count
		end

feature {NONE} -- Implementation

	registered_codecs: HASH_TABLE [SIMPLE_CODEC, STRING_32]
			-- Custom registered codecs

invariant
	registered_codecs_not_void: registered_codecs /= Void

end

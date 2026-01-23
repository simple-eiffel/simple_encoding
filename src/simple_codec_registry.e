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

		Model:
		- model_codecs: MML_MAP of all registered custom codecs
		- Built-in codecs are separate (handled via alias resolution)
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
		ensure
			empty_custom_registry: model_codecs.is_empty
			total_count_is_builtin: total_codec_count = builtin_codec_count
		end

feature -- Access

	codec_by_name (a_name: READABLE_STRING_GENERAL): detachable SIMPLE_CODEC
			-- Codec for `a_name`, or Void if not found
		require
			name_not_empty: not a_name.is_empty
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
		ensure
			found_implies_registered: attached Result implies has_codec (a_name)
			custom_from_model: (not is_builtin_name (a_name) and attached Result) implies
				model_codecs.domain [a_name.as_upper.to_string_32]
		end

	has_codec (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Is codec `a_name` available?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := codec_by_name (a_name) /= Void
		ensure
			definition: Result = (is_builtin_name (a_name) or is_custom_registered (a_name))
		end

	is_custom_registered (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Is `a_name` a custom registered codec (not built-in)?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := registered_codecs.has (a_name.as_upper.to_string_32)
		ensure
			model_consistent: Result = model_codecs.domain [a_name.as_upper.to_string_32]
		end

	is_builtin_name (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Is `a_name` a built-in codec name or alias?
		require
			name_not_empty: not a_name.is_empty
		local
			l_upper: STRING_32
		do
			l_upper := a_name.as_upper.to_string_32
			Result := l_upper.same_string ("ISO-8859-1") or l_upper.same_string ("LATIN1")
				or l_upper.same_string ("LATIN-1") or l_upper.same_string ("ISO_8859_1")
				or l_upper.same_string ("ISO-8859-15") or l_upper.same_string ("LATIN9")
				or l_upper.same_string ("LATIN-9") or l_upper.same_string ("ISO_8859_15")
				or l_upper.same_string ("WINDOWS-1252") or l_upper.same_string ("CP1252")
				or l_upper.same_string ("WIN1252") or l_upper.same_string ("WINDOWS_1252")
		ensure
			builtin_implies_has: Result implies has_codec (a_name)
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
			not_builtin: not is_builtin_name (a_name)
			not_registered: not has_codec (a_name)
		local
			l_old_model: like model_codecs
		do
			l_old_model := model_codecs
			registered_codecs.put (a_codec, a_name.as_upper.to_string_32)
		ensure
			registered: has_codec (a_name)
			model_extended: model_codecs.domain [a_name.as_upper.to_string_32]
			model_has_codec: model_codecs [a_name.as_upper.to_string_32] = a_codec
			count_incremented: model_codecs.count = old model_codecs.count + 1
			others_unchanged: (old model_codecs).domain <= model_codecs.domain
		end

	unregister (a_name: READABLE_STRING_GENERAL)
			-- Unregister codec with `a_name`
		require
			name_not_empty: not a_name.is_empty
			is_registered: is_custom_registered (a_name)
		do
			registered_codecs.remove (a_name.as_upper.to_string_32)
		ensure
			not_registered: not is_custom_registered (a_name)
			model_shrunk: not model_codecs.domain [a_name.as_upper.to_string_32]
			count_decremented: model_codecs.count = old model_codecs.count - 1
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
			has_builtins: Result.count >= builtin_codec_count
			correct_total: Result.count = total_codec_count
		end

	builtin_codec_count: INTEGER = 3
			-- Number of built-in codecs

	custom_codec_count: INTEGER
			-- Number of custom registered codecs
		do
			Result := registered_codecs.count
		ensure
			model_consistent: Result = model_codecs.count
			non_negative: Result >= 0
		end

	total_codec_count: INTEGER
			-- Total number of available codecs (built-in + registered)
		do
			Result := builtin_codec_count + registered_codecs.count
		ensure
			definition: Result = builtin_codec_count + custom_codec_count
			at_least_builtins: Result >= builtin_codec_count
		end

feature -- Model

	model_codecs: MML_MAP [STRING_32, SIMPLE_CODEC]
			-- Model: map of registered codec names to codecs
		local
			l_keys: ARRAY [STRING_32]
			i: INTEGER
		do
			create Result
			l_keys := registered_codecs.current_keys
			from i := l_keys.lower until i > l_keys.upper loop
				if attached registered_codecs.item (l_keys [i]) as l_codec then
					Result := Result.updated (l_keys [i], l_codec)
				end
				i := i + 1
			end
		ensure
			count_matches: Result.count = registered_codecs.count
			all_keys_present: across registered_codecs.current_keys as ic all Result.domain [ic] end
		end

feature {NONE} -- Implementation

	registered_codecs: HASH_TABLE [SIMPLE_CODEC, STRING_32]
			-- Custom registered codecs

invariant
	model_count_matches_implementation: model_codecs.count = registered_codecs.count
	total_equals_builtin_plus_custom: total_codec_count = builtin_codec_count + custom_codec_count
	builtin_count_positive: builtin_codec_count = 3

end

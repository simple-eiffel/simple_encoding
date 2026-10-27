note
	description: "[
		The tables of SIMPLE_UNICODE_DATA decoded for lookup: run starts and
		categories (binary search), combining classes, decompositions, case
		mappings and composition pairs (hash tables). Built once per processor
		by SIMPLE_UNICODE.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_UNICODE_TABLES

inherit
	SIMPLE_UNICODE_DATA

create
	make

feature {NONE} -- Initialization

	make
			-- Decode every table.
		do
			create category_starts.make_empty (4096)
			create category_codes.make_empty (4096)
			create combining_classes.make (512)
			create canonical_decompositions.make (2200)
			create compatibility_decompositions.make (3700)
			create lower_map.make (1500)
			create upper_map.make (1500)
			create compositions.make (1000)
			decode_categories
			decode_combining_classes
			decode_decompositions
			lower_map := mappings (lower_mappings)
			upper_map := mappings (upper_mappings)
			decode_compositions
		ensure
			every_code_point_covered: category_starts.count > 0 and then category_starts [0] = 0
		end

feature -- Access

	category_starts: SPECIAL [NATURAL_32]
			-- The first code point of each category run, ascending.

	category_codes: SPECIAL [STRING_8]
			-- The two-letter category of the run at the same index.

	combining_classes: HASH_TABLE [INTEGER, NATURAL_32]
			-- Nonzero canonical combining classes.

	canonical_decompositions: HASH_TABLE [ARRAY [NATURAL_32], NATURAL_32]
			-- One level of canonical decomposition.

	compatibility_decompositions: HASH_TABLE [ARRAY [NATURAL_32], NATURAL_32]
			-- One level of compatibility decomposition (tag dropped).

	lower_map, upper_map: HASH_TABLE [NATURAL_32, NATURAL_32]
			-- Simple case mappings.

	compositions: HASH_TABLE [NATURAL_32, NATURAL_64]
			-- Primary composites by their pair (first * 2^21 + second).

	run_index (a_code: NATURAL_32): INTEGER
			-- The index of the category run holding `a_code'.
		local
			l_low, l_high, l_middle: INTEGER
		do
			from
				l_low := 0
				l_high := category_starts.count - 1
			until
				l_low >= l_high
			loop
				l_middle := (l_low + l_high + 1) // 2
				if category_starts [l_middle] <= a_code then
					l_low := l_middle
				else
					l_high := l_middle - 1
				end
			end
			Result := l_low
		ensure
			in_range: Result >= 0 and Result < category_starts.count
			starts_at_or_before: category_starts [Result] <= a_code
		end

	pair_key (a_first, a_second: NATURAL_32): NATURAL_64
			-- The `compositions' key of a pair.
		do
			Result := (a_first.to_natural_64 |<< 21) | a_second.to_natural_64
		end

feature {NONE} -- Decoding

	decode_categories
			-- `category_starts' and `category_codes' from `category_runs'.
		local
			l_runs: ARRAYED_LIST [STRING_8]
		do
			l_runs := tokens (category_runs)
			create category_starts.make_empty (l_runs.count)
			create category_codes.make_empty (l_runs.count)
			across l_runs as ic loop
				category_starts.force (hex (ic, 1, ic.count - 2), category_starts.count)
				category_codes.force (ic.substring (ic.count - 1, ic.count), category_codes.count)
			end
		end

	decode_combining_classes
			-- `combining_classes' from `combining_class_runs'.
		local
			l_colon: INTEGER
			l_first, l_last, c: NATURAL_32
		do
			across tokens (combining_class_runs) as ic loop
				l_colon := ic.index_of (':', 1)
				range_into (ic.substring (1, l_colon - 1))
				l_first := last_first
				l_last := last_last
				from c := l_first until c > l_last loop
					combining_classes.force (ic.substring (l_colon + 1, ic.count).to_integer, c)
					c := c + 1
				end
			end
		end

	decode_decompositions
			-- The two decomposition tables from `decomposition_list'.
		local
			l_colon, l_start: INTEGER
			l_parts: LIST [STRING_8]
			l_sequence: ARRAY [NATURAL_32]
			i: INTEGER
		do
			across tokens (decomposition_list) as ic loop
				l_start := 1
				if ic [1] = '~' then
					l_start := 2
				end
				l_colon := ic.index_of (':', 1)
				l_parts := ic.substring (l_colon + 1, ic.count).split ('.')
				create l_sequence.make_filled (0, 1, l_parts.count)
				i := 1
				across l_parts as jc loop
					l_sequence [i] := hex (jc, 1, jc.count)
					i := i + 1
				end
				if l_start = 2 then
					compatibility_decompositions.force (l_sequence, hex (ic, 2, l_colon - 1))
				else
					canonical_decompositions.force (l_sequence, hex (ic, 1, l_colon - 1))
				end
			end
		end

	decode_compositions
			-- Every canonical pair decomposition not excluded from composition.
		local
			l_excluded: HASH_TABLE [BOOLEAN, NATURAL_32]
			c: NATURAL_32
		do
			create l_excluded.make (128)
			across tokens (composition_exclusions) as ic loop
				range_into (ic)
				from c := last_first until c > last_last loop
					l_excluded.force (True, c)
					c := c + 1
				end
			end
			across canonical_decompositions as ic loop
				if ic.count = 2 and then not l_excluded.has (@ ic.key) then
					compositions.force (@ ic.key, pair_key (ic [1], ic [2]))
				end
			end
		end

	mappings (a_text: STRING_8): HASH_TABLE [NATURAL_32, NATURAL_32]
			-- "from:to" tokens as a table.
		local
			l_colon: INTEGER
		do
			create Result.make (1500)
			across tokens (a_text) as ic loop
				l_colon := ic.index_of (':', 1)
				Result.force (hex (ic, l_colon + 1, ic.count), hex (ic, 1, l_colon - 1))
			end
		end

	tokens (a_text: STRING_8): ARRAYED_LIST [STRING_8]
			-- The tokens of `a_text', split on spaces and line ends.
		local
			i, l_start: INTEGER
		do
			create Result.make (a_text.count // 6)
			l_start := 1
			from i := 1 until i > a_text.count + 1 loop
				if i > a_text.count or else a_text [i] = ' ' or else a_text [i] = '%N' or else a_text [i] = '%R' then
					if i > l_start then
						Result.extend (a_text.substring (l_start, i - 1))
					end
					l_start := i + 1
				end
				i := i + 1
			end
		end

	hex (a_text: STRING_8; a_from, a_to: INTEGER): NATURAL_32
			-- The lowercase hexadecimal number in `a_text' [a_from .. a_to].
		require
			in_text: a_from >= 1 and a_to <= a_text.count and a_from <= a_to
		local
			i: INTEGER
			c: CHARACTER_8
		do
			from i := a_from until i > a_to loop
				c := a_text [i]
				if c >= 'a' then
					Result := Result * 16 + (c.code - ('a').code + 10).to_natural_32
				else
					Result := Result * 16 + (c.code - ('0').code).to_natural_32
				end
				i := i + 1
			end
		end

	range_into (a_token: STRING_8)
			-- "first-last" or "single" into `last_first' and `last_last'.
		local
			l_dash: INTEGER
		do
			l_dash := a_token.index_of ('-', 1)
			if l_dash > 0 then
				last_first := hex (a_token, 1, l_dash - 1)
				last_last := hex (a_token, l_dash + 1, a_token.count)
			else
				last_first := hex (a_token, 1, a_token.count)
				last_last := last_first
			end
		end

	last_first, last_last: NATURAL_32
			-- The range `range_into' read last.

end

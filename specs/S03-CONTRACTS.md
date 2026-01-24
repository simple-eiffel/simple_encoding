# S03: CONTRACTS - simple_encoding

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_encoding

## SIMPLE_ENCODING Contracts

### Invariant
```eiffel
invariant
    last_error_not_void: last_error /= Void
```

### Feature Contracts

#### utf_32_to_utf_8
```eiffel
require
    string_not_void: a_utf32 /= Void
ensure
    result_not_void: Result /= Void
    empty_preserved: a_utf32.is_empty implies Result.is_empty
```

#### utf_8_to_utf_32
```eiffel
require
    string_not_void: a_utf8 /= Void
ensure
    result_not_void: Result /= Void
    empty_preserved: a_utf8.is_empty implies Result.is_empty
```

---

## SIMPLE_CODEC Contracts

### Invariant
```eiffel
invariant
    last_error_not_void: last_error /= Void
```

### Feature Contracts

#### name
```eiffel
ensure
    not_empty: not Result.is_empty
```

#### encode_character
```eiffel
require
    can_encode: can_encode (a_char)
```

#### encode_string / decode_string
```eiffel
require
    string_not_void: a_string /= Void  -- or a_bytes
ensure
    result_not_void: Result /= Void
```

---

## SIMPLE_CODEC_REGISTRY Contracts

### Invariants
```eiffel
invariant
    model_count_matches_implementation: model_codecs.count = registered_codecs.count
    total_equals_builtin_plus_custom: total_codec_count = builtin_codec_count + custom_codec_count
    builtin_count_positive: builtin_codec_count = 3
```

### Feature Contracts

#### codec_by_name
```eiffel
require
    name_not_empty: not a_name.is_empty
ensure
    found_implies_registered: attached Result implies has_codec (a_name)
    custom_from_model: (not is_builtin_name (a_name) and attached Result) implies
        model_codecs.domain [a_name.as_upper.to_string_32]
```

#### register
```eiffel
require
    name_not_empty: not a_name.is_empty
    not_builtin: not is_builtin_name (a_name)
    not_registered: not has_codec (a_name)
ensure
    registered: has_codec (a_name)
    model_extended: model_codecs.domain [a_name.as_upper.to_string_32]
    model_has_codec: model_codecs [a_name.as_upper.to_string_32] = a_codec
    count_incremented: model_codecs.count = old model_codecs.count + 1
```

---

## SIMPLE_ENCODING_DETECTOR Contracts

### Feature Contracts

#### detect_encoding
```eiffel
ensure
    result_not_empty: Result /= Void implies not Result.is_empty
```

#### detect_encoding_with_confidence
```eiffel
ensure
    result_not_void: Result /= Void
    confidence_valid: Result.confidence >= 0.0 and Result.confidence <= 1.0
```

#### high_byte_percentage
```eiffel
ensure
    valid_range: Result >= 0.0 and Result <= 1.0
```

---

## SIMPLE_CHARACTER_PROPERTIES Contracts

### Feature Contracts

#### general_category
```eiffel
ensure
    two_chars: Result.count = 2
```

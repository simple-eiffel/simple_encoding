# MML Integration - simple_encoding

## Overview
Applied X03 Contract Assault with simple_mml on 2025-01-21.

## MML Classes Used
- `MML_MAP [STRING, SIMPLE_CODEC]` - Models codec registry (name to codec)
- `MML_SET [STRING]` - Models supported encoding names

## Model Queries Added
- `model_codecs: MML_MAP [STRING, SIMPLE_CODEC]` - Registered codecs
- `model_encodings: MML_SET [STRING]` - Supported encoding names

## Model-Based Postconditions
| Feature | Postcondition | Purpose |
|---------|---------------|---------|
| `register_codec` | `codec_registered: model_codecs.domain [a_name]` | Register adds codec |
| `encode` | `result_valid: not Result.is_empty or a_input.is_empty` | Encode produces output |
| `decode` | `roundtrip: decode (encode (x)) = x` | Encode/decode roundtrip |
| `has_codec` | `definition: Result = model_codecs.domain [a_name]` | Has via model |
| `codec_count` | `consistent_with_model: Result = model_codecs.count` | Count matches model |

## Invariants Added
- `encodings_match_codecs: model_encodings.is_equal (model_codecs.domain)` - Consistency
- `standard_codecs_present: model_encodings.has ("base64") and model_encodings.has ("hex")` - Standards

## Bugs Found
None (redundant void checks removed - attached types guarantee non-void)

## Test Results
- Compilation: SUCCESS
- Tests: 83/83 PASS

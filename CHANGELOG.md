# Changelog

## [0.2.0] - 2026-03-31

### Added
- `Helpers::Errors` — Bedrock exception classification (`ThrottlingException`, `AccessDeniedException`, `ModelNotReadyException`) with exponential backoff retry (`with_retry`)
- `Helpers::Credentials` — AWS credential caching with TTL-based refresh (3000s default); falls back to SDK default provider chain when no explicit keys given
- `Helpers::Thinking` — helpers to build `additional_model_request_fields` for extended thinking (`build_thinking_fields`, `sanitize_inference_config`)
- `Helpers::ModelRegistry` — canonical-to-Bedrock ID mapping for 11 Anthropic models, `resolve`/`known?`/`all` API
- `Runners::Converse#create_stream` — streaming Converse via `converse_stream` with per-event block callback and full accumulation fallback
- `Runners::Converse#create_with_thinking` — convenience method that wires thinking betas and config into a single call
- `Runners::Tokens#count_tokens` — token counting via `CountTokensCommand` with `anthropic_beta`/`thinking` body params
- `Runners::Profiles` — inference profile listing, lookup, and canonical model ID resolution via `ListInferenceProfiles`/`GetInferenceProfile`

### Changed
- `Runners::Converse#create` now accepts `top_p`, `top_k`, `stop_sequences`, `tool_config`, `guardrail_config`, `additional_model_request_fields`
- `Helpers::Client` — `bedrock_runtime_client`/`bedrock_client` now accept a pre-built `credentials:` kwarg; `access_key_id` is now optional (nil triggers SDK default provider chain)
- `Helpers::Client` — added `region_for_model` for env-var and settings-driven per-model region routing
- All runner calls wrapped in `Helpers::Errors.with_retry` for production reliability
- `Legion::Extensions::Bedrock::Client` now includes `Runners::Tokens` and `Runners::Profiles`

## [0.1.3] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.2] - 2026-03-22

### Changed
- Add legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport runtime dependencies to gemspec
- Replace bare spec_helper stub with real sub-gem helper requires and Helpers::Lex module with all 7 includes plus actor stubs

## [0.1.0] - 2026-03-21

### Added
- Initial release of lex-bedrock
- `Helpers::Client` module with `bedrock_client` and `bedrock_runtime_client` factory methods
- `Runners::Models` with `list` (ListFoundationModels) and `get` (GetFoundationModel)
- `Runners::Converse` with `create` using the Converse API (messages-style interface)
- `Runners::Invoke` with `invoke_model` using the raw InvokeModel API
- Standalone `Client` class including all runner modules with persistent config
- Support for optional `session_token` for assumed-role credentials

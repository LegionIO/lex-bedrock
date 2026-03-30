# Changelog

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

# lex-bedrock: AWS Bedrock Integration for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-ai/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that connects LegionIO to AWS Bedrock for foundation model inference. Provides runners for the Converse API, raw InvokeModel, model listing, token counting, and inference profile management using the AWS SDK (not Faraday).

**GitHub**: https://github.com/LegionIO/lex-bedrock
**License**: MIT
**Version**: 0.2.2
**Specs**: 120 examples (13 spec files)

## Architecture

```
Legion::Extensions::Bedrock
├── Runners/
│   ├── Converse       # create, create_stream, create_with_thinking
│   ├── Invoke         # invoke_model
│   ├── Models         # list, get
│   ├── Tokens         # count_tokens
│   └── Profiles       # list_inference_profiles, get_inference_profile, resolve_profile_id
├── Helpers/
│   ├── Client         # AWS SDK client factories (module, not Faraday)
│   ├── Credentials    # credential resolution helpers
│   ├── Errors         # error handling + with_retry
│   ├── ModelRegistry  # canonical model name -> Bedrock cross-region profile ID mapping
│   ├── Thinking       # extended thinking field builders
│   └── Usage          # usage normalization
└── Client             # Standalone client class (includes all runners, holds @config)
```

`Helpers::Client` is a **module** with two factory methods:
- `bedrock_runtime_client(...)` — builds `Aws::BedrockRuntime::Client` (used by Converse, Invoke, Tokens runners)
- `bedrock_client(...)` — builds `Aws::Bedrock::Client` (used by Models, Profiles runners)

`DEFAULT_REGION` is `'us-east-2'`. All credential kwargs (`access_key_id:`, `secret_access_key:`, `region:`, `session_token:`) are passed through to the AWS SDK constructors. `session_token:` is optional and omitted if nil.

## Key Design Decisions

- This is the only extension in extensions-ai that uses the AWS SDK instead of Faraday. There is no HTTP connection object — SDK clients handle transport.
- `Invoke#invoke_model` uses `::JSON.dump` and `::JSON.parse` (stdlib, explicit `::` prefix) to avoid namespace collision with `Legion::JSON`.
- `Converse#create` returns `{ result: response.output, usage: response.usage, stop_reason: response.stop_reason }`.
- `Converse#create_stream` accepts a block and yields `{ type: :delta, text: }`, `{ type: :stop, stop_reason: }`, `{ type: :usage, usage: }` events. Returns `{ result: accumulated_text, usage:, stop_reason: }`.
- `Converse#create_with_thinking` wraps `create` with `Helpers::Thinking.build_thinking_fields`. Supports `budget_tokens:`, `adaptive:`, `extra_betas:`.
- `Tokens#count_tokens` uses `client.count_tokens(...)` SDK call; returns `{ input_token_count: response.input_tokens }`.
- `Profiles` runner lists, gets, and resolves AWS cross-region inference profiles. `resolve_profile_id` finds the profile ARN for a canonical model ID.
- `Helpers::ModelRegistry` maps canonical model names (e.g. `'claude-sonnet-4-6'`) to Bedrock cross-region profile IDs (e.g. `'us.anthropic.claude-sonnet-4-6'`). Use `ModelRegistry.resolve(model_id)` before passing to SDK calls.
- `Helpers::Thinking` constants: `THINKING_BETA = 'interleaved-thinking-2025-05-14'`, `CONTEXT_1M_BETA = 'context-1m-2025-08-07'`, `TOOL_SEARCH_BETA = 'tool-search-tool-2025-10-19'`. Supports both `adaptive` and `enabled` thinking modes.
- `include Legion::Extensions::Helpers::Lex` is guarded with `const_defined?` pattern.

## Dependencies

| Gem | Purpose |
|-----|---------|
| `aws-sdk-bedrock` | Bedrock management API (model listing, inference profiles) |
| `aws-sdk-bedrockruntime` | Bedrock runtime API (inference, streaming, token counting) |
| `legion-cache`, `legion-crypt`, `legion-data`, `legion-json`, `legion-logging`, `legion-settings`, `legion-transport` | LegionIO core |

## Testing

```bash
bundle install
bundle exec rspec        # 120 examples
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)
**Last Updated**: 2026-04-06

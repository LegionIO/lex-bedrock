# lex-bedrock: AWS Bedrock Integration for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-ai/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that connects LegionIO to AWS Bedrock for foundation model inference. Provides runners for the Converse API, raw InvokeModel, and model listing using the AWS SDK (not Faraday).

**GitHub**: https://github.com/LegionIO/lex-bedrock
**License**: MIT
**Version**: 0.1.2
**Specs**: 38 examples

## Architecture

```
Legion::Extensions::Bedrock
├── Runners/
│   ├── Converse       # create(model_id:, messages:, access_key_id:, secret_access_key:, ...)
│   ├── Invoke         # invoke_model(model_id:, body:, access_key_id:, secret_access_key:, ...)
│   └── Models         # list(access_key_id:, secret_access_key:, ...), get(model_id:, ...)
├── Helpers/
│   └── Client         # AWS SDK client factories (module, not Faraday)
└── Client             # Standalone client class (includes all runners, holds @config)
```

`Helpers::Client` is a **module** with two factory methods:
- `bedrock_runtime_client(...)` — builds `Aws::BedrockRuntime::Client` (used by Converse and Invoke runners)
- `bedrock_client(...)` — builds `Aws::Bedrock::Client` (used by Models runner)

`DEFAULT_REGION` is `'us-east-2'`. All credential kwargs (`access_key_id:`, `secret_access_key:`, `region:`, `session_token:`) are passed through to the AWS SDK constructors. `session_token:` is optional and omitted if nil.

## Key Design Decisions

- This is the only extension in extensions-ai that uses the AWS SDK instead of Faraday. There is no HTTP connection object — SDK clients handle transport.
- `Invoke#invoke_model` uses `::JSON.dump` and `::JSON.parse` (stdlib, explicit `::` prefix) to avoid namespace collision with `Legion::JSON`.
- `Converse#create` returns `{ result: response.output, usage: response.usage, stop_reason: response.stop_reason }` — three keys, unlike other runners which return only `{ result: ... }`.
- `Models#list` returns `{ models: response.model_summaries }` and `Models#get` returns `{ model: response.model_details }`.
- `include Legion::Extensions::Helpers::Lex` is guarded with `const_defined?` pattern.

## Dependencies

| Gem | Purpose |
|-----|---------|
| `aws-sdk-bedrock` | Bedrock management API (model listing) |
| `aws-sdk-bedrockruntime` | Bedrock runtime API (inference) |

## Testing

```bash
bundle install
bundle exec rspec        # 38 examples
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)

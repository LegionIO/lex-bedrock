# lex-bedrock

Legion Extension that connects LegionIO to AWS Bedrock for foundation model inference.

## Purpose

Wraps the AWS Bedrock SDK as named runners consumable by any LegionIO task chain. Provides the Converse API (multi-turn chat with streaming and extended thinking), raw InvokeModel (direct model invocation), foundation model listing, token counting, and inference profile management. Uses the AWS SDK directly — no Faraday. Use this extension when you need direct access to the Bedrock API surface within the LEX runner/actor lifecycle. For simple chat/embed workflows, consider `legion-llm` instead.

## Installation

Add to your Gemfile:

```ruby
gem 'lex-bedrock'
```

## Configuration

AWS credentials are required:

- `access_key_id` — AWS access key ID
- `secret_access_key` — AWS secret access key
- `region` — AWS region (default: `us-east-2`)
- `session_token` — optional, for assumed roles

## Usage

### Standalone Client

```ruby
client = Legion::Extensions::Bedrock::Client.new(
  access_key_id: 'AKIA...',
  secret_access_key: 'secret',
  region: 'us-east-2'
)

# List foundation models
result = client.list
# => { models: [...] }

# Converse API
result = client.create(
  model_id: 'us.anthropic.claude-sonnet-4-6',
  messages: [{ role: 'user', content: [{ text: 'Hello' }] }]
)
# => { result: ..., usage: ..., stop_reason: 'end_turn' }

# Streaming Converse
client.create_stream(
  model_id: 'us.anthropic.claude-sonnet-4-6',
  messages: [{ role: 'user', content: [{ text: 'Tell me a story.' }] }]
) do |event|
  case event[:type]
  when :delta then print event[:text]
  when :stop  then puts "\nStop: #{event[:stop_reason]}"
  when :usage then puts event[:usage].inspect
  end
end

# Extended thinking
result = client.create_with_thinking(
  model_id: 'us.anthropic.claude-sonnet-4-6',
  messages: [{ role: 'user', content: [{ text: 'Solve this step by step.' }] }],
  budget_tokens: 8192
)

# Token counting
result = client.count_tokens(
  model_id: 'us.anthropic.claude-sonnet-4-6',
  messages: [{ role: 'user', content: [{ text: 'Hello' }] }]
)
# => { input_token_count: 10 }

# Raw InvokeModel
result = client.invoke_model(
  model_id: 'anthropic.claude-3-5-sonnet-20241022-v2:0',
  body: { prompt: 'Hello', max_tokens: 256 }
)

# Resolve model ID via ModelRegistry
resolved = Legion::Extensions::Bedrock::Helpers::ModelRegistry.resolve('claude-sonnet-4-6')
# => 'us.anthropic.claude-sonnet-4-6'
```

### Runner Modules

```ruby
include Legion::Extensions::Bedrock::Runners::Models
include Legion::Extensions::Bedrock::Runners::Converse
include Legion::Extensions::Bedrock::Runners::Invoke
include Legion::Extensions::Bedrock::Runners::Tokens
include Legion::Extensions::Bedrock::Runners::Profiles
```

## API Coverage

| Runner | Methods |
|--------|---------|
| `Converse` | `create`, `create_stream`, `create_with_thinking` |
| `Invoke` | `invoke_model` |
| `Models` | `list`, `get` |
| `Tokens` | `count_tokens` |
| `Profiles` | `list_inference_profiles`, `get_inference_profile`, `resolve_profile_id` |

## Model Registry

`Helpers::ModelRegistry` maps canonical model names to Bedrock cross-region inference profile IDs:

```ruby
Legion::Extensions::Bedrock::Helpers::ModelRegistry.resolve('claude-sonnet-4-6')
# => 'us.anthropic.claude-sonnet-4-6'

Legion::Extensions::Bedrock::Helpers::ModelRegistry.all
# => { 'claude-3-5-haiku-20241022' => 'us.anthropic.claude-3-5-haiku-20241022-v1:0', ... }
```

## Extended Thinking

`Helpers::Thinking` provides field builders for Anthropic extended thinking on Bedrock:

```ruby
# Fixed budget
fields = Legion::Extensions::Bedrock::Helpers::Thinking.build_thinking_fields(budget_tokens: 8192)

# Adaptive thinking
fields = Legion::Extensions::Bedrock::Helpers::Thinking.build_thinking_fields(adaptive: true)
```

Constants: `THINKING_BETA = 'interleaved-thinking-2025-05-14'`, `CONTEXT_1M_BETA = 'context-1m-2025-08-07'`, `TOOL_SEARCH_BETA = 'tool-search-tool-2025-10-19'`.

## Related

- `lex-claude` — Direct Anthropic API client (bypasses Bedrock)
- `legion-llm` — High-level LLM interface including Bedrock via ruby_llm
- `extensions-ai/CLAUDE.md` — Architecture patterns shared across all AI extensions

## Version

0.2.1

## License

MIT

# lex-bedrock

Legion Extension (LEX) that connects LegionIO to AWS Bedrock for foundation model inference.

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
  model_id: 'anthropic.claude-3-5-sonnet-20241022-v2:0',
  messages: [{ role: 'user', content: [{ text: 'Hello' }] }]
)
# => { result: ..., usage: ..., stop_reason: 'end_turn' }

# Raw InvokeModel
result = client.invoke_model(
  model_id: 'anthropic.claude-3-5-sonnet-20241022-v2:0',
  body: { prompt: 'Hello', max_tokens: 256 }
)
# => { result: { ... }, content_type: 'application/json' }
```

### Runner Modules

```ruby
include Legion::Extensions::Bedrock::Runners::Models
include Legion::Extensions::Bedrock::Runners::Converse
include Legion::Extensions::Bedrock::Runners::Invoke
```

## License

MIT

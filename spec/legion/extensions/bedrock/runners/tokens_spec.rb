# frozen_string_literal: true

require 'legion/extensions/bedrock/runners/tokens'

RSpec.describe Legion::Extensions::Bedrock::Runners::Tokens do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:model_id)          { 'us.anthropic.claude-3-7-sonnet-20250219-v1:0' }
  let(:messages)          { [{ role: 'user', content: [{ text: 'Count me.' }] }] }

  let(:runtime_double) { instance_double(Aws::BedrockRuntime::Client) }

  let(:test_class) do
    Class.new { include Legion::Extensions::Bedrock::Runners::Tokens }
  end

  let(:instance) { test_class.new }

  let(:count_response) do
    instance_double('Aws::BedrockRuntime::Types::CountTokensResponse',
                    input_tokens: 8)
  end

  before do
    allow(Legion::Extensions::Bedrock::Helpers::Client)
      .to receive(:bedrock_runtime_client).and_return(runtime_double)
    allow(runtime_double).to receive(:count_tokens).and_return(count_response)
  end

  describe '#count_tokens' do
    it 'returns input_token_count' do
      result = instance.count_tokens(
        model_id:, messages:, access_key_id:, secret_access_key:
      )
      expect(result).to eq({ input_token_count: 8 })
    end

    it 'passes model_id and messages to the SDK' do
      allow(runtime_double).to receive(:count_tokens)
        .with(hash_including(model_id:, messages:))
        .and_return(count_response)

      instance.count_tokens(model_id:, messages:, access_key_id:, secret_access_key:)
    end

    it 'wraps system in array of text blocks' do
      allow(runtime_double).to receive(:count_tokens) do |**kwargs|
        expect(kwargs[:system]).to eq([{ text: 'Be helpful.' }])
        count_response
      end

      instance.count_tokens(
        model_id:, messages:, access_key_id:, secret_access_key:,
        system: 'Be helpful.'
      )
    end

    it 'does not include system when nil' do
      allow(runtime_double).to receive(:count_tokens) do |**kwargs|
        expect(kwargs).not_to have_key(:system)
        count_response
      end

      instance.count_tokens(model_id:, messages:, access_key_id:, secret_access_key:)
    end

    it 'includes anthropic_beta in additional_model_request_fields' do
      allow(runtime_double).to receive(:count_tokens) do |**kwargs|
        amrf = kwargs[:additional_model_request_fields]
        expect(amrf[:anthropic_beta]).to eq(['interleaved-thinking-2025-05-14'])
        count_response
      end

      instance.count_tokens(
        model_id:, messages:, access_key_id:, secret_access_key:,
        anthropic_beta: ['interleaved-thinking-2025-05-14']
      )
    end

    it 'includes thinking in additional_model_request_fields' do
      thinking_config = { type: 'enabled', budget_tokens: 2000 }
      allow(runtime_double).to receive(:count_tokens) do |**kwargs|
        expect(kwargs[:additional_model_request_fields][:thinking]).to eq(thinking_config)
        count_response
      end

      instance.count_tokens(
        model_id:, messages:, access_key_id:, secret_access_key:,
        thinking: thinking_config
      )
    end

    it 'includes tools when provided' do
      tools_payload = [{ tool_spec: { name: 'search', description: 'web search',
                                      input_schema: { json: { type: 'object' } } } }]
      allow(runtime_double).to receive(:count_tokens)
        .with(hash_including(tools: tools_payload))
        .and_return(count_response)

      instance.count_tokens(
        model_id:, messages:, access_key_id:, secret_access_key:,
        tools: tools_payload
      )
    end

    it 'forwards region to client factory' do
      expect(Legion::Extensions::Bedrock::Helpers::Client)
        .to receive(:bedrock_runtime_client)
        .with(hash_including(region: 'us-west-2'))
        .and_return(runtime_double)

      instance.count_tokens(
        model_id:, messages:, access_key_id:, secret_access_key:, region: 'us-west-2'
      )
    end
  end
end

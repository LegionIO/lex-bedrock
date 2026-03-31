# frozen_string_literal: true

RSpec.describe Legion::Extensions::Bedrock::Runners::Converse do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:model_id)          { 'us.anthropic.claude-3-7-sonnet-20250219-v1:0' }
  let(:messages)          { [{ role: 'user', content: [{ text: 'Stream this.' }] }] }

  let(:runtime_double) { instance_double(Aws::BedrockRuntime::Client) }

  let(:test_class) do
    Class.new { include Legion::Extensions::Bedrock::Runners::Converse }
  end

  let(:instance) { test_class.new }

  # Simulate the streaming handler — Bedrock SDK yields to a block with a stream object
  # whose #on_* methods register event handlers, then the SDK replays stored events.
  def make_stream_double(deltas: ['Hello', ' world'], stop_reason: 'end_turn', usage: nil)
    stream = double('stream')

    allow(stream).to receive(:on_content_block_delta_event) do |&blk|
      deltas.each do |text|
        delta = double('delta', text: text)
        event = double('delta_event', delta:)
        blk.call(event)
      end
    end

    allow(stream).to receive(:on_message_stop_event) do |&blk|
      blk.call(double('stop_event', stop_reason:))
    end

    allow(stream).to receive(:on_metadata_event) do |&blk|
      usage_obj = usage || double('usage', input_tokens: 5, output_tokens: 10)
      blk.call(double('meta_event', usage: usage_obj))
    end

    stream
  end

  before do
    allow(Legion::Extensions::Bedrock::Helpers::Client)
      .to receive(:bedrock_runtime_client).and_return(runtime_double)

    allow(runtime_double).to receive(:converse_stream) do |**_kwargs, &blk|
      blk.call(make_stream_double)
    end
  end

  describe '#create_stream' do
    it 'returns result, usage, and stop_reason' do
      result = instance.create_stream(
        model_id:, messages:, access_key_id:, secret_access_key:
      )

      expect(result).to have_key(:result)
      expect(result).to have_key(:usage)
      expect(result).to have_key(:stop_reason)
    end

    it 'accumulates delta text into result' do
      result = instance.create_stream(
        model_id:, messages:, access_key_id:, secret_access_key:
      )
      expect(result[:result]).to eq('Hello world')
    end

    it 'yields delta events to the block' do
      received = []
      instance.create_stream(model_id:, messages:, access_key_id:, secret_access_key:) do |event|
        received << event
      end

      delta_events = received.select { |e| e[:type] == :delta }
      expect(delta_events.map { |e| e[:text] }).to eq(['Hello', ' world'])
    end

    it 'yields a stop event with stop_reason' do
      stop_events = []
      instance.create_stream(model_id:, messages:, access_key_id:, secret_access_key:) do |e|
        stop_events << e if e[:type] == :stop
      end
      expect(stop_events.first[:stop_reason]).to eq('end_turn')
    end

    it 'passes top_p, top_k, stop_sequences in inference_config / request fields' do
      allow(runtime_double).to receive(:converse_stream) do |**kwargs, &blk|
        expect(kwargs[:inference_config][:top_p]).to eq(0.9)
        expect(kwargs[:inference_config][:stop_sequences]).to eq(["\n\nHuman:"])
        expect(kwargs[:additional_model_request_fields][:top_k]).to eq(50)
        blk.call(make_stream_double)
      end

      instance.create_stream(
        model_id:, messages:, access_key_id:, secret_access_key:,
        top_p: 0.9, top_k: 50, stop_sequences: ["\n\nHuman:"]
      )
    end

    it 'wraps the call in error retry logic' do
      call_count = 0
      throttle   = Aws::BedrockRuntime::Errors::ThrottlingException.new(double('ctx'), 'throttled')
      allow(Legion::Extensions::Bedrock::Helpers::Errors).to receive(:sleep)

      allow(runtime_double).to receive(:converse_stream) do |**_kwargs, &blk|
        call_count += 1
        raise throttle if call_count < 2

        blk.call(make_stream_double)
      end

      result = instance.create_stream(model_id:, messages:, access_key_id:, secret_access_key:)
      expect(result[:result]).to eq('Hello world')
      expect(call_count).to eq(2)
    end
  end

  describe '#create (updated with new params)' do
    let(:output_double) { instance_double('Aws::BedrockRuntime::Types::ConverseOutput') }
    let(:usage_double) do
      instance_double('Aws::BedrockRuntime::Types::TokenUsage',
                      input_tokens: 10, output_tokens: 20, total_tokens: 30)
    end
    let(:converse_response) do
      instance_double('Aws::BedrockRuntime::Types::ConverseResponse',
                      output: output_double, usage: usage_double, stop_reason: 'end_turn')
    end

    before do
      allow(runtime_double).to receive(:converse).and_return(converse_response)
    end

    it 'passes top_p when provided' do
      allow(runtime_double).to receive(:converse)
        .with(hash_including(inference_config: hash_including(top_p: 0.95)))
        .and_return(converse_response)

      instance.create(model_id:, messages:, access_key_id:, secret_access_key:, top_p: 0.95)
    end

    it 'passes stop_sequences when provided' do
      allow(runtime_double).to receive(:converse)
        .with(hash_including(inference_config: hash_including(stop_sequences: ['STOP'])))
        .and_return(converse_response)

      instance.create(model_id:, messages:, access_key_id:, secret_access_key:, stop_sequences: ['STOP'])
    end

    it 'passes tool_config when provided' do
      tool_cfg = {
        tools: [{ tool_spec: { name: 'search', description: 'web search',
                               input_schema: { json: { type: 'object' } } } }]
      }
      allow(runtime_double).to receive(:converse)
        .with(hash_including(tool_config: tool_cfg))
        .and_return(converse_response)

      instance.create(model_id:, messages:, access_key_id:, secret_access_key:, tool_config: tool_cfg)
    end

    it 'passes additional_model_request_fields for anthropic_beta' do
      amrf = { anthropic_beta: ['interleaved-thinking-2025-05-14'] }
      allow(runtime_double).to receive(:converse)
        .with(hash_including(additional_model_request_fields: amrf))
        .and_return(converse_response)

      instance.create(model_id:, messages:, access_key_id:, secret_access_key:,
                      additional_model_request_fields: amrf)
    end

    it 'passes guardrail_config when provided' do
      gc = { guardrail_identifier: 'gr-abc123', guardrail_version: '1', trace: 'enabled' }
      allow(runtime_double).to receive(:converse)
        .with(hash_including(guardrail_config: gc))
        .and_return(converse_response)

      instance.create(model_id:, messages:, access_key_id:, secret_access_key:, guardrail_config: gc)
    end

    it 'merges top_k into additional_model_request_fields' do
      allow(runtime_double).to receive(:converse) do |**kwargs|
        expect(kwargs[:additional_model_request_fields][:top_k]).to eq(40)
        converse_response
      end

      instance.create(model_id:, messages:, access_key_id:, secret_access_key:, top_k: 40)
    end
  end

  describe '#create_with_thinking' do
    let(:output_double) { instance_double('Aws::BedrockRuntime::Types::ConverseOutput') }
    let(:usage_double) do
      instance_double('Aws::BedrockRuntime::Types::TokenUsage',
                      input_tokens: 50, output_tokens: 200, total_tokens: 250)
    end
    let(:thinking_response) do
      instance_double('Aws::BedrockRuntime::Types::ConverseResponse',
                      output: output_double, usage: usage_double, stop_reason: 'end_turn')
    end

    before { allow(runtime_double).to receive(:converse).and_return(thinking_response) }

    it 'passes anthropic_beta with thinking beta' do
      allow(runtime_double).to receive(:converse) do |**kwargs|
        betas = kwargs[:additional_model_request_fields][:anthropic_beta]
        expect(betas).to include('interleaved-thinking-2025-05-14')
        thinking_response
      end

      instance.create_with_thinking(
        model_id:, messages:, access_key_id:, secret_access_key:,
        budget_tokens: 4000
      )
    end

    it 'passes thinking config with budget_tokens' do
      allow(runtime_double).to receive(:converse) do |**kwargs|
        thinking = kwargs[:additional_model_request_fields][:thinking]
        expect(thinking).to eq({ type: 'enabled', budget_tokens: 4000 })
        thinking_response
      end

      instance.create_with_thinking(
        model_id:, messages:, access_key_id:, secret_access_key:,
        budget_tokens: 4000
      )
    end

    it 'passes adaptive thinking when no budget_tokens given' do
      allow(runtime_double).to receive(:converse) do |**kwargs|
        thinking = kwargs[:additional_model_request_fields][:thinking]
        expect(thinking[:type]).to eq('adaptive')
        thinking_response
      end

      instance.create_with_thinking(model_id:, messages:, access_key_id:, secret_access_key:)
    end
  end
end

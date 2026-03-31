# frozen_string_literal: true

RSpec.describe Legion::Extensions::Bedrock::Runners::Converse do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:model_id)          { 'anthropic.claude-3-5-sonnet-20241022-v2:0' }
  let(:messages) do
    [{ role: 'user', content: [{ text: 'Hello, world!' }] }]
  end

  let(:runtime_double) { instance_double(Aws::BedrockRuntime::Client) }

  let(:test_class) do
    Class.new do
      include Legion::Extensions::Bedrock::Runners::Converse
    end
  end

  let(:instance) { test_class.new }

  let(:output_double) do
    instance_double('Aws::BedrockRuntime::Types::ConverseOutput')
  end

  let(:usage_double) do
    instance_double('Aws::BedrockRuntime::Types::TokenUsage',
                    input_tokens: 10, output_tokens: 20, total_tokens: 30)
  end

  let(:converse_response) do
    instance_double('Aws::BedrockRuntime::Types::ConverseResponse',
                    output:      output_double,
                    usage:       usage_double,
                    stop_reason: 'end_turn')
  end

  before do
    allow(Legion::Extensions::Bedrock::Helpers::Client)
      .to receive(:bedrock_runtime_client).and_return(runtime_double)
    allow(runtime_double).to receive(:converse).and_return(converse_response)
  end

  describe '#create' do
    it 'returns result, usage, and stop_reason' do
      result = instance.create(
        model_id:          model_id,
        messages:          messages,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )

      expect(result).to have_key(:result)
      expect(result).to have_key(:usage)
      expect(result).to have_key(:stop_reason)
      expect(result[:stop_reason]).to eq('end_turn')
    end

    it 'passes max_tokens in inference_config' do
      allow(runtime_double).to receive(:converse)
        .with(hash_including(inference_config: hash_including(max_tokens: 512)))
        .and_return(converse_response)

      instance.create(
        model_id:          model_id,
        messages:          messages,
        max_tokens:        512,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'passes temperature when provided' do
      allow(runtime_double).to receive(:converse)
        .with(hash_including(inference_config: hash_including(temperature: 0.7)))
        .and_return(converse_response)

      instance.create(
        model_id:          model_id,
        messages:          messages,
        temperature:       0.7,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'wraps system prompt as array of text blocks' do
      allow(runtime_double).to receive(:converse)
        .with(hash_including(system: [{ text: 'You are helpful.' }]))
        .and_return(converse_response)

      instance.create(
        model_id:          model_id,
        messages:          messages,
        system:            'You are helpful.',
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'does not include system key when system is nil' do
      allow(runtime_double).to receive(:converse) do |kwargs|
        expect(kwargs).not_to have_key(:system)
        converse_response
      end

      instance.create(
        model_id:          model_id,
        messages:          messages,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'defaults max_tokens to 1024 when not specified' do
      allow(runtime_double).to receive(:converse)
        .with(hash_including(inference_config: hash_including(max_tokens: 1024)))
        .and_return(converse_response)

      instance.create(
        model_id:          model_id,
        messages:          messages,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'forwards the region to Helpers::Client' do
      expect(Legion::Extensions::Bedrock::Helpers::Client)
        .to receive(:bedrock_runtime_client)
        .with(hash_including(region: 'ap-southeast-1'))
        .and_return(runtime_double)

      instance.create(
        model_id:          model_id,
        messages:          messages,
        region:            'ap-southeast-1',
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'forwards access_key_id and secret_access_key to Helpers::Client' do
      expect(Legion::Extensions::Bedrock::Helpers::Client)
        .to receive(:bedrock_runtime_client)
        .with(hash_including(
                access_key_id:     access_key_id,
                secret_access_key: secret_access_key
              ))
        .and_return(runtime_double)

      instance.create(
        model_id:          model_id,
        messages:          messages,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'returns standardized usage hash from the response' do
      result = instance.create(
        model_id:          model_id,
        messages:          messages,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
      expect(result[:usage]).to eq({
                                     input_tokens:       10,
                                     output_tokens:      20,
                                     cache_read_tokens:  0,
                                     cache_write_tokens: 0
                                   })
    end

    it 'does not include temperature in inference_config when temperature is nil' do
      allow(runtime_double).to receive(:converse) do |kwargs|
        expect(kwargs[:inference_config]).not_to have_key(:temperature)
        converse_response
      end

      instance.create(
        model_id:          model_id,
        messages:          messages,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end
  end
end

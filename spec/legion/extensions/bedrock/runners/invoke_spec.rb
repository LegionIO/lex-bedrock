# frozen_string_literal: true

require 'json'
require 'stringio'

RSpec.describe Legion::Extensions::Bedrock::Runners::Invoke do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:model_id)          { 'anthropic.claude-3-5-sonnet-20241022-v2:0' }
  let(:body)              { { prompt: 'Hello', max_tokens_to_sample: 256 } }

  let(:runtime_double) { instance_double(Aws::BedrockRuntime::Client) }

  let(:test_class) do
    Class.new do
      include Legion::Extensions::Bedrock::Runners::Invoke
    end
  end

  let(:instance) { test_class.new }

  let(:response_body_io) { StringIO.new(JSON.dump({ completion: 'Hello there!' })) }

  let(:invoke_response) do
    instance_double('Aws::BedrockRuntime::Types::InvokeModelResponse',
                    body:         response_body_io,
                    content_type: 'application/json')
  end

  before do
    allow(Legion::Extensions::Bedrock::Helpers::Client)
      .to receive(:bedrock_runtime_client).and_return(runtime_double)
    allow(runtime_double).to receive(:invoke_model).and_return(invoke_response)
  end

  describe '#invoke_model' do
    it 'returns parsed result, content_type, and usage' do
      result = instance.invoke_model(
        model_id:          model_id,
        body:              body,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )

      expect(result).to have_key(:result)
      expect(result).to have_key(:content_type)
      expect(result).to have_key(:usage)
      expect(result[:result]['completion']).to eq('Hello there!')
      expect(result[:content_type]).to eq('application/json')
    end

    it 'returns zero-filled usage when response has no usage key' do
      result = instance.invoke_model(
        model_id:          model_id,
        body:              body,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )

      expect(result[:usage]).to eq({
                                     input_tokens:       0,
                                     output_tokens:      0,
                                     cache_read_tokens:  0,
                                     cache_write_tokens: 0
                                   })
    end

    it 'extracts usage from response body when present' do
      body_with_usage = JSON.dump({
                                    completion: 'Hi',
                                    usage:      { input_tokens: 8, output_tokens: 16 }
                                  })
      response_with_usage = instance_double(
        'Aws::BedrockRuntime::Types::InvokeModelResponse',
        body:         StringIO.new(body_with_usage),
        content_type: 'application/json'
      )
      allow(runtime_double).to receive(:invoke_model).and_return(response_with_usage)

      result = instance.invoke_model(
        model_id:          model_id,
        body:              body,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )

      expect(result[:usage]).to eq({
                                     input_tokens:       8,
                                     output_tokens:      16,
                                     cache_read_tokens:  0,
                                     cache_write_tokens: 0
                                   })
    end

    it 'passes model_id and serialized body to aws invoke_model' do
      allow(runtime_double).to receive(:invoke_model)
        .with(hash_including(
                model_id:     model_id,
                content_type: 'application/json',
                accept:       'application/json'
              )).and_return(invoke_response)

      instance.invoke_model(
        model_id:          model_id,
        body:              body,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'supports custom content_type and accept headers' do
      allow(runtime_double).to receive(:invoke_model)
        .with(hash_including(content_type: 'application/json', accept: '*/*'))
        .and_return(invoke_response)

      instance.invoke_model(
        model_id:          model_id,
        body:              body,
        accept:            '*/*',
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'serializes body hash to JSON string before sending' do
      allow(runtime_double).to receive(:invoke_model) do |kwargs|
        expect(kwargs[:body]).to be_a(String)
        expect(JSON.parse(kwargs[:body])).to eq('prompt' => 'Hello', 'max_tokens_to_sample' => 256)
        invoke_response
      end

      instance.invoke_model(
        model_id:          model_id,
        body:              body,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end

    it 'forwards the region to Helpers::Client' do
      expect(Legion::Extensions::Bedrock::Helpers::Client)
        .to receive(:bedrock_runtime_client)
        .with(hash_including(region: 'us-west-2'))
        .and_return(runtime_double)

      instance.invoke_model(
        model_id:          model_id,
        body:              body,
        region:            'us-west-2',
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

      instance.invoke_model(
        model_id:          model_id,
        body:              body,
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end
  end
end

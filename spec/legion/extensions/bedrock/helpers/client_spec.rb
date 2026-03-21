# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'

RSpec.describe Legion::Extensions::Bedrock::Helpers::Client do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:region)            { 'us-east-2' }

  describe 'DEFAULT_REGION' do
    it 'is us-east-2' do
      expect(described_class::DEFAULT_REGION).to eq('us-east-2')
    end
  end

  describe '.bedrock_client' do
    it 'returns an Aws::Bedrock::Client' do
      client = described_class.bedrock_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            region
      )
      expect(client).to be_a(Aws::Bedrock::Client)
    end

    it 'accepts a custom region' do
      client = described_class.bedrock_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            'us-west-2'
      )
      expect(client.config.region).to eq('us-west-2')
    end

    it 'includes session_token when provided' do
      client = described_class.bedrock_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            region,
        session_token:     'my-session-token'
      )
      expect(client.config.credentials.session_token).to eq('my-session-token')
    end

    it 'uses DEFAULT_REGION when region is not specified' do
      client = described_class.bedrock_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
      expect(client.config.region).to eq(described_class::DEFAULT_REGION)
    end
  end

  describe '.bedrock_runtime_client' do
    it 'returns an Aws::BedrockRuntime::Client' do
      client = described_class.bedrock_runtime_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            region
      )
      expect(client).to be_a(Aws::BedrockRuntime::Client)
    end

    it 'accepts a custom region' do
      client = described_class.bedrock_runtime_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            'eu-west-1'
      )
      expect(client.config.region).to eq('eu-west-1')
    end

    it 'includes session_token when provided' do
      client = described_class.bedrock_runtime_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            region,
        session_token:     'runtime-session-token'
      )
      expect(client.config.credentials.session_token).to eq('runtime-session-token')
    end

    it 'uses DEFAULT_REGION when region is not specified' do
      client = described_class.bedrock_runtime_client(
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
      expect(client.config.region).to eq(described_class::DEFAULT_REGION)
    end
  end
end

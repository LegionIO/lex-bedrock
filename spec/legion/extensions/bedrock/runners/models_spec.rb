# frozen_string_literal: true

RSpec.describe Legion::Extensions::Bedrock::Runners::Models do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:region)            { 'us-east-2' }

  let(:bedrock_double) { instance_double(Aws::Bedrock::Client) }

  let(:test_class) do
    Class.new do
      include Legion::Extensions::Bedrock::Runners::Models
    end
  end

  let(:instance) { test_class.new }

  before do
    allow(Legion::Extensions::Bedrock::Helpers::Client)
      .to receive(:bedrock_client).and_return(bedrock_double)
  end

  describe '#list' do
    let(:model_summary) do
      instance_double(
        'Aws::Bedrock::Types::FoundationModelSummary',
        model_id:   'anthropic.claude-3-5-sonnet-20241022-v2:0',
        model_name: 'Claude 3.5 Sonnet v2'
      )
    end

    let(:list_response) do
      instance_double(
        'Aws::Bedrock::Types::ListFoundationModelsResponse',
        model_summaries: [model_summary]
      )
    end

    it 'returns a hash with models key' do
      allow(bedrock_double).to receive(:list_foundation_models).and_return(list_response)

      result = instance.list(access_key_id: access_key_id, secret_access_key: secret_access_key)

      expect(result).to have_key(:models)
      expect(result[:models].length).to eq(1)
    end

    it 'passes credentials and region to bedrock_client' do
      allow(bedrock_double).to receive(:list_foundation_models).and_return(list_response)

      expect(Legion::Extensions::Bedrock::Helpers::Client).to receive(:bedrock_client)
        .with(hash_including(access_key_id: access_key_id, secret_access_key: secret_access_key,
                             region: 'us-west-2'))
        .and_return(bedrock_double)

      instance.list(access_key_id: access_key_id, secret_access_key: secret_access_key,
                    region: 'us-west-2')
    end
  end

  describe '#get' do
    let(:model_details) do
      instance_double(
        'Aws::Bedrock::Types::FoundationModelDetails',
        model_id:   'anthropic.claude-3-5-sonnet-20241022-v2:0',
        model_name: 'Claude 3.5 Sonnet v2'
      )
    end

    let(:get_response) do
      instance_double(
        'Aws::Bedrock::Types::GetFoundationModelResponse',
        model_details: model_details
      )
    end

    it 'returns a hash with model key' do
      allow(bedrock_double).to receive(:get_foundation_model)
        .with(model_identifier: 'anthropic.claude-3-5-sonnet-20241022-v2:0')
        .and_return(get_response)

      result = instance.get(
        model_id:          'anthropic.claude-3-5-sonnet-20241022-v2:0',
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )

      expect(result).to have_key(:model)
      expect(result[:model].model_id).to eq('anthropic.claude-3-5-sonnet-20241022-v2:0')
    end

    it 'passes credentials and region to bedrock_client' do
      allow(bedrock_double).to receive(:get_foundation_model).and_return(get_response)

      expect(Legion::Extensions::Bedrock::Helpers::Client).to receive(:bedrock_client)
        .with(hash_including(
                access_key_id:     access_key_id,
                secret_access_key: secret_access_key,
                region:            'eu-central-1'
              ))
        .and_return(bedrock_double)

      instance.get(
        model_id:          'anthropic.claude-3-5-sonnet-20241022-v2:0',
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key,
        region:            'eu-central-1'
      )
    end

    it 'calls get_foundation_model with the model_identifier keyword' do
      expect(bedrock_double).to receive(:get_foundation_model)
        .with(model_identifier: 'amazon.titan-text-express-v1')
        .and_return(get_response)

      instance.get(
        model_id:          'amazon.titan-text-express-v1',
        access_key_id:     access_key_id,
        secret_access_key: secret_access_key
      )
    end
  end

  describe '#list' do
    let(:model_summary) do
      instance_double(
        'Aws::Bedrock::Types::FoundationModelSummary',
        model_id:   'amazon.titan-text-express-v1',
        model_name: 'Titan Text Express'
      )
    end

    let(:list_response) do
      instance_double(
        'Aws::Bedrock::Types::ListFoundationModelsResponse',
        model_summaries: [model_summary]
      )
    end

    it 'returns model summaries as an array' do
      allow(bedrock_double).to receive(:list_foundation_models).and_return(list_response)

      result = instance.list(access_key_id: access_key_id, secret_access_key: secret_access_key)

      expect(result[:models]).to be_an(Array)
      expect(result[:models].first.model_name).to eq('Titan Text Express')
    end
  end
end

# frozen_string_literal: true

require 'legion/extensions/bedrock/runners/profiles'

RSpec.describe Legion::Extensions::Bedrock::Runners::Profiles do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }

  let(:bedrock_double) { instance_double(Aws::Bedrock::Client) }

  let(:test_class) do
    Class.new { include Legion::Extensions::Bedrock::Runners::Profiles }
  end

  let(:instance) { test_class.new }

  let(:profile_summary) do
    double('profile_summary',
           inference_profile_id: 'us.anthropic.claude-3-7-sonnet-20250219-v1:0',
           inference_profile_name: 'Claude 3.7 Sonnet US Cross-Region',
           models: [double('model', model_arn: 'arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0')])
  end

  let(:list_response) do
    double('list_response', inference_profile_summaries: [profile_summary])
  end

  before do
    allow(Legion::Extensions::Bedrock::Helpers::Client)
      .to receive(:bedrock_client).and_return(bedrock_double)
    allow(bedrock_double).to receive(:list_inference_profiles).and_return(list_response)
  end

  describe '#list_inference_profiles' do
    it 'returns inference_profiles key' do
      result = instance.list_inference_profiles(access_key_id:, secret_access_key:)
      expect(result).to have_key(:inference_profiles)
    end

    it 'requests SYSTEM_DEFINED profiles by default' do
      expect(bedrock_double).to receive(:list_inference_profiles)
        .with(type_equals: 'SYSTEM_DEFINED')
        .and_return(list_response)

      instance.list_inference_profiles(access_key_id:, secret_access_key:)
    end

    it 'accepts custom profile_type' do
      expect(bedrock_double).to receive(:list_inference_profiles)
        .with(type_equals: 'APPLICATION')
        .and_return(list_response)

      instance.list_inference_profiles(
        access_key_id:, secret_access_key:, profile_type: 'APPLICATION'
      )
    end
  end

  describe '#get_inference_profile' do
    let(:profile_detail) { double('profile_detail', inference_profile_id: 'us.anthropic.claude-3-7-sonnet-20250219-v1:0') }

    before do
      allow(bedrock_double).to receive(:get_inference_profile).and_return(profile_detail)
    end

    it 'returns inference_profile key' do
      result = instance.get_inference_profile(
        profile_id: 'us.anthropic.claude-3-7-sonnet-20250219-v1:0',
        access_key_id:, secret_access_key:
      )
      expect(result).to have_key(:inference_profile)
    end

    it 'calls get_inference_profile with the correct identifier' do
      expect(bedrock_double).to receive(:get_inference_profile)
        .with(inference_profile_identifier: 'us.anthropic.claude-3-7-sonnet-20250219-v1:0')
        .and_return(profile_detail)

      instance.get_inference_profile(
        profile_id: 'us.anthropic.claude-3-7-sonnet-20250219-v1:0',
        access_key_id:, secret_access_key:
      )
    end
  end

  describe '#resolve_profile_id' do
    it 'returns the profile_id when a matching profile exists' do
      result = instance.resolve_profile_id(
        canonical_model_id: 'claude-3-7-sonnet-20250219',
        access_key_id:, secret_access_key:
      )
      expect(result).to eq('us.anthropic.claude-3-7-sonnet-20250219-v1:0')
    end

    it 'returns the canonical_model_id unchanged when no profile matches' do
      result = instance.resolve_profile_id(
        canonical_model_id: 'no-match-model',
        access_key_id:, secret_access_key:
      )
      expect(result).to eq('no-match-model')
    end
  end
end

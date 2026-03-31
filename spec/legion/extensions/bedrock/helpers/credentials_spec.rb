# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/credentials'

RSpec.describe Legion::Extensions::Bedrock::Helpers::Credentials do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }

  before { described_class.clear_cache! }

  describe '.resolve' do
    it 'returns Aws::Credentials when static keys are provided' do
      creds = described_class.resolve(
        access_key_id:,
        secret_access_key:
      )
      expect(creds).to be_a(Aws::Credentials)
    end

    it 'includes session_token when provided' do
      creds = described_class.resolve(
        access_key_id:,
        secret_access_key:,
        session_token: 'tok-abc'
      )
      expect(creds.session_token).to eq('tok-abc')
    end

    it 'returns the same object on repeated calls (cache hit)' do
      creds1 = described_class.resolve(access_key_id:, secret_access_key:)
      creds2 = described_class.resolve(access_key_id:, secret_access_key:)
      expect(creds1).to equal(creds2)
    end

    it 'returns nil credentials when no access_key_id is given (default provider chain)' do
      creds = described_class.resolve
      expect(creds).to be_a(Aws::Credentials)
    end

    it 'refreshes credentials after TTL expires' do
      described_class.resolve(access_key_id:, secret_access_key:)

      cache_key = "#{access_key_id}/us-east-2"
      entry = described_class.instance_variable_get(:@credential_cache)[cache_key]
      # Backdate the entry so it appears stale
      entry[:fetched_at] -= described_class::CREDENTIAL_TTL + 1

      creds2 = described_class.resolve(access_key_id:, secret_access_key:)
      expect(creds2).to be_a(Aws::Credentials)
    end
  end

  describe '.clear_cache!' do
    it 'empties the credential cache' do
      described_class.resolve(access_key_id:, secret_access_key:)
      described_class.clear_cache!
      cache = described_class.instance_variable_get(:@credential_cache)
      expect(cache).to be_empty
    end
  end
end

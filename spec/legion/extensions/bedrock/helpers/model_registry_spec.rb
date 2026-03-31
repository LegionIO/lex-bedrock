# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/model_registry'

RSpec.describe Legion::Extensions::Bedrock::Helpers::ModelRegistry do
  describe '.resolve' do
    it 'maps a canonical name to a Bedrock ID' do
      expect(described_class.resolve('claude-3-7-sonnet-20250219'))
        .to eq('us.anthropic.claude-3-7-sonnet-20250219-v1:0')
    end

    it 'returns an already-qualified Bedrock ID unchanged' do
      bedrock_id = 'us.anthropic.claude-3-7-sonnet-20250219-v1:0'
      expect(described_class.resolve(bedrock_id)).to eq(bedrock_id)
    end

    it 'returns an unknown canonical name unchanged' do
      expect(described_class.resolve('some-future-model')).to eq('some-future-model')
    end

    it 'handles all 11 known models' do
      described_class::MODELS.each_key do |canonical|
        expect(described_class.resolve(canonical)).not_to eq(canonical)
      end
    end
  end

  describe '.known?' do
    it 'returns true for a known canonical name' do
      expect(described_class.known?('claude-sonnet-4-6')).to be true
    end

    it 'returns false for an unknown name' do
      expect(described_class.known?('gpt-4o')).to be false
    end
  end

  describe '.all' do
    it 'returns a hash with at least 11 entries' do
      expect(described_class.all.size).to be >= 11
    end

    it 'returns a copy (not the frozen constant itself)' do
      copy = described_class.all
      expect { copy['new-key'] = 'val' }.not_to raise_error
    end
  end
end

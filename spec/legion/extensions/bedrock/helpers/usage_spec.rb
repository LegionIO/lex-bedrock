# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/usage'

RSpec.describe Legion::Extensions::Bedrock::Helpers::Usage do
  describe '.normalize' do
    it 'converts an SDK usage struct to a plain hash' do
      sdk_usage = double('usage', input_tokens: 10, output_tokens: 20)
      result = described_class.normalize(sdk_usage)

      expect(result).to eq({
                             input_tokens:       10,
                             output_tokens:      20,
                             cache_read_tokens:  0,
                             cache_write_tokens: 0
                           })
    end

    it 'returns zero-filled hash when sdk_usage is nil' do
      expect(described_class.normalize(nil)).to eq(described_class::EMPTY_USAGE)
    end

    it 'defaults nil token counts to 0' do
      sdk_usage = double('usage', input_tokens: nil, output_tokens: nil)
      result = described_class.normalize(sdk_usage)

      expect(result[:input_tokens]).to eq(0)
      expect(result[:output_tokens]).to eq(0)
    end

    it 'always includes cache_read_tokens and cache_write_tokens as 0' do
      sdk_usage = double('usage', input_tokens: 5, output_tokens: 15)
      result = described_class.normalize(sdk_usage)

      expect(result[:cache_read_tokens]).to eq(0)
      expect(result[:cache_write_tokens]).to eq(0)
    end
  end

  describe '.from_json' do
    it 'extracts usage from a parsed JSON hash' do
      parsed = { 'usage' => { 'input_tokens' => 12, 'output_tokens' => 34 } }
      result = described_class.from_json(parsed)

      expect(result).to eq({
                             input_tokens:       12,
                             output_tokens:      34,
                             cache_read_tokens:  0,
                             cache_write_tokens: 0
                           })
    end

    it 'returns zero-filled hash when parsed has no usage key' do
      parsed = { 'completion' => 'Hello' }
      expect(described_class.from_json(parsed)).to eq(described_class::EMPTY_USAGE)
    end

    it 'returns zero-filled hash when parsed is not a Hash' do
      expect(described_class.from_json('string')).to eq(described_class::EMPTY_USAGE)
      expect(described_class.from_json(nil)).to eq(described_class::EMPTY_USAGE)
    end

    it 'defaults missing token keys to 0' do
      parsed = { 'usage' => { 'input_tokens' => 5 } }
      result = described_class.from_json(parsed)

      expect(result[:output_tokens]).to eq(0)
    end
  end
end

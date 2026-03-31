# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/thinking'

RSpec.describe Legion::Extensions::Bedrock::Helpers::Thinking do
  describe '.build_thinking_fields' do
    it 'returns thinking enabled with budget_tokens when provided' do
      fields = described_class.build_thinking_fields(budget_tokens: 2000)
      expect(fields[:thinking]).to eq({ type: 'enabled', budget_tokens: 2000 })
      expect(fields[:anthropic_beta]).to include(described_class::THINKING_BETA)
    end

    it 'returns adaptive thinking when adaptive: true' do
      fields = described_class.build_thinking_fields(adaptive: true)
      expect(fields[:thinking]).to eq({ type: 'adaptive' })
    end

    it 'returns adaptive thinking when budget_tokens is nil' do
      fields = described_class.build_thinking_fields
      expect(fields[:thinking]).to eq({ type: 'adaptive' })
    end

    it 'includes extra_betas in the anthropic_beta array' do
      fields = described_class.build_thinking_fields(
        budget_tokens: 1000,
        extra_betas:   [described_class::CONTEXT_1M_BETA]
      )
      expect(fields[:anthropic_beta]).to include(described_class::CONTEXT_1M_BETA)
    end

    it 'always includes the thinking beta' do
      fields = described_class.build_thinking_fields(budget_tokens: 500)
      expect(fields[:anthropic_beta]).to include(described_class::THINKING_BETA)
    end
  end

  describe '.sanitize_inference_config' do
    it 'removes temperature when thinking is enabled' do
      config = { max_tokens: 1024, temperature: 0.7 }
      result = described_class.sanitize_inference_config(
        inference_config: config, thinking_enabled: true
      )
      expect(result).not_to have_key(:temperature)
      expect(result[:max_tokens]).to eq(1024)
    end

    it 'leaves inference_config unchanged when thinking is disabled' do
      config = { max_tokens: 512, temperature: 0.5 }
      result = described_class.sanitize_inference_config(
        inference_config: config, thinking_enabled: false
      )
      expect(result).to eq(config)
    end
  end
end

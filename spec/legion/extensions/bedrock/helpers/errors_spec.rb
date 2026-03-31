# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/errors'

RSpec.describe Legion::Extensions::Bedrock::Helpers::Errors do
  describe '.throttling_error?' do
    it 'returns true for ThrottlingException' do
      err = instance_double(
        'Aws::BedrockRuntime::Errors::ThrottlingException',
        class: Aws::BedrockRuntime::Errors::ThrottlingException
      )
      allow(err.class).to receive(:name)
        .and_return('Aws::BedrockRuntime::Errors::ThrottlingException')
      expect(described_class.throttling_error?(err)).to be true
    end

    it 'returns false for AccessDeniedException' do
      err = instance_double(
        'Aws::BedrockRuntime::Errors::AccessDeniedException',
        class: Aws::BedrockRuntime::Errors::AccessDeniedException
      )
      allow(err.class).to receive(:name)
        .and_return('Aws::BedrockRuntime::Errors::AccessDeniedException')
      expect(described_class.throttling_error?(err)).to be false
    end
  end

  describe '.access_error?' do
    it 'returns true for AccessDeniedException' do
      err = double('err')
      allow(err.class).to receive(:name)
        .and_return('Aws::BedrockRuntime::Errors::AccessDeniedException')
      expect(described_class.access_error?(err)).to be true
    end
  end

  describe '.retryable?' do
    it 'returns true for throttling errors' do
      err = double('err')
      allow(err.class).to receive(:name)
        .and_return('Aws::BedrockRuntime::Errors::ThrottlingException')
      expect(described_class.retryable?(err)).to be true
    end

    it 'returns false for access errors' do
      err = double('err')
      allow(err.class).to receive(:name)
        .and_return('Aws::BedrockRuntime::Errors::AccessDeniedException')
      expect(described_class.retryable?(err)).to be false
    end
  end

  describe '.with_retry' do
    it 'returns the block result on success' do
      result = described_class.with_retry { 42 }
      expect(result).to eq(42)
    end

    it 're-raises non-retryable errors immediately' do
      err = RuntimeError.new('permanent failure')
      expect { described_class.with_retry { raise err } }.to raise_error(RuntimeError)
    end

    it 'retries on throttling and eventually re-raises after max attempts' do
      call_count = 0
      throttle_err = Aws::BedrockRuntime::Errors::ThrottlingException.new(
        double('ctx'), 'throttled'
      )
      allow(described_class).to receive(:sleep)

      expect do
        described_class.with_retry(max_retries: 2) do
          call_count += 1
          raise throttle_err
        end
      end.to raise_error(Aws::BedrockRuntime::Errors::ThrottlingException)

      expect(call_count).to eq(3) # 1 initial + 2 retries
    end

    it 'succeeds on retry after transient throttle' do
      attempt = 0
      throttle_err = Aws::BedrockRuntime::Errors::ThrottlingException.new(
        double('ctx'), 'throttled'
      )
      allow(described_class).to receive(:sleep)

      result = described_class.with_retry(max_retries: 2) do
        attempt += 1
        raise throttle_err if attempt == 1

        'ok'
      end

      expect(result).to eq('ok')
      expect(attempt).to eq(2)
    end
  end
end

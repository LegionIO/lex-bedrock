# frozen_string_literal: true

require 'legion/extensions/bedrock/client'

RSpec.describe Legion::Extensions::Bedrock::Client do
  let(:access_key_id)     { 'AKIAIOSFODNN7EXAMPLE' }
  let(:secret_access_key) { 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' }
  let(:client) do
    described_class.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
  end

  it 'stores config on initialization' do
    expect(client.config[:access_key_id]).to eq(access_key_id)
    expect(client.config[:secret_access_key]).to eq(secret_access_key)
    expect(client.config[:region]).to eq(Legion::Extensions::Bedrock::Helpers::Client::DEFAULT_REGION)
  end

  it 'stores a custom region when provided' do
    c = described_class.new(access_key_id: access_key_id, secret_access_key: secret_access_key,
                            region: 'us-west-2')
    expect(c.config[:region]).to eq('us-west-2')
  end

  it 'responds to models runner methods' do
    expect(client).to respond_to(:list)
    expect(client).to respond_to(:get)
  end

  it 'responds to converse runner methods' do
    expect(client).to respond_to(:create)
  end

  it 'responds to invoke runner methods' do
    expect(client).to respond_to(:invoke_model)
  end
end

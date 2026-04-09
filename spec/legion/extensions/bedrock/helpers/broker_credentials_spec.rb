# frozen_string_literal: true

RSpec.describe Legion::Extensions::Bedrock::Helpers::Client do
  describe 'Broker credential resolution' do
    let(:broker_creds) { Aws::Credentials.new('AKIA_BROKER', 'secret_broker', 'session_broker') }
    let(:broker_provider) { double('provider', current_credentials: broker_creds) }
    let(:broker_renewer) { double('renewer', provider: broker_provider) }

    context 'when Broker has AWS credentials and no explicit creds given' do
      before do
        renewer = broker_renewer
        broker = Module.new
        broker.define_singleton_method(:renewer_for) { |name| name == :aws ? renewer : nil }
        stub_const('Legion::Identity::Broker', broker)
      end

      it 'uses Broker credentials for runtime client' do
        client = described_class.bedrock_runtime_client(region: 'us-east-2')
        expect(client.config.credentials.access_key_id).to eq('AKIA_BROKER')
      end

      it 'uses Broker credentials for management client' do
        client = described_class.bedrock_client(region: 'us-east-2')
        expect(client.config.credentials.access_key_id).to eq('AKIA_BROKER')
      end
    end

    context 'when explicit access_key_id is provided' do
      before do
        renewer = broker_renewer
        broker = Module.new
        broker.define_singleton_method(:renewer_for) { |name| name == :aws ? renewer : nil }
        stub_const('Legion::Identity::Broker', broker)
      end

      it 'prefers explicit credentials over Broker' do
        client = described_class.bedrock_runtime_client(
          access_key_id: 'AKIA_EXPLICIT', secret_access_key: 'secret_explicit', region: 'us-east-2'
        )
        expect(client.config.credentials.access_key_id).to eq('AKIA_EXPLICIT')
      end
    end

    context 'when credentials: kwarg is provided' do
      before do
        renewer = broker_renewer
        broker = Module.new
        broker.define_singleton_method(:renewer_for) { |name| name == :aws ? renewer : nil }
        stub_const('Legion::Identity::Broker', broker)
      end

      it 'prefers credentials: kwarg over everything' do
        explicit = Aws::Credentials.new('AKIA_KWARG', 'secret_kwarg')
        client = described_class.bedrock_runtime_client(credentials: explicit, region: 'us-east-2')
        expect(client.config.credentials.access_key_id).to eq('AKIA_KWARG')
      end
    end

    context 'when Broker is not defined' do
      before { hide_const('Legion::Identity::Broker') }

      it 'falls back to SDK default chain' do
        client = described_class.bedrock_runtime_client(region: 'us-east-2')
        # SDK resolves from env/profile/instance — credentials will be some object
        expect(client).to be_a(Aws::BedrockRuntime::Client)
      end
    end

    context 'when Broker raises an error' do
      before do
        broker = Module.new
        broker.define_singleton_method(:renewer_for) { |_| raise StandardError, 'broken' }
        stub_const('Legion::Identity::Broker', broker)
      end

      it 'falls through gracefully' do
        client = described_class.bedrock_runtime_client(
          access_key_id: 'AKIA_FALLBACK', secret_access_key: 'secret', region: 'us-east-2'
        )
        expect(client.config.credentials.access_key_id).to eq('AKIA_FALLBACK')
      end
    end
  end
end

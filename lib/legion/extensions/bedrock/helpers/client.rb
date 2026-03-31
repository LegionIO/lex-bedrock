# frozen_string_literal: true

require 'aws-sdk-bedrock'
require 'aws-sdk-bedrockruntime'

module Legion
  module Extensions
    module Bedrock
      module Helpers
        module Client
          DEFAULT_REGION = 'us-east-2'

          module_function

          def bedrock_runtime_client(access_key_id: nil, secret_access_key: nil,
                                     region: DEFAULT_REGION, session_token: nil,
                                     credentials: nil, **)
            Aws::BedrockRuntime::Client.new(
              region:,
              credentials: credentials || build_credentials(access_key_id:, secret_access_key:,
                                                            session_token:)
            )
          end

          def bedrock_client(access_key_id: nil, secret_access_key: nil,
                             region: DEFAULT_REGION, session_token: nil,
                             credentials: nil, **)
            Aws::Bedrock::Client.new(
              region:,
              credentials: credentials || build_credentials(access_key_id:, secret_access_key:,
                                                            session_token:)
            )
          end

          def region_for_model(model_id:, region: nil)
            return region if region

            env_key = "BEDROCK_REGION_#{model_id.upcase.gsub(/[^A-Z0-9]/, '_')}"
            env_val = ENV.fetch(env_key, nil)
            return env_val if env_val

            settings_region = begin
              Legion::Settings[:bedrock]&.dig(:model_regions, model_id.to_sym)
            rescue StandardError
              nil
            end

            settings_region || DEFAULT_REGION
          end

          def build_credentials(access_key_id:, secret_access_key:, session_token:)
            return nil if access_key_id.nil?

            if session_token
              Aws::Credentials.new(access_key_id, secret_access_key, session_token)
            else
              Aws::Credentials.new(access_key_id, secret_access_key)
            end
          end

          private_class_method :build_credentials
        end
      end
    end
  end
end

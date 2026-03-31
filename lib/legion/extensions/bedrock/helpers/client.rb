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

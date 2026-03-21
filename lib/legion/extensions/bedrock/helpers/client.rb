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

          def bedrock_runtime_client(access_key_id:, secret_access_key:, region: DEFAULT_REGION,
                                     session_token: nil, **)
            opts = {
              access_key_id:     access_key_id,
              secret_access_key: secret_access_key,
              region:            region
            }
            opts[:session_token] = session_token if session_token

            Aws::BedrockRuntime::Client.new(**opts)
          end

          def bedrock_client(access_key_id:, secret_access_key:, region: DEFAULT_REGION,
                             session_token: nil, **)
            opts = {
              access_key_id:     access_key_id,
              secret_access_key: secret_access_key,
              region:            region
            }
            opts[:session_token] = session_token if session_token

            Aws::Bedrock::Client.new(**opts)
          end
        end
      end
    end
  end
end

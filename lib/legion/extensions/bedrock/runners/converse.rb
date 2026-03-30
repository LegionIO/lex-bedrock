# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Converse
          def create(model_id:, messages:, access_key_id:, secret_access_key:, # rubocop:disable Metrics/ParameterLists
                     system: nil, max_tokens: 1024, temperature: nil,
                     region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_runtime_client(
              access_key_id:     access_key_id,
              secret_access_key: secret_access_key,
              region:            region
            )

            inference_config = { max_tokens: max_tokens }
            inference_config[:temperature] = temperature if temperature

            request = {
              model_id:         model_id,
              messages:         messages,
              inference_config: inference_config
            }
            request[:system] = [{ text: system }] if system

            response = client.converse(**request)
            {
              result:      response.output,
              usage:       response.usage,
              stop_reason: response.stop_reason
            }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end

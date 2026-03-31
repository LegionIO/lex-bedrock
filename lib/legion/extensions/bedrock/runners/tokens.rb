# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/helpers/errors'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Tokens
          def count_tokens(model_id:, messages:, access_key_id:, secret_access_key:, # rubocop:disable Metrics/ParameterLists
                           system: nil, tools: nil, anthropic_version: 'bedrock-2023-05-31',
                           anthropic_beta: nil, thinking: nil,
                           region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_runtime_client(
              access_key_id:,
              secret_access_key:,
              region:
            )

            request = build_count_tokens_request(
              model_id:, messages:, system:, tools:,
              anthropic_version:, anthropic_beta:, thinking:
            )

            response = Helpers::Errors.with_retry { client.count_tokens(**request) }
            {
              input_token_count: response.input_tokens
            }
          end

          private

          def build_count_tokens_request(model_id:, messages:, system:, tools:,
                                         anthropic_version:, anthropic_beta:, thinking:)
            body_fields = { anthropic_version: }
            body_fields[:anthropic_beta] = anthropic_beta if anthropic_beta
            body_fields[:thinking]       = thinking if thinking

            request = {
              model_id:,
              messages:,
              system:                          system ? [{ text: system }] : nil,
              additional_model_request_fields: body_fields
            }
            request[:tools] = tools if tools
            request.compact
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end

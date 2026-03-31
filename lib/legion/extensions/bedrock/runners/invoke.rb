# frozen_string_literal: true

require 'json'
require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/helpers/errors'
require 'legion/extensions/bedrock/helpers/usage'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Invoke
          def invoke_model(model_id:, body:, access_key_id:, secret_access_key:,
                           content_type: 'application/json', accept: 'application/json',
                           region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_runtime_client(
              access_key_id:,
              secret_access_key:,
              region:
            )

            response = Helpers::Errors.with_retry do
              client.invoke_model(
                model_id:,
                body:         ::JSON.dump(body),
                content_type:,
                accept:
              )
            end

            parsed = ::JSON.parse(response.body.read)
            {
              result:       parsed,
              content_type: response.content_type,
              usage:        Helpers::Usage.from_json(parsed)
            }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end

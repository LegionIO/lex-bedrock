# frozen_string_literal: true

require 'json'
require 'legion/extensions/bedrock/helpers/client'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Invoke
          def invoke_model(model_id:, body:, access_key_id:, secret_access_key:,
                           content_type: 'application/json', accept: 'application/json',
                           region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_runtime_client(
              access_key_id:     access_key_id,
              secret_access_key: secret_access_key,
              region:            region
            )

            response = client.invoke_model(
              model_id:     model_id,
              body:         ::JSON.dump(body),
              content_type: content_type,
              accept:       accept
            )

            {
              result:       ::JSON.parse(response.body.read),
              content_type: response.content_type
            }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end

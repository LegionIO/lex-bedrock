# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Models
          def list(access_key_id:, secret_access_key:, region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_client(
              access_key_id:     access_key_id,
              secret_access_key: secret_access_key,
              region:            region
            )
            response = client.list_foundation_models
            { models: response.model_summaries }
          end

          def get(model_id:, access_key_id:, secret_access_key:, region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_client(
              access_key_id:     access_key_id,
              secret_access_key: secret_access_key,
              region:            region
            )
            response = client.get_foundation_model(model_identifier: model_id)
            { model: response.model_details }
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)
        end
      end
    end
  end
end

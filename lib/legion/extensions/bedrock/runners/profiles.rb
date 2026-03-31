# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/helpers/errors'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Profiles
          def list_inference_profiles(access_key_id:, secret_access_key:,
                                      profile_type: 'SYSTEM_DEFINED',
                                      region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_client(
              access_key_id:,
              secret_access_key:,
              region:
            )

            response = Helpers::Errors.with_retry do
              client.list_inference_profiles(type_equals: profile_type)
            end

            { inference_profiles: response.inference_profile_summaries }
          end

          def get_inference_profile(profile_id:, access_key_id:, secret_access_key:,
                                    region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_client(
              access_key_id:,
              secret_access_key:,
              region:
            )

            response = Helpers::Errors.with_retry do
              client.get_inference_profile(inference_profile_identifier: profile_id)
            end

            { inference_profile: response }
          end

          def resolve_profile_id(canonical_model_id:, access_key_id:, secret_access_key:,
                                 region: Helpers::Client::DEFAULT_REGION, **)
            result = list_inference_profiles(
              access_key_id:, secret_access_key:, region:
            )
            profiles = result[:inference_profiles]

            matched = profiles.find do |p|
              p.respond_to?(:models) &&
                Array(p.models).any? { |m| m.model_arn.to_s.include?(canonical_model_id) }
            end

            matched ? matched.inference_profile_id : canonical_model_id
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end

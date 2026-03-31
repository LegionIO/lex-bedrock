# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/runners/models'
require 'legion/extensions/bedrock/runners/converse'
require 'legion/extensions/bedrock/runners/invoke'
require 'legion/extensions/bedrock/runners/tokens'
require 'legion/extensions/bedrock/runners/profiles'

module Legion
  module Extensions
    module Bedrock
      class Client
        include Legion::Extensions::Bedrock::Runners::Models
        include Legion::Extensions::Bedrock::Runners::Converse
        include Legion::Extensions::Bedrock::Runners::Invoke
        include Legion::Extensions::Bedrock::Runners::Tokens
        include Legion::Extensions::Bedrock::Runners::Profiles

        attr_reader :config

        def initialize(access_key_id:, secret_access_key:, region: Helpers::Client::DEFAULT_REGION, **opts)
          @config = { access_key_id: access_key_id, secret_access_key: secret_access_key,
                      region: region, **opts }
        end
      end
    end
  end
end

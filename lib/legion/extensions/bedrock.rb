# frozen_string_literal: true

require 'legion/extensions/bedrock/version'
require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/helpers/errors'
require 'legion/extensions/bedrock/helpers/credentials'
require 'legion/extensions/bedrock/helpers/thinking'
require 'legion/extensions/bedrock/helpers/model_registry'
require 'legion/extensions/bedrock/runners/models'
require 'legion/extensions/bedrock/runners/converse'
require 'legion/extensions/bedrock/runners/invoke'
require 'legion/extensions/bedrock/runners/tokens'
require 'legion/extensions/bedrock/runners/profiles'

module Legion
  module Extensions
    module Bedrock
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core, false
    end
  end
end

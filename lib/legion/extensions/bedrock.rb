# frozen_string_literal: true

require 'legion/extensions/bedrock/version'
require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/runners/models'
require 'legion/extensions/bedrock/runners/converse'
require 'legion/extensions/bedrock/runners/invoke'

module Legion
  module Extensions
    module Bedrock
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core, false
    end
  end
end

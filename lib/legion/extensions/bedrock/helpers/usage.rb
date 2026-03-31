# frozen_string_literal: true

module Legion
  module Extensions
    module Bedrock
      module Helpers
        module Usage
          EMPTY_USAGE = {
            input_tokens:       0,
            output_tokens:      0,
            cache_read_tokens:  0,
            cache_write_tokens: 0
          }.freeze

          module_function

          def normalize(sdk_usage)
            return EMPTY_USAGE.dup unless sdk_usage

            {
              input_tokens:       sdk_usage.input_tokens || 0,
              output_tokens:      sdk_usage.output_tokens || 0,
              cache_read_tokens:  0,
              cache_write_tokens: 0
            }
          end

          def from_json(parsed)
            return EMPTY_USAGE.dup unless parsed.is_a?(Hash)

            usage = parsed['usage'] || {}
            {
              input_tokens:       usage['input_tokens'] || 0,
              output_tokens:      usage['output_tokens'] || 0,
              cache_read_tokens:  0,
              cache_write_tokens: 0
            }
          end
        end
      end
    end
  end
end

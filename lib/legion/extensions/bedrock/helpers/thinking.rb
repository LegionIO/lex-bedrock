# frozen_string_literal: true

module Legion
  module Extensions
    module Bedrock
      module Helpers
        module Thinking
          THINKING_BETA       = 'interleaved-thinking-2025-05-14'
          CONTEXT_1M_BETA     = 'context-1m-2025-08-07'
          TOOL_SEARCH_BETA    = 'tool-search-tool-2025-10-19'

          module_function

          def build_thinking_fields(budget_tokens: nil, adaptive: false, extra_betas: [])
            betas   = [THINKING_BETA] + Array(extra_betas)
            fields  = { anthropic_beta: betas }

            thinking = if adaptive || budget_tokens.nil?
                         { type: 'adaptive' }
                       else
                         { type: 'enabled', budget_tokens: }
                       end

            fields[:thinking] = thinking
            fields
          end

          def sanitize_inference_config(inference_config:, thinking_enabled:)
            return inference_config unless thinking_enabled

            inference_config.reject { |k, _| k == :temperature }
          end
        end
      end
    end
  end
end

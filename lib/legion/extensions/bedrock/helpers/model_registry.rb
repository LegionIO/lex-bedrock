# frozen_string_literal: true

module Legion
  module Extensions
    module Bedrock
      module Helpers
        module ModelRegistry
          # Maps canonical model names to their AWS Bedrock cross-region inference profile IDs.
          # Use the us.* cross-region IDs for best availability.
          MODELS = {
            'claude-3-5-haiku-20241022'  => 'us.anthropic.claude-3-5-haiku-20241022-v1:0',
            'claude-haiku-4-5-20251001'  => 'us.anthropic.claude-haiku-4-5-20251001-v1:0',
            'claude-3-5-sonnet-20241022' => 'anthropic.claude-3-5-sonnet-20241022-v2:0',
            'claude-3-7-sonnet-20250219' => 'us.anthropic.claude-3-7-sonnet-20250219-v1:0',
            'claude-sonnet-4-20250514'   => 'us.anthropic.claude-sonnet-4-20250514-v1:0',
            'claude-sonnet-4-5-20250929' => 'us.anthropic.claude-sonnet-4-5-20250929-v1:0',
            'claude-sonnet-4-6'          => 'us.anthropic.claude-sonnet-4-6',
            'claude-opus-4-20250514'     => 'us.anthropic.claude-opus-4-20250514-v1:0',
            'claude-opus-4-1-20250805'   => 'us.anthropic.claude-opus-4-1-20250805-v1:0',
            'claude-opus-4-5-20251101'   => 'us.anthropic.claude-opus-4-5-20251101-v1:0',
            'claude-opus-4-6'            => 'us.anthropic.claude-opus-4-6-v1'
          }.freeze

          module_function

          def resolve(model_id)
            return model_id if bedrock_id?(model_id)

            MODELS.fetch(model_id, model_id)
          end

          def known?(model_id)
            MODELS.key?(model_id)
          end

          def all
            MODELS.dup
          end

          def bedrock_id?(model_id)
            model_id.include?('.') || model_id.include?(':')
          end
        end
      end
    end
  end
end

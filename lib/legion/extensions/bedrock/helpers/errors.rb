# frozen_string_literal: true

module Legion
  module Extensions
    module Bedrock
      module Helpers
        module Errors
          THROTTLING_ERRORS = %w[
            Aws::BedrockRuntime::Errors::ThrottlingException
            Aws::BedrockRuntime::Errors::ServiceUnavailableException
            Aws::Bedrock::Errors::ThrottlingException
            Aws::Bedrock::Errors::ServiceUnavailableException
          ].freeze

          ACCESS_ERRORS = %w[
            Aws::BedrockRuntime::Errors::AccessDeniedException
            Aws::Bedrock::Errors::AccessDeniedException
          ].freeze

          MODEL_ERRORS = %w[
            Aws::BedrockRuntime::Errors::ModelNotReadyException
            Aws::BedrockRuntime::Errors::ModelTimeoutException
            Aws::BedrockRuntime::Errors::ModelErrorException
          ].freeze

          MAX_RETRIES   = 3
          BASE_DELAY    = 0.5  # seconds
          MAX_DELAY     = 16.0 # seconds

          module_function

          def throttling_error?(exception)
            THROTTLING_ERRORS.include?(exception.class.name)
          end

          def access_error?(exception)
            ACCESS_ERRORS.include?(exception.class.name)
          end

          def model_error?(exception)
            MODEL_ERRORS.include?(exception.class.name)
          end

          def retryable?(exception)
            throttling_error?(exception)
          end

          def with_retry(max_retries: MAX_RETRIES)
            attempts = 0
            begin
              yield
            rescue StandardError => e
              attempts += 1
              raise unless retryable?(e) && attempts <= max_retries

              delay = [BASE_DELAY * (2**(attempts - 1)), MAX_DELAY].min
              sleep(delay)
              retry
            end
          end
        end
      end
    end
  end
end

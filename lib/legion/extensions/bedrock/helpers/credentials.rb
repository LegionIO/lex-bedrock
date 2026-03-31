# frozen_string_literal: true

module Legion
  module Extensions
    module Bedrock
      module Helpers
        module Credentials
          CREDENTIAL_TTL = 3000 # seconds — refresh before the typical 1-hour STS TTL

          @credential_cache = {}
          @cache_mutex      = ::Mutex.new

          module_function

          def resolve(access_key_id: nil, secret_access_key: nil,
                      session_token: nil, region: 'us-east-2', **)
            return default_credentials if access_key_id.nil?

            cache_key = "#{access_key_id}/#{region}"
            @cache_mutex.synchronize do
              entry = @credential_cache[cache_key]
              if entry.nil? || stale?(entry)
                @credential_cache[cache_key] = {
                  credentials: build_static(
                    access_key_id:,
                    secret_access_key:,
                    session_token:
                  ),
                  fetched_at: ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
                }
              end
              @credential_cache[cache_key][:credentials]
            end
          end

          def clear_cache!
            @cache_mutex.synchronize { @credential_cache.clear }
          end

          def default_credentials
            Aws::Credentials.new(nil, nil) # triggers SDK default chain
          end

          def build_static(access_key_id:, secret_access_key:, session_token:)
            if session_token
              Aws::Credentials.new(access_key_id, secret_access_key, session_token)
            else
              Aws::Credentials.new(access_key_id, secret_access_key)
            end
          end

          def stale?(entry)
            elapsed = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - entry[:fetched_at]
            elapsed >= CREDENTIAL_TTL
          end

          private_class_method :default_credentials, :build_static, :stale?
        end
      end
    end
  end
end

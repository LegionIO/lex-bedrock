# frozen_string_literal: true

require 'legion/extensions/bedrock/helpers/client'
require 'legion/extensions/bedrock/helpers/errors'
require 'legion/extensions/bedrock/helpers/thinking'

module Legion
  module Extensions
    module Bedrock
      module Runners
        module Converse
          def create(model_id:, messages:, access_key_id:, secret_access_key:, # rubocop:disable Metrics/ParameterLists
                     system: nil, max_tokens: 1024, temperature: nil,
                     top_p: nil, top_k: nil, stop_sequences: nil,
                     tool_config: nil, guardrail_config: nil,
                     additional_model_request_fields: nil,
                     region: Helpers::Client::DEFAULT_REGION, **)
            client = Helpers::Client.bedrock_runtime_client(
              access_key_id:,
              secret_access_key:,
              region:
            )

            request = build_converse_request(
              model_id:, messages:, system:, max_tokens:, temperature:,
              top_p:, top_k:, stop_sequences:, tool_config:,
              guardrail_config:, additional_model_request_fields:
            )

            response = Helpers::Errors.with_retry { client.converse(**request) }
            {
              result:      response.output,
              usage:       response.usage,
              stop_reason: response.stop_reason
            }
          end

          def create_stream(model_id:, messages:, access_key_id:, secret_access_key:, # rubocop:disable Metrics/ParameterLists
                            system: nil, max_tokens: 1024, temperature: nil,
                            top_p: nil, top_k: nil, stop_sequences: nil,
                            tool_config: nil, guardrail_config: nil,
                            additional_model_request_fields: nil,
                            region: Helpers::Client::DEFAULT_REGION, **,
                            &block)
            client = Helpers::Client.bedrock_runtime_client(
              access_key_id:,
              secret_access_key:,
              region:
            )

            request = build_converse_request(
              model_id:, messages:, system:, max_tokens:, temperature:,
              top_p:, top_k:, stop_sequences:, tool_config:,
              guardrail_config:, additional_model_request_fields:
            )

            accumulated_text = +''
            final_usage      = nil
            final_stop       = nil

            Helpers::Errors.with_retry do
              client.converse_stream(**request) do |stream|
                stream.on_content_block_delta_event do |event|
                  delta = event.delta
                  text  = delta.respond_to?(:text) ? delta.text : nil
                  next if text.nil?

                  accumulated_text << text
                  block&.call(type: :delta, text:)
                end

                stream.on_message_stop_event do |event|
                  final_stop = event.stop_reason
                  block&.call(type: :stop, stop_reason: final_stop)
                end

                stream.on_metadata_event do |event|
                  final_usage = event.usage
                  block&.call(type: :usage, usage: final_usage)
                end
              end
            end

            {
              result:      accumulated_text,
              usage:       final_usage,
              stop_reason: final_stop
            }
          end

          def create_with_thinking(model_id:, messages:, access_key_id:, secret_access_key:, # rubocop:disable Metrics/ParameterLists
                                   budget_tokens: nil, adaptive: false, extra_betas: [],
                                   system: nil, max_tokens: 16_000,
                                   region: Helpers::Client::DEFAULT_REGION, **opts)
            thinking_fields = Helpers::Thinking.build_thinking_fields(
              budget_tokens:, adaptive:, extra_betas:
            )

            # Merge with any caller-supplied additional_model_request_fields
            amrf = opts.delete(:additional_model_request_fields) || {}
            merged_amrf = thinking_fields.merge(amrf) do |_key, thinking_val, caller_val|
              thinking_val.is_a?(Array) ? thinking_val | Array(caller_val) : caller_val
            end

            create(
              model_id:, messages:, access_key_id:, secret_access_key:,
              system:, max_tokens:, region:,
              additional_model_request_fields: merged_amrf,
              **opts
            )
          end

          private

          def build_converse_request(model_id:, messages:, system:, max_tokens:, # rubocop:disable Metrics/ParameterLists
                                     temperature:, top_p:, top_k:, stop_sequences:,
                                     tool_config:, guardrail_config:,
                                     additional_model_request_fields:)
            inference_config = { max_tokens: }
            inference_config[:temperature]    = temperature    if temperature
            inference_config[:top_p]          = top_p          if top_p
            inference_config[:stop_sequences] = stop_sequences if stop_sequences

            request = {
              model_id:,
              messages:,
              inference_config:
            }
            request[:system]                            = [{ text: system }] if system
            request[:tool_config]                       = tool_config                  if tool_config
            request[:guardrail_config]                  = guardrail_config             if guardrail_config
            request[:additional_model_request_fields]   = additional_model_request_fields \
              if additional_model_request_fields

            # top_k goes in additional_model_request_fields for Anthropic models
            if top_k
              request[:additional_model_request_fields] ||= {}
              request[:additional_model_request_fields][:top_k] = top_k
            end

            request
          end

          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex, false)
        end
      end
    end
  end
end

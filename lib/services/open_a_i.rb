# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'openai'
require 'json'

require_relative '../config'

module WordSmith
  module Services
    class OpenAI
      class << self
        extend T::Sig

        # Storage methods

        OPEN_AI_API_KEY_FILE = File.join(File.dirname(__FILE__), '../../', '.openai_api_key')
        OPEN_AI_ORG_ID_FILE = File.join(File.dirname(__FILE__), '../../', '.openai_org_id')

        sig { params(key: String).void }
        def store_api_key(key)
          File.write(OPEN_AI_API_KEY_FILE, key)
        end

        sig { returns(T.nilable(String)) }
        def api_key
          return nil unless File.exist?(OPEN_AI_API_KEY_FILE)

          File.read(OPEN_AI_API_KEY_FILE)
        end

        sig { params(key: String).void }
        def store_org_id(key)
          File.write(OPEN_AI_ORG_ID_FILE, key)
        end

        sig { returns(T.nilable(String)) }
        def org_id
          return nil unless File.exist?(OPEN_AI_ORG_ID_FILE)

          File.read(OPEN_AI_ORG_ID_FILE)
        end
      end

      extend T::Sig

      class OpenAIKeyNotSetError < StandardError; end
      class OpenAIOrgIDNotSetError < StandardError; end

      def initialize
        raise OpenAIKeyNotSetError if OpenAI.api_key.nil?
        raise OpenAIOrgIDNotSetError if OpenAI.org_id.nil?

        ::OpenAI.configure do |config|
          config.access_token = OpenAI.api_key
          config.organization_id = OpenAI.org_id
          config.log_errors = Config::DEBUG_MODE
        end

        @client = ::OpenAI::Client.new
      end

      sig do
        params(text: String).returns({ word: String, pronunciation: String, meaning: String, example: String })
      end
      def translate(text)
        response = @client.chat(
          parameters: {
            model: 'gpt-4o-mini',
            response_format: { type: 'json_schema',
                               json_schema: {
                                 name: 'Translation',
                                 strict: true,
                                 schema: {
                                   type: 'object',
                                   properties: {
                                     word: { type: 'string' },
                                     pronunciation: { type: 'string' },
                                     meaning: { type: 'string' },
                                     example: { type: 'string' }
                                   },
                                   additionalProperties: false,
                                   required: %w[word pronunciation meaning example]
                                 }
                               } },
            messages: [
              {
                role: 'system', content: Helpers::Str.lstr_every_line("
            You are a great translator. Give the user the meaning of the word in English.
            Also give the user an example of the sentence using the word.
            Do not hallucinate.
            Be to the point and concise without an
            ")
              },
              {
                role: 'user', content: text
              }
            ],
            temperature: 0.7
          }
        )

        JSON.parse(response.dig('choices', 0, 'message', 'content'), { symbolize_names: true })
      end

      sig do
        params(sentence: String,
               word: String).returns({ word: String, pronunciation: String, meaning: String, example: String })
      end
      def translate_in_context_of_sentence(sentence, word)
        response = @client.chat(
          parameters: {
            model: 'gpt-4o-mini',
            response_format: { type: 'json_schema',
                               json_schema: {
                                 name: 'Translation',
                                 strict: true,
                                 schema: {
                                   type: 'object',
                                   properties: {
                                     word: { type: 'string' },
                                     pronunciation: { type: 'string' },
                                     meaning: { type: 'string' },
                                     example: { type: 'string' }
                                   },
                                   additionalProperties: false,
                                   required: %w[word pronunciation meaning example]
                                 }
                               } },
            messages: [
              {
                role: 'system', content: Helpers::Str.lstr_every_line("
            You are a great translator. Give the user the meaning of the word in context of the sentence in English.
            Also give the user an example of the sentence using the meaning of the word in that context.
            Do not hallucinate.
            Be to the point and concise without an
            ")
              },
              {
                role: 'user', content: Helpers::Str.lstr_every_line("
                Sentence: #{sentence}
                Word: #{word}
                ")
              }
            ],
            temperature: 0.7
          }
        )

        JSON.parse(response.dig('choices', 0, 'message', 'content'), { symbolize_names: true })
      end
    end
  end
end

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

      sig { params(text: String).void }
      def translate(text)
        response = @client.chat(
          parameters: {
            model: 'gpt-4o-mini',
            messages: [
              {
                role: 'system', content: Helpers::Str.lstr_every_line("
            You are a great translator. Give the user the meaning of the word in English.
            Also give the user an example of the sentence using the word.
            Give me the result in the following format:
            <word>, <pronunciation>: <new_line>
            <meaning>
            - <example> -> <example meaning>
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

        puts response.dig('choices', 0, 'message', 'content')
      end
    end
  end
end

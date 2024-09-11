# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
module WordSmith
  class OpenAI
    extend T::Sig

    OPEN_AI_API_KEY_FILE = '.openai_api_key'

    sig { params(key: String).void }
    def self.store_api_key(key)
      File.write(OPEN_AI_API_KEY_FILE, key)
    end

    sig { returns(T.nilable(String)) }
    def self.api_key
      return nil unless File.exist?(OPEN_AI_API_KEY_FILE)

      File.read(OPEN_AI_API_KEY_FILE)
    end
  end
end

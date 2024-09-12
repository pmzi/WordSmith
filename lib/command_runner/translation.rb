# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../services/open_a_i'
require_relative '../models/word'

module WordSmith
  module CommandRunner
    module Translation
      class << self
        extend T::Sig

        sig { params(word: String).returns(T.nilable(String)) }
        def find_translation(word)
          existing_word = Models::Word.find_by_word(word)

          return existing_word.result unless existing_word.nil?

          result = Services::OpenAI.new.translate(word)

          Models::Word.create(word: word, result: result)

          result
        end
        sig { params(word: String, options: T.nilable(T::Hash[Symbol, String])).void }
        def run(word, options = nil)
          puts find_translation(word)
        end
      end
    end
  end
end

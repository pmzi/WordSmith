# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../services/open_a_i'
require_relative '../models/word'
require_relative '../services/logger'

module WordSmith
  module CommandRunner
    module Translation
      class << self
        extend T::Sig

        sig { params(word: String, no_cache: T::Boolean).returns(Models::Word) }
        def find_translation(word, no_cache: false)
          existing_word = Models::Word.find_by_word(word)

          unless no_cache || existing_word.nil?
            Services::Logger.debug_log("Found existing word: #{existing_word.word}")

            return existing_word
          end

          Services::Logger.debug_log("Translating the word: #{word}")

          result = Services::OpenAI.new.translate(word)

          if existing_word.nil?
            Services::Logger.debug_log("Creating new word: #{word}")

            return Models::Word.create(word: word, pronunciation: result[:pronunciation], meaning: result[:meaning],
                                       example: result[:example])
          end

          Services::Logger.debug_log("Updating existing word: #{word}")

          existing_word.update(word: word, pronunciation: result[:pronunciation], meaning: result[:meaning],
                               example: result[:example])
        end
        sig { params(word: String, options: { no_cache: T::Boolean }).void }
        def run(word, options)
          result = find_translation(word, no_cache: options[:no_cache])

          puts '', "#{Rainbow(result.word).green.bold}#{Rainbow(" (#{result.pronunciation})").blue}", "\n"
          puts " #{Rainbow('Meaning:').bold}#{Rainbow(" #{result.meaning}").blue}", "\n"
          puts " #{Rainbow('Example:').bold}#{Rainbow(" #{result.example}").blue}", "\n"
        end
      end
    end
  end
end

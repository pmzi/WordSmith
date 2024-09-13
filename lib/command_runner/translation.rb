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

        sig { params(input_text: String, options: { no_cache: T::Boolean }).void }
        def run(input_text, options)
          is_contextual_translation = input_text.match?(%r{/[a-zA-Z]+/})

          if is_contextual_translation
            sentence = input_text.gsub(%r{/([a-zA-Z]+)/}, '\1')

            literal_word_match = input_text.match(%r{/([a-zA-Z]+)/})
            raise "Invalid word: #{input_text}" if literal_word_match.nil?

            word = T.cast(literal_word_match.captures[0], String)

            result = find_or_create_contextual_translation(word, sentence, no_cache: options[:no_cache])

            puts '', "In context of \"#{Rainbow(sentence).blue.bold}\":"

            print_common_parts(result)

            return
          end

          word = input_text.chomp

          result = find_or_create_word_translation(word, no_cache: options[:no_cache])

          print_common_parts(result)
        end

        private

        sig { params(word: String, no_cache: T::Boolean).returns(Models::Word) }
        def find_or_create_word_translation(word, no_cache: false)
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

        sig { params(word: String, sentence: String, no_cache: T::Boolean).returns(Models::Word) }
        def find_or_create_contextual_translation(word, sentence, no_cache: false)
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

        sig { params(word: Models::Word).void }
        def print_common_parts(word)
          puts '', "#{Rainbow(word.word).green.bold}#{Rainbow(" (#{word.pronunciation})").blue}", "\n"
          puts " #{Rainbow('Meaning:').bold}#{Rainbow(" #{word.meaning}").blue}", "\n"
          puts " #{Rainbow('Example:').bold}#{Rainbow(" #{word.example}").blue}", "\n"
        end
      end
    end
  end
end

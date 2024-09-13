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

        sig { params(input_text: String, options: { no_cache: T::Boolean, target_language: T.nilable(String) }).void }
        def run(input_text, options)
          is_contextual_translation = input_text.match?(%r{/[a-zA-Z]+/})

          if is_contextual_translation
            sentence = input_text.gsub(%r{/([a-zA-Z]+)/}, '\1')

            literal_word_match = input_text.match(%r{/([a-zA-Z]+)/})
            raise "Invalid word: #{input_text}" if literal_word_match.nil?

            word = T.cast(literal_word_match.captures[0], String)

            result = find_or_create_contextual_translation(word, sentence, **options)

            puts '', "In context of \"#{Rainbow(sentence).blue.bold}\":"

            print_common_parts(result)

            return
          end

          word = input_text.chomp

          result = find_or_create_word_translation(word, **options)

          print_common_parts(result)
        end

        private

        sig do
          params(word: String, no_cache: T::Boolean, target_language: T.nilable(String)).returns(Models::Word)
        end
        def find_or_create_word_translation(word, no_cache: false, target_language: nil)
          existing_word = Models::Word.find_by_word(word)

          unless no_cache || existing_word.nil?
            Services::Logger.debug_log("Found existing word: #{existing_word.word}")

            return existing_word
          end

          Services::Logger.debug_log("Translating the word: #{word}")

          result = Services::OpenAI.new.translate(text: word, target_language: target_language)

          if existing_word.nil?
            Services::Logger.debug_log("Creating new word: #{word}")

            return Models::Word.create(word: word, pronunciation: result[:pronunciation], meaning: result[:meaning],
                                       example: result[:example], target_language: target_language,
                                       translation_to_target_language: result[:translation_to_target_language])
          end

          Services::Logger.debug_log("Updating existing word: #{word}")

          existing_word.update(word: word, pronunciation: result[:pronunciation], meaning: result[:meaning],
                               example: result[:example], target_language: target_language,
                               translation_to_target_language: result[:translation_to_target_language])
        end

        sig do
          params(word: String, sentence: String, no_cache: T::Boolean,
                 target_language: T.nilable(String)).returns(Models::Word)
        end
        def find_or_create_contextual_translation(word, sentence, no_cache: false, target_language: nil)
          existing_word = Models::Word.find_by_word(word)

          unless no_cache || existing_word.nil?
            Services::Logger.debug_log("Found existing word: #{existing_word.word}")

            return existing_word
          end

          Services::Logger.debug_log("Translating the word: #{word}")

          result = Services::OpenAI.new.translate_in_context_of_sentence(word: word, sentence: sentence,
                                                                         target_language: target_language)

          if existing_word.nil?
            Services::Logger.debug_log("Creating new word: #{word}")

            return Models::Word.create(word: word, pronunciation: result[:pronunciation], meaning: result[:meaning],
                                       example: result[:example], target_language: target_language,
                                       translation_to_target_language: result[:translation_to_target_language])
          end

          Services::Logger.debug_log("Updating existing word: #{word}")

          existing_word.update(word: word, pronunciation: result[:pronunciation], meaning: result[:meaning],
                               example: result[:example], target_language: target_language,
                               translation_to_target_language: result[:translation_to_target_language])
        end

        sig { params(word: Models::Word).void }
        def print_common_parts(word)
          puts '', "#{Rainbow(word.word).green.bold}#{Rainbow(" (#{word.pronunciation})").blue}", "\n"
          puts " #{Rainbow('Meaning:').bold}#{Rainbow(" #{word.meaning}").blue}", "\n"
          puts " #{Rainbow('Example:').bold}#{Rainbow(" #{word.example}").blue}", "\n"

          return if word.translation_to_target_language.nil?

          puts " #{Rainbow('Translation to target language:').bold}#{Rainbow(" #{word.translation_to_target_language}").blue}",
               "\n"
        end
      end
    end
  end
end

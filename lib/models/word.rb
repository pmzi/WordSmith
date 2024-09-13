# typed: true
# frozen_string_literal: true

require_relative '../services/db'
require 'sorbet-runtime'

module WordSmith
  module Models
    class Word
      extend T::Sig

      sig { returns(Integer) }
      attr_reader :id

      sig { returns(String) }
      attr_reader :word

      sig { returns(String) }
      attr_reader :pronunciation

      sig { returns(String) }
      attr_reader :meaning

      sig { returns(String) }
      attr_reader :example

      sig { returns(T.nilable(String)) }
      attr_reader :context

      sig { returns(T.nilable(String)) }
      attr_reader :target_language

      sig { returns(T.nilable(String)) }
      attr_reader :translation_to_target_language

      sig do
        params(id: Integer, word: String, pronunciation: String, meaning: String, example: String,
               context: T.nilable(String), target_language: T.nilable(String),
               translation_to_target_language: T.nilable(String)).void
      end
      def initialize(
        id:,
        word:,
        pronunciation:,
        meaning:,
        example:,
        context: nil,
        target_language: nil,
        translation_to_target_language: nil
      )
        @id = id
        @word = word
        @pronunciation = pronunciation
        @meaning = meaning
        @example = example
        @context = context
        @target_language = target_language
        @translation_to_target_language = translation_to_target_language
      end

      sig { void }
      def delete
        Services::DB.instance.execute('DELETE FROM words WHERE id = ?', [@id])
      end

      sig do
        params(word: String, pronunciation: String, meaning: String, example: String,
               context: T.nilable(String), target_language: T.nilable(String),
               translation_to_target_language: T.nilable(String)).returns(Word)
      end
      def update(word:, pronunciation:, meaning:, example:, context: nil, target_language: nil,
                 translation_to_target_language: nil)
        result = Services::DB.instance.execute('UPDATE words SET word = ?, pronunciation = ?, meaning = ?, example = ?, context = ?, target_language = ?, translation_to_target_language = ? WHERE id = ? RETURNING *',
                                               [word, pronunciation, meaning, example, context, target_language,
                                                translation_to_target_language, @id]).first

        @word = result[1]
        @pronunciation = result[2]
        @meaning = result[3]
        @example = result[4]
        @context = result[5]
        @target_language = result[6]
        @translation_to_target_language = result[7]

        self
      end

      class << self
        extend T::Sig

        sig { returns(T::Array[Word]) }
        def all
          Services::DB.instance.execute('SELECT id, word, pronunciation, meaning, example, context, target_language, translation_to_target_language FROM words').map do |row|
            new(id: row[0], word: row[1], pronunciation: row[2], meaning: row[3], example: row[4], context: row[5],
                target_language: row[6], translation_to_target_language: row[7])
          end
        end

        sig do
          params(word: String, pronunciation: String, meaning: String, example: String,
                 context: T.nilable(String), target_language: T.nilable(String),
                 translation_to_target_language: T.nilable(String)).returns(Word)
        end
        def create(word:, pronunciation:, meaning:, example:, context: nil, target_language: nil,
                   translation_to_target_language: nil)
          result = Services::DB.instance.execute('INSERT INTO words (word, pronunciation, meaning, example, context, target_language, translation_to_target_language) VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *',
                                                 [word, pronunciation, meaning, example, context, target_language,
                                                  translation_to_target_language]).first

          new(id: result[0], word: result[1], pronunciation: result[2], meaning: result[3], example: result[4],
              context: result[5], target_language: result[6], translation_to_target_language: result[7])
        end

        sig { params(id: Integer).returns(Word) }
        def find(id)
          Services::DB.instance.execute('SELECT id, word, pronunciation, meaning, example, context, target_language, translation_to_target_language FROM words WHERE id = ?',
                                        [id]).map do |row|
            new(id: row[0], word: row[1], pronunciation: row[2], meaning: row[3], example: row[4], context: row[5],
                target_language: row[6], translation_to_target_language: row[7])
          end.first
        end

        sig { params(word: String).returns(T.nilable(Word)) }
        def find_by_word(word)
          Services::DB.instance.execute('SELECT id, word, pronunciation, meaning, example, context, target_language, translation_to_target_language FROM words WHERE word = ?',
                                        [word]).map do |row|
            new(id: row[0], word: row[1], pronunciation: row[2], meaning: row[3], example: row[4], context: row[5],
                target_language: row[6], translation_to_target_language: row[7])
          end.first
        end
      end
    end
  end
end

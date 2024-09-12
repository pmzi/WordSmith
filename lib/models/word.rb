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
      attr_reader :result

      sig { params(id: Integer, word: String, result: String).void }
      def initialize(id:, word:, result:)
        @id = id
        @word = word
        @result = result
      end

      class << self
        extend T::Sig

        sig { returns(T::Array[Word]) }
        def all
          Services::DB.instance.execute('SELECT * FROM words').map do |row|
            new(**row)
          end
        end

        sig { params(word: String, result: String).returns(Word) }
        def create(word:, result:)
          result = Services::DB.instance.execute('INSERT INTO words (word, result) VALUES (?, ?) RETURNING *',
                                                 [word, result])

          puts result.first
          new(**result.first)
        end

        sig { params(id: Integer).void }
        def delete(id)
          Services::DB.instance.execute('DELETE FROM words WHERE id = ?', [id])
        end

        sig { params(id: Integer).returns(Word) }
        def find(id)
          Services::DB.instance.execute('SELECT id, word, result FROM words WHERE id = ?', [id]).map do |row|
            new(id: row[0], word: row[1], result: row[2])
          end.first
        end

        sig { params(word: String).returns(T.nilable(Word)) }
        def find_by_word(word)
          Services::DB.instance.execute('SELECT id, word, result FROM words WHERE word = ?', [word]).map do |row|
            new(id: row[0], word: row[1], result: row[2])
          end.first
        end
      end
    end
  end
end

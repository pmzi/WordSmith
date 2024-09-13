# typed: true
# frozen_string_literal: true

require_relative '../services/db'

module WordSmith
  module Migrations
    class Words
      def self.up
        Services::DB.instance.execute <<-SQL
          CREATE TABLE IF NOT EXISTS words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            pronunciation TEXT NOT NULL,
            meaning TEXT NOT NULL,
            example TEXT NOT NULL,
            context TEXT DEFAULT NULL,
            target_language TEXT DEFAULT NULL,
            translation_to_target_language TEXT DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        SQL
      end
    end
  end
end

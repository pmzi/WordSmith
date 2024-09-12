# typed: true
# frozen_string_literal: true

require 'sqlite3'
require 'sorbet-runtime'
require 'singleton'

module WordSmith
  module Services
    class DB < SQLite3::Database
      extend T::Sig
      include Singleton

      DB_FILE = File.join(File.dirname(__FILE__), '../..', 'db', 'storage.db')

      sig { void }
      def initialize
        @db = super(DB_FILE)
      end
    end
  end
end
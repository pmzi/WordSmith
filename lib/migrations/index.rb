# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module WordSmith
  module Migrations
    class << self
      extend T::Sig

      sig { void }
      def run
        Dir.glob(File.join(__dir__, './*.rb')).each do |file| # rubocop:disable Lint/NonDeterministicRequireOrder
          next if file == __FILE__

          require_relative file
        end

        WordSmith::Migrations.constants.each do |constant|
          WordSmith::Migrations.const_get(constant).up
        end
      end
    end
  end
end

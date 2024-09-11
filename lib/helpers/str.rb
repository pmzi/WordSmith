# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module WordSmith
  module Helpers
    module Str
      extend T::Sig

      sig { params(string: String).returns(String) }
      def self.lstr_every_line(string)
        string.split("\n").map(&:lstrip).join("\n")
      end
    end
  end
end

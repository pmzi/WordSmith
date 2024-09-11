# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module WordSmith
  module CommandRunner
    module Translation
      class << self
        extend T::Sig

        sig { params(word: String, options: T.nilable(T::Hash[Symbol, String])).void }
        def run(word, options = nil)
          puts word
        end
      end
    end
  end
end

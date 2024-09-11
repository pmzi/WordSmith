# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative '../services/open_a_i'

module WordSmith
  module CommandRunner
    module Translation
      class << self
        extend T::Sig

        sig { params(word: String, options: T.nilable(T::Hash[Symbol, String])).void }
        def run(word, options = nil)
          Services::OpenAI.new.translate(word)
        end
      end
    end
  end
end

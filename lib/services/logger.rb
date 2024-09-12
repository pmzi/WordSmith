# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'rainbow'

module WordSmith
  module Services
    module Logger
      class << self
        extend T::Sig

        sig { params(message: String).void }
        def debug_log(message)
          return unless Config::DEBUG_MODE

          puts Rainbow('DEBUG:').white.bg(:yellow) + " #{message}"
        end
      end
    end
  end
end

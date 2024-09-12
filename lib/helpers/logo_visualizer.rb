module WordSmith
  module Helpers
    module LogoVisualizer
      def self.draw
        puts Rainbow("
        ▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄      ▗▄▄▖▗▖  ▗▖▗▄▄▄▖▗▄▄▄▖▗▖ ▗▖
        ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌  █    ▐▌   ▐▛▚▞▜▌  █    █  ▐▌ ▐▌
        ▐▌ ▐▌▐▌ ▐▌▐▛▀▚▖▐▌  █     ▝▀▚▖▐▌  ▐▌  █    █  ▐▛▀▜▌
        ▐▙█▟▌▝▚▄▞▘▐▌ ▐▌▐▙▄▄▀    ▗▄▄▞▘▐▌  ▐▌▗▄█▄▖  █  ▐▌ ▐▌
        ").blue.bold
      end
    end
  end
end

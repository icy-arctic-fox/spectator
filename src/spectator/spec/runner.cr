require "../example"

module Spectator
  class Spec
    private struct Runner
      def initialize(@examples : Array(Example))
      end

      def run
        @examples.each(&.run)
      end
    end
  end
end

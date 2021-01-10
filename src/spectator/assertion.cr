require "./block"
require "./expression"

module Spectator
  class Assertion
    struct Target(T)
      @expression : Expression(T) | Block(T)
      @source : Source?

      def initialize(@expression : Expression(T) | Block(T), @source)
        puts "TARGET: #{@expression} @ #{@source}"
      end
    end
  end
end

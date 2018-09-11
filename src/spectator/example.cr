require "./source"

module Spectator
  abstract class Example
    getter context : Context

    def initialize(@context)
    end

    macro is_expected
      expect(subject)
    end

    abstract def run
  end
end

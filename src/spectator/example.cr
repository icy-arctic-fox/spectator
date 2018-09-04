require "./source"

module Spectator
  abstract class Example
    macro is_expected
      expect(subject)
    end

    abstract def source : Source

    abstract def run
  end
end

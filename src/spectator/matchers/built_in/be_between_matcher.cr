require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeBetweenMatcher(B, E)
    include Matchable

    def initialize(@min : B, @max : E, @exclusive : Bool = false)
    end

    def matches?(actual_value)
      if @exclusive
        actual_value > @min && actual_value < @max
      else
        actual_value >= @min && actual_value <= @max
      end
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "     Expected: " << description_of(actual_value) << EOL
      printer << "to be between: " << description_of(@min) << " and " << description_of(@max)
      printer << " (" << (@exclusive ? "exclusive" : "inclusive") << ')'
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "     Expected: " << description_of(actual_value) << EOL
      printer << "to be outside: " << description_of(@min) << " and " << description_of(@max)
      printer << " (" << (@exclusive ? "exclusive" : "inclusive") << ')'
    end

    def to_s(io : IO) : Nil
      io << "be between " << @min << " and " << @max
      io << " (" << (@exclusive ? "exclusive" : "inclusive") << ')'
    end

    def exclusive
      self.class.new(@min, @max, true)
    end

    def inclusive
      self.class.new(@min, @max, false)
    end
  end
end

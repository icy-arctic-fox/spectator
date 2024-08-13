require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeBetweenMatcher(B, E)
    include Matchable

    def description
      "be between #{@min} and #{@max} (#{@exclusive ? "exclusive" : "inclusive"})"
    end

    def initialize(@min : B, @max : E, @exclusive : Bool = false)
    end

    def matches?(actual_value)
      if @exclusive
        actual_value > @min && actual_value < @max
      else
        actual_value >= @min && actual_value <= @max
      end
    end

    print_messages

    def failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "     Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to be between: "
      printer.description_of(@min)
      printer << " and "
      printer.description_of(@max)
      printer << " (" << (@exclusive ? "exclusive" : "inclusive") << ')'
    end

    def negated_failure_message(printer : FormattingPrinter, actual_value) : Nil
      printer << "     Expected: "
      printer.description_of(actual_value)
      printer.puts

      printer << "to be outside: "
      printer.description_of(@min)
      printer << " and "
      printer.description_of(@max)
      printer << " (" << (@exclusive ? "exclusive" : "inclusive") << ')'
    end

    def exclusive
      self.class.new(@min, @max, true)
    end

    def inclusive
      self.class.new(@min, @max, false)
    end
  end
end

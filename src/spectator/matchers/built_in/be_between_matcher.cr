module Spectator::Matchers::BuiltIn
  struct BeBetweenMatcher(B, E)
    def initialize(@min : B, @max : E, @exclusive : Bool = false)
    end

    def matches?(actual_value) : Bool
      if @exclusive
        actual_value > @min && actual_value < @max
      else
        actual_value >= @min && actual_value <= @max
      end
    end

    def failure_message(actual_value) : String
      "     Expected: #{actual_value.pretty_inspect}\n" +
        "to be between: #{@min.pretty_inspect} and #{@max.pretty_inspect} (#{@exclusive ? "exclusive" : "inclusive"})"
    end

    def negated_failure_message(actual_value) : String
      "     Expected: #{actual_value.pretty_inspect}\n" +
        "to be outside: #{@min.pretty_inspect} and #{@max.pretty_inspect} (#{@exclusive ? "exclusive" : "inclusive"})"
    end

    def exclusive
      self.class.new(@min, @max, true)
    end

    def inclusive
      self.class.new(@min, @max, false)
    end
  end
end

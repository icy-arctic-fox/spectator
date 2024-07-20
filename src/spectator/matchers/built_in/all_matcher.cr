require "../matcher"

module Spectator::Matchers::BuiltIn
  class AllMatcher(T)
    def initialize(@matcher : T)
    end

    def matches?(actual_value) : Bool
      raise "`all` matcher requires value to be `Enumerable`" unless actual_value.is_a?(Enumerable)
      actual_value.each_with_index do |value, index|
        next unless failure = Matcher.process(@matcher, value)
        @failed_index = index
        @failure = failure
        return false
      end
      true
    end

    def does_not_match?(actual_value) : Bool
      raise "`all` matcher requires value to be `Enumerable`" unless actual_value.is_a?(Enumerable)
      actual_value.each_with_index do |value, index|
        next unless failure = Matcher.process_negated(@matcher, value)
        @failed_index = index
        @failure = failure
        return false
      end
      true
    end

    def failure_message(actual_value) : String
      if (index = @failed_index) && (failure = @failure)
        <<-END_MESSAGE
        Expected all elements to be satisfied, but element #{index} did not.
        #{failure.message}
        END_MESSAGE
      else
        raise ApplicationError.new("`failure_message` was called on a successful expectation")
      end
    end

    def negative_failure_message(actual_value) : String
      if (index = @failed_index) && (failure = @failure)
        <<-END_MESSAGE
        Expected no elements to be satisfied, but element #{index} did.
        #{failure.message}
        END_MESSAGE
      else
        raise ApplicationError.new("`negative_failure_message` was called on a successful expectation")
      end
    end
  end
end

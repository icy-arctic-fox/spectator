module Spectator::Matchers::BuiltIn
  class RaiseErrorMatcher(T)
    @expected_error : T?
    @expected_message : String | Regex?

    getter rescued_error : Exception?

    def initialize(@expected_error : T)
    end

    def initialize(@expected_message : String | Regex? = nil)
    end

    def matches?(&)
      yield
      false
    rescue ex
      @rescued_error = ex
      matches_error?(ex)
    end

    private def matches_error?(actual_error)
      if expected_error = @expected_error
        actual_error == expected_error
      elsif expected_message = @expected_message
        return false unless actual_error.is_a?(T)
        case expected_message
        in String then actual_error.message == expected_message
        in Regex  then actual_error.message =~ expected_message
        end
      else
        actual_error.is_a?(T)
      end
    end

    def failure_message(&)
      "Expected block to raise error #{@expected_error.pretty_inspect}"
    end

    def negated_failure_message(&)
      "Expected block not to raise error #{@expected_error.pretty_inspect}"
    end
  end
end

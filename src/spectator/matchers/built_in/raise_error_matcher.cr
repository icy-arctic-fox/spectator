require "../matchable"

module Spectator::Matchers::BuiltIn
  class RaiseErrorMatcher(T)
    include Matchable

    @expected_error : T?
    @expected_message : String | Regex?

    getter rescued_error : Exception?

    def description
      "raise error #{@expected_error.inspect}"
    end

    def initialize(@expected_error : T)
    end

    def initialize(@expected_message : String | Regex? = nil)
    end

    require_block

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

    print_messages

    def failure_message(printer : FormattingPrinter, &) : Nil
      printer << "Expected block to raise error "
      printer.description_of(@expected_error)
    end

    def negated_failure_message(printer : FormattingPrinter, &) : Nil
      printer << "Expected block not to raise error "
      printer.description_of(@expected_error)
    end
  end
end

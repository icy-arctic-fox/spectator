require "../matchable"

module Spectator::Matchers::BuiltIn
  class RaiseErrorMatcher(T)
    include Matchable

    @expected_error : T?
    @expected_message : String | Regex?

    getter rescued_error : Exception?

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

    def print_failure_message(printer : Formatters::Printer, &) : Nil
      printer << "Expected block to raise "
      describe_expected_error(printer)
    end

    def print_negated_failure_message(printer : Formatters::Printer, &) : Nil
      printer << "Expected block not to raise "
      describe_expected_error(printer)
    end

    def to_s(io : IO) : Nil
      io << "raise "
      describe_expected_error(io)
    end

    private def describe_expected_error(output) : Nil
      if expected_error = @expected_error
        output << expected_error.class.name << " with message " << description_of(expected_error.message)
      elsif expected_message = @expected_message
        output << "an error with message " << description_of(expected_message)
      else
        output << "an error"
      end
    end
  end
end

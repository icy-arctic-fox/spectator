require "../matchable"

module Spectator::Matchers::BuiltIn
  struct StartWithMatcher(T)
    include Matchable

    def initialize(@expected : T)
    end

    def matches?(actual_value)
      case actual_value
      when String     then matches_string?(actual_value)
      when Enumerable then matches_enumerable?(actual_value)
      else                 raise "The `start_with` matcher requires a String or Enumerable object" # TODO: Better error message
      end
    end

    private def matches_string?(actual_value : String)
      offset = 0
      @expected.each do |expected|
        expected_part = expected.to_s
        expected_size = expected_part.size
        actual_part = actual_value[offset, expected_size]
        return false if actual_part != expected_part
        offset += expected_size
      rescue IndexError
        return false
      end
      true
    end

    private def matches_enumerable?(actual_value : Enumerable)
      @expected.zip(actual_value) do |expected, actual|
        return false if actual != expected
      end
      true
    rescue IndexError
      false
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to start with " << @expected
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to start with " << @expected
    end

    def to_s(io : IO) : Nil
      io << "start with " << @expected
    end
  end
end

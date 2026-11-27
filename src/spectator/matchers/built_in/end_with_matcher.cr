require "../matchable"

module Spectator::Matchers::BuiltIn
  struct EndWithMatcher(T)
    include Matchable

    def initialize(@expected : T)
    end

    def matches?(actual_value)
      case actual_value
      when String     then matches_string?(actual_value)
      when Enumerable then matches_enumerable?(actual_value)
      else                 raise "The `end_with` matcher requires a String or Enumerable object" # TODO: Better error message
      end
    end

    private def matches_string?(actual_value : String)
      offset = 0
      @expected.each do |expected|
        expected_part = expected.to_s
        expected_size = expected_part.size
        offset -= expected_size
        actual_part = actual_value[offset, expected_size]
        return false if actual_part != expected_part
      rescue IndexError
        return false
      end
      true
    end

    private def matches_enumerable?(actual_value : Enumerable)
      return true if @expected.empty?
      actual_end = last_elements(@expected.size, actual_value)
      @expected.zip(actual_end) do |expected, actual|
        return false if actual != expected
      end
      true
    rescue IndexError
      false
    end

    private def last_elements(count : Int, enumerable : Enumerable(U)) : Indexable(U) forall U
      deque = Deque(U).new(count)
      enumerable.each do |item|
        deque.shift if deque.size >= deque.capacity # aka count
        deque << item
      end
      deque
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to end with" << @expected
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to end with" << @expected
    end

    def to_s(io : IO) : Nil
      io << "end with " << @expected
    end
  end
end

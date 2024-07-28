module Spectator::Matchers::BuiltIn
  struct EqualMatcher(T)
    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      expected_value = @expected_value

      if actual_value.is_a?(String) && expected_value.is_a?(String)
        strings_equal?(actual_value, expected_value)
      else
        actual_value == expected_value
      end
    end

    private def strings_equal?(actual_value : String, expected_value : String) : Bool
      actual_value == expected_value &&
        actual_value.bytesize == expected_value.bytesize &&
        actual_value.size == expected_value.size
    end

    def failure_message(actual_value)
      expected_value = @expected_value

      if actual_value.is_a?(String) && expected_value.is_a?(String) && actual_value == expected_value
        strings_failure_message(actual_value, expected_value)
      else
        expected = expected_value.pretty_inspect
        actual = actual_value.pretty_inspect
        if expected == actual
          expected += " : #{expected_value.class}"
          actual += " : #{actual_value.class}"
        end
        <<-MSG
        Expected: #{expected}
             got: #{actual}"
        MSG
      end
    end

    private def strings_failure_message(actual_value : String, expected_value : String) : String
      if actual_value.bytesize != expected_value.bytesize
        <<-MSG
        Expected bytesize: #{expected_value.bytesize}
             got bytesize: #{actual_value.bytesize}
        MSG
      else
        <<-MSG
        Expected size: #{expected_value.size}
             got size: #{actual_value.size}
        MSG
      end
    end

    def negated_failure_message(actual_value)
      <<-MSG
      Expected:     #{actual_value.pretty_inspect}
      not to equal: #{@expected_value.pretty_inspect}"
      MSG
    end
  end
end

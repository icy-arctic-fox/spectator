module Spectator::Matchers::BuiltIn
  struct BeMatcher(T)
    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      expected_value = @expected_value
      if expected_value.is_a?(Reference) && actual_value.is_a?(Reference)
        # Both are references, check if they're the same object.
        actual_value.same?(expected_value)
      elsif expected_value.class == actual_value.class
        # Both are the same type, check if they're equal.
        actual_value == expected_value
      else
        # They're different types, so they can't be the same.
        false
      end
    end

    def failure_message(actual_value)
      <<-MESSAGE
      Expected: #{stringify(actual_value)}
         to be: #{stringify(@expected_value)}
      MESSAGE
    end

    def negated_failure_message(actual_value)
      <<-MESSAGE
       Expected: #{stringify(actual_value)}
      not to be: #{stringify(@expected_value)}
      MESSAGE
    end

    private def stringify(value) : String
      string = value.pretty_inspect
      if value.is_a?(Reference)
        "#{string} (object_id: #{value.object_id})"
      else
        "#{string} : #{value.class}"
      end
    end
  end
end

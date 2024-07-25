module Spectator::Matchers::BuiltIn
  struct BeAMatcher(T)
    def matches?(actual_value) : Bool
      actual_value.is_a?(T)
    end

    def failure_message(actual_value) : String
      <<-MESSAGE
       Expected: #{actual_value.pretty_inspect}
        to be a: #{T}
      but was a: #{actual_value.class}
      MESSAGE
    end

    def negated_failure_message(actual_value) : String
      <<-MESSAGE
         Expected: #{actual_value.pretty_inspect}
      not to be a: #{T}
      MESSAGE
    end
  end
end

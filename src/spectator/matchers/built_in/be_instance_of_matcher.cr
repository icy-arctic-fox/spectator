module Spectator::Matchers::BuiltIn
  struct BeInstanceOfMatcher(T)
    def matches?(actual_value) : Bool
      actual_value.class == T
    end

    def failure_message(actual_value) : String
      if actual_value.is_a?(T)
        <<-MESSAGE
         Expected: #{actual_value.pretty_inspect}
          to be a: #{T}
        but was a: #{actual_value.class}
        
        #{actual_value.class} is a sub-type of #{T}.
        Using `be_instance_of` ensures the type matches EXACTLY.
        If you want to match sub-types, use `be_a` instead.
        MESSAGE
      else
        <<-MESSAGE
         Expected: #{actual_value.pretty_inspect}
          to be a: #{T}
        but was a: #{actual_value.class}
        MESSAGE
      end
    end

    def negated_failure_message(actual_value) : String
      <<-MESSAGE
         Expected: #{actual_value.pretty_inspect}
      not to be a: #{T}
      MESSAGE
    end
  end
end

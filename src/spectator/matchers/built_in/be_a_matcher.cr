require "../matchable"

module Spectator::Matchers::BuiltIn
  struct BeAMatcher(T)
    include Matchable

    def description
      "be a #{T}"
    end

    def matches?(actual_value)
      actual_value.is_a?(T)
    end

    format_messages

    def failure_message(actual_value) : Nil
      puts << " Expected: " << description_of(actual_value)
      puts << "  to be a: " << description_of(T)
      puts << "but was a: " << description_of(actual_value.class)
    end

    def negated_failure_message(actual_value) : Nil
      puts << "   Expected: " << description_of(actual_value)
      puts << "not to be a: " << description_of(T)
      return if actual_value.class == T
      puts << description_of(actual_value.class) << " is a sub-type of " << description_of(T)
    end
  end
end

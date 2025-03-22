require "../value"
require "./match_data"

module Spectator::Matchers
  # Common base class for all expectation conditions.
  # A matcher looks at something produced by the SUT
  # and evaluates whether it is correct or not.
  abstract struct Matcher
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    # ```
    # it { is_expected.to do_something }
    # ```
    # The phrasing should be such that it reads "it ___."
    # where the blank is what is returned by this method.
    abstract def description : String

    # Actually performs the test against the expression (value or block).
    abstract def match(actual : Expression(T)) : MatchData forall T

    # Performs the test against the expression (value or block), but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    abstract def negated_match(actual : Expression(T)) : MatchData forall T

    # Compares a matcher against a value.
    # Enables composable matchers.
    def ===(actual : Expression(T)) : Bool
      match(actual).matched?
    end

    # Compares a matcher against a value.
    # Enables composable matchers.
    def ===(other) : Bool
      expression = Value.new(other)
      match(expression).matched?
    end

    private def match_data_description(actual : Expression(T)) : String forall T
      match_data_description(actual.label)
    end

    private def match_data_description(actual_label : String | Symbol) : String
      "#{actual_label} #{description}"
    end

    private def match_data_description(actual_label : Nil) : String
      description
    end
  end
end

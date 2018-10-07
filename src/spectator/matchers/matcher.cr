module Spectator::Matchers
  # Common base class for all expectation conditions.
  # A matcher looks at something produced by the SUT
  # and evaluates whether it is correct or not.
  abstract struct Matcher
    # Textual representation of what the matcher expects.
    # This shouldn't be used in the conditional logic,
    # but for verbose output to help the end-user.
    private getter label : String

    # Creates the base of the matcher.
    private def initialize(@label)
    end
  end
end

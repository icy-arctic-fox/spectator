module Spectator::Matchers
  # Match data that does nothing.
  # This is to workaround a Crystal compiler bug.
  # See: [Issue 4225](https://github.com/crystal-lang/crystal/issues/4225)
  # If there are no concrete implementations of an abstract class,
  # the compiler gives an error.
  # The error indicates an abstract method is undefined.
  # This class shouldn't be used, it's just to trick the compiler.
  private struct DummyMatchData < MatchData
    # Creates the match data.
    def initialize
      super(false)
    end

    # Dummy values.
    def named_tuple
      {
        you: "shouldn't be calling this."
      }
    end

    # Dummy message.
    def message
      "You shouldn't be calling this."
    end

    # Dummy message
    def negated_message
      "You shouldn't be calling this."
    end
  end
end

module Spectator::Expectations
  # Min-in for all expectation types.
  # Classes that include this must implement
  # the `#satisfied?`, `#message`, and `#negated_message` methods.
  # Typically, expectation classes/structs store an `ExpectationPartial`
  # and a `Matchers::Matcher` and then proxy calls to those instances.
  module Expectation
    # Checks whether the expectation is met.
    abstract def satisfied? : Bool

    # Describes the condition that must be met for the expectation to be satisifed.
    abstract def message : String

    # Describes the condition under which the expectation won't be satisifed.
    abstract def negated_message : String

    # Evaulates the expectation and produces a result.
    # The `negated` flag should be set to true to invert the result.
    def eval(negated = false) : Result
      success = satisfied? ^ negated
      Result.new(success, negated, self)
    end

    # Information regarding the outcome of an expectation.
    class Result
      # Indicates whether the expectation was satisifed or not.
      getter? successful : Bool

      # Indicates whether the expectation failed.
      def failure? : Bool
        !@successful
      end

      # Creates the result.
      # The expectation is stored so that information from it may be lazy-loaded.
      protected def initialize(@successful, @negated : Bool, @expectation : Expectation)
      end

      # Description of the condition that satisfies, or meets, the expectation.
      def expected_message
        message(@negated)
      end

      # Description of what actually happened when the expectation was evaluated.
      def actual_message
        message(!@successful)
      end

      # Retrieves the message or negated message from an expectation.
      # Set `negated` to true to get the negated message,
      # or to false to get the regular message.
      private def message(negated)
        negated ? @expectation.negated_message : @expectation.message
      end
    end
  end
end

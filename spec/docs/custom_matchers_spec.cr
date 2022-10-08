require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/wikis/Custom-Matchers
Spectator.describe "Custom Matchers Docs" do
  context "value matcher" do
    # Sub-type of Matcher to suit our needs.
    # Notice this is a struct.
    struct MultipleOfMatcher(ExpectedType) < Spectator::Matchers::ValueMatcher(ExpectedType)
      # Short text about the matcher's purpose.
      # This explains what condition satisfies the matcher.
      # The description is used when the one-liner syntax is used.
      def description : String
        "is a multiple of #{expected.label}"
      end

      # Checks whether the matcher is satisfied with the expression given to it.
      private def match?(actual : Spectator::Expression(T)) : Bool forall T
        actual.value % expected.value == 0
      end

      # Message displayed when the matcher isn't satisfied.
      # The message should typically only contain the test expression labels.
      private def failure_message(actual : Spectator::Expression(T)) : String forall T
        "#{actual.label} is not a multiple of #{expected.label}"
      end

      # Message displayed when the matcher isn't satisfied and is negated.
      # This is essentially what would satisfy the matcher if it wasn't negated.
      # The message should typically only contain the test expression labels.
      private def failure_message_when_negated(actual : Spectator::Expression(T)) : String forall T
        "#{actual.label} is a multiple of #{expected.label}"
      end
    end

    # The DSL portion of the matcher.
    # This captures the test expression and creates an instance of the matcher.
    macro be_a_multiple_of(expected)
    %value = ::Spectator::Value.new({{expected}}, {{expected.stringify}})
    MultipleOfMatcher.new(%value)
  end

    specify do
      expect(9).to be_a_multiple_of(3)
      # or negated:
      expect(5).to_not be_a_multiple_of(2)
    end

    specify "failure messages" do
      expect { expect(9).to be_a_multiple_of(5) }.to raise_error(Spectator::ExpectationFailed, "9 is not a multiple of 5")
      expect { expect(6).to_not be_a_multiple_of(3) }.to raise_error(Spectator::ExpectationFailed, "6 is a multiple of 3")
    end
  end

  context "standard matcher" do
    struct OddMatcher < Spectator::Matchers::StandardMatcher
      def description : String
        "is odd"
      end

      private def match?(actual : Spectator::Expression(T)) : Bool forall T
        actual.value % 2 == 1
      end

      private def failure_message(actual : Spectator::Expression(T)) : String forall T
        "#{actual.label} is not odd"
      end

      private def failure_message_when_negated(actual : Spectator::Expression(T)) : String forall T
        "#{actual.label} is odd"
      end

      private def does_not_match?(actual : Spectator::Expression(T)) : Bool forall T
        actual.value % 2 == 0
      end
    end

    macro be_odd
      OddMatcher.new
    end

    specify do
      expect(9).to be_odd
      expect(2).to_not be_odd
    end

    specify "failure messages" do
      expect { expect(2).to be_odd }.to raise_error(Spectator::ExpectationFailed, "2 is not odd")
      expect { expect(3).to_not be_odd }.to raise_error(Spectator::ExpectationFailed, "3 is odd")
    end
  end
end

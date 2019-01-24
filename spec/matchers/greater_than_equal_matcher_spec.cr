require "../spec_helper"

describe Spectator::Matchers::GreaterThanEqualMatcher do
  describe "#match?" do
    it "compares using #>=" do
      spy = SpySUT.new
      partial = Spectator::Expectations::ValueExpectationPartial.new(spy)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(42)
      matcher.match?(partial).should be_true
      spy.ge_call_count.should be > 0
    end

    context "with a larger value" do
      it "is false" do
        actual = 42
        expected = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(actual)
        matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(expected)
        matcher.match?(partial).should be_false
      end
    end

    context "with a smaller value" do
      it "is true" do
        actual = 777
        expected = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(actual)
        matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(expected)
        matcher.match?(partial).should be_true
      end
    end

    context "with an equal value" do
      it "is true" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value)
        matcher.match?(partial).should be_true
      end
    end
  end

  describe "#message" do
    it "mentions >=" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value)
      matcher.message(partial).should contain(">=")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(label, value)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value2)
        matcher.message(partial).should contain(value2.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "mentions >=" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value)
      matcher.negated_message(partial).should contain(">=")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(label, value)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::GreaterThanEqualMatcher.new(value2)
        matcher.negated_message(partial).should contain(value2.to_s)
      end
    end
  end
end

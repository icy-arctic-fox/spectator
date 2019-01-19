require "../spec_helper"

describe Spectator::Matchers::TypeMatcher do
  describe "#match?" do
    context "with the same type" do
      it "is true" do
        value = "foobar"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::TypeMatcher(String).new
        matcher.match?(partial).should be_true
      end
    end

    context "with a different type" do
      it "is false" do
        value = "foobar"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::TypeMatcher(Int32).new
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::TypeMatcher(String).new
      matcher.message(partial).should contain(label)
    end

    it "contains the expected type" do
      partial = Spectator::Expectations::ValueExpectationPartial.new(42)
      matcher = Spectator::Matchers::TypeMatcher(String).new
      matcher.message(partial).should contain("String")
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::TypeMatcher(String).new
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected type" do
      partial = Spectator::Expectations::ValueExpectationPartial.new(42)
      matcher = Spectator::Matchers::TypeMatcher(String).new
      matcher.negated_message(partial).should contain("String")
    end
  end
end

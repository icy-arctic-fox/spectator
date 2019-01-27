require "../spec_helper"

describe Spectator::Matchers::NilMatcher do
  describe "#match?" do
    context "with nil" do
      it "is true" do
        value = nil.as(Bool?)
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::NilMatcher.new
        matcher.match?(partial).should be_true
      end
    end

    context "with not nil" do
      it "is false" do
        value = true.as(Bool?)
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::NilMatcher.new
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "mentions nil" do
      partial = Spectator::Expectations::ValueExpectationPartial.new(42)
      matcher = Spectator::Matchers::NilMatcher.new
      matcher.message(partial).should contain("nil")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::NilMatcher.new
      matcher.message(partial).should contain(label)
    end
  end

  describe "#negated_message" do
    it "mentions nil" do
      partial = Spectator::Expectations::ValueExpectationPartial.new(42)
      matcher = Spectator::Matchers::NilMatcher.new
      matcher.negated_message(partial).should contain("nil")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::NilMatcher.new
      matcher.negated_message(partial).should contain(label)
    end
  end
end
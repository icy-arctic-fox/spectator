require "../spec_helper"

describe Spectator::Matchers::EmptyMatcher do
  describe "#match?" do
    context "with an empty set" do
      it "is true" do
        array = [] of Symbol
        partial = Spectator::Expectations::ValueExpectationPartial.new(array)
        matcher = Spectator::Matchers::EmptyMatcher.new
        matcher.match?(partial).should be_true
      end
    end

    context "with a filled set" do
      it "is false" do
        array = %i[a b c]
        partial = Spectator::Expectations::ValueExpectationPartial.new(array)
        matcher = Spectator::Matchers::EmptyMatcher.new
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      array = %i[a b c]
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, array)
      matcher = Spectator::Matchers::EmptyMatcher.new
      matcher.message(partial).should contain(label)
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      array = %i[a b c]
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, array)
      matcher = Spectator::Matchers::EmptyMatcher.new
      matcher.negated_message(partial).should contain(label)
    end
  end
end

require "../spec_helper"

describe Spectator::Matchers::EmptyMatcher do
  describe "#match?" do
    context "with an empty set" do
      it "is true" do
        array = [] of Symbol
        partial = new_partial(array)
        matcher = Spectator::Matchers::EmptyMatcher.new
        matcher.match?(partial).should be_true
      end
    end

    context "with a filled set" do
      it "is false" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::EmptyMatcher.new
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      array = %i[a b c]
      label = "everything"
      partial = new_partial(array, label)
      matcher = Spectator::Matchers::EmptyMatcher.new
      matcher.message(partial).should contain(label)
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      array = %i[a b c]
      label = "everything"
      partial = new_partial(array, label)
      matcher = Spectator::Matchers::EmptyMatcher.new
      matcher.negated_message(partial).should contain(label)
    end
  end
end

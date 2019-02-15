require "../spec_helper"

describe Spectator::Matchers::PredicateMatcher do
  describe "#match?" do
    context "with a true predicate" do
      it "is true" do
        value = "foobar"
        partial = new_partial(value)
        matcher = Spectator::Matchers::PredicateMatcher(NamedTuple(ascii_only: Nil)).new
        matcher.match?(partial).should be_true
      end
    end

    context "with a false predicate" do
      it "is false" do
        value = "foobar"
        partial = new_partial(value)
        matcher = Spectator::Matchers::PredicateMatcher(NamedTuple(empty: Nil)).new
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      value = "foobar"
      label = "blah"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::PredicateMatcher(NamedTuple(ascii_only: Nil)).new
      matcher.message(partial).should contain(label)
    end

    it "contains stringified form of predicate" do
      value = "foobar"
      partial = new_partial(value)
      matcher = Spectator::Matchers::PredicateMatcher(NamedTuple(ascii_only: Nil)).new
      matcher.message(partial).should contain("ascii_only")
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      value = "foobar"
      label = "blah"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::PredicateMatcher(NamedTuple(ascii_only: Nil)).new
      matcher.negated_message(partial).should contain(label)
    end

    it "contains stringified form of predicate" do
      value = "foobar"
      partial = new_partial(value)
      matcher = Spectator::Matchers::PredicateMatcher(NamedTuple(ascii_only: Nil)).new
      matcher.negated_message(partial).should contain("ascii_only")
    end
  end
end

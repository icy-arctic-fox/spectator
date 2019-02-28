require "../spec_helper"

describe Spectator::Matchers::LessThanMatcher do
  describe "#match?" do
    it "compares using #<" do
      spy = SpySUT.new
      partial = new_partial(spy)
      matcher = Spectator::Matchers::LessThanMatcher.new(42)
      matcher.match?(partial).should be_true
      spy.lt_call_count.should be > 0
    end

    context "with a larger value" do
      it "is true" do
        actual = 42
        expected = 777
        partial = new_partial(actual)
        matcher = Spectator::Matchers::LessThanMatcher.new(expected)
        matcher.match?(partial).should be_true
      end
    end

    context "with a smaller value" do
      it "is false" do
        actual = 777
        expected = 42
        partial = new_partial(actual)
        matcher = Spectator::Matchers::LessThanMatcher.new(expected)
        matcher.match?(partial).should be_false
      end
    end

    context "with an equal value" do
      it "is false" do
        value = 42
        partial = new_partial(value)
        matcher = Spectator::Matchers::LessThanMatcher.new(value)
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "mentions <" do
      value = 42
      partial = new_partial(value)
      matcher = Spectator::Matchers::LessThanMatcher.new(value)
      matcher.message(partial).should contain("<")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::LessThanMatcher.new(value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::LessThanMatcher.new(value, label)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = new_partial(value1)
        matcher = Spectator::Matchers::LessThanMatcher.new(value2)
        matcher.message(partial).should contain(value2.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "mentions <" do
      value = 42
      partial = new_partial(value)
      matcher = Spectator::Matchers::LessThanMatcher.new(value)
      matcher.negated_message(partial).should contain("<")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::LessThanMatcher.new(value)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::LessThanMatcher.new(value, label)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = new_partial(value1)
        matcher = Spectator::Matchers::LessThanMatcher.new(value2)
        matcher.negated_message(partial).should contain(value2.to_s)
      end
    end
  end
end

require "../spec_helper"

describe Spectator::Matchers::HaveValueMatcher do
  describe "#match?" do
    context "with an existing value" do
      it "is true" do
        hash = Hash{"foo" => "bar"}
        value = "bar"
        partial = new_partial(hash)
        matcher = Spectator::Matchers::HaveValueMatcher.new(value)
        matcher.match?(partial).should be_true
      end
    end

    context "with a non-existent value" do
      it "is false" do
        hash = Hash{"foo" => "bar"}
        value = "baz"
        partial = new_partial(hash)
        matcher = Spectator::Matchers::HaveValueMatcher.new(value)
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      hash = Hash{"foo" => "bar"}
      value = "bar"
      label = "blah"
      partial = new_partial(hash, label)
      matcher = Spectator::Matchers::HaveValueMatcher.new(value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      hash = Hash{"foo" => "bar"}
      value = "bar"
      label = "blah"
      partial = new_partial(hash)
      matcher = Spectator::Matchers::HaveValueMatcher.new(value, label)
      matcher.message(partial).should contain(label)
    end

    context "when the expected label is omitted" do
      it "contains the stringified key" do
        hash = Hash{"foo" => "bar"}
        value = "bar"
        partial = new_partial(hash)
        matcher = Spectator::Matchers::HaveValueMatcher.new(value)
        matcher.message(partial).should contain(value.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      hash = Hash{"foo" => "bar"}
      value = "bar"
      label = "blah"
      partial = new_partial(hash, label)
      matcher = Spectator::Matchers::HaveValueMatcher.new(value)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      hash = Hash{"foo" => "bar"}
      value = "bar"
      label = "blah"
      partial = new_partial(hash)
      matcher = Spectator::Matchers::HaveValueMatcher.new(value, label)
      matcher.negated_message(partial).should contain(label)
    end

    context "when the expected label is omitted" do
      it "contains the stringified key" do
        hash = Hash{"foo" => "bar"}
        value = "bar"
        partial = new_partial(hash)
        matcher = Spectator::Matchers::HaveValueMatcher.new(value)
        matcher.negated_message(partial).should contain(value.to_s)
      end
    end
  end
end

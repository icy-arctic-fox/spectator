require "../spec_helper"

describe Spectator::Matchers::HaveKeyMatcher do
  describe "#match?" do
    context "against a Hash" do
      context "with an existing key" do
        it "is true" do
          hash = Hash{"foo" => "bar"}
          key = "foo"
          partial = new_partial(hash)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
          matcher.match?(partial).should be_true
        end
      end

      context "with a non-existent key" do
        it "is false" do
          hash = Hash{"foo" => "bar"}
          key = "baz"
          partial = new_partial(hash)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
          matcher.match?(partial).should be_false
        end
      end
    end

    context "against a NamedTuple" do
      context "with an existing key" do
        it "is true" do
          tuple = {foo: "bar"}
          key = :foo
          partial = new_partial(tuple)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
          matcher.match?(partial).should be_true
        end
      end

      context "with a non-existent key" do
        it "is false" do
          tuple = {foo: "bar"}
          key = :baz
          partial = new_partial(tuple)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
          matcher.match?(partial).should be_false
        end
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      tuple = {foo: "bar"}
      key = :foo
      label = "blah"
      partial = new_partial(tuple, label)
      matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      tuple = {foo: "bar"}
      key = :foo
      label = "blah"
      partial = new_partial(tuple)
      matcher = Spectator::Matchers::HaveKeyMatcher.new(label, key)
      matcher.message(partial).should contain(label)
    end

    context "when the expected label is omitted" do
      it "contains the stringified key" do
        tuple = {foo: "bar"}
        key = :foo
        partial = new_partial(tuple)
        matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
        matcher.message(partial).should contain(key.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      tuple = {foo: "bar"}
      key = :foo
      label = "blah"
      partial = new_partial(tuple, label)
      matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      tuple = {foo: "bar"}
      key = :foo
      label = "blah"
      partial = new_partial(tuple)
      matcher = Spectator::Matchers::HaveKeyMatcher.new(label, key)
      matcher.negated_message(partial).should contain(label)
    end

    context "when the expected label is omitted" do
      it "contains the stringified key" do
        tuple = {foo: "bar"}
        key = :foo
        partial = new_partial(tuple)
        matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
        matcher.negated_message(partial).should contain(key.to_s)
      end
    end
  end
end

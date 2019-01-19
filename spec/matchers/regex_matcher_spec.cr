require "../spec_helper"

describe Spectator::Matchers::RegexMatcher do
  describe "#match?" do
    it "compares using #=~" do
      spy = SpySUT.new
      partial = Spectator::Expectations::ValueExpectationPartial.new(spy)
      matcher = Spectator::Matchers::RegexMatcher.new(/foobar/)
      matcher.match?(partial).should be_true
      spy.match_call_count.should be > 0
    end

    context "with a matching pattern" do
      it "is true" do
        value = "foobar"
        pattern = /foo/
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::RegexMatcher.new(pattern)
        matcher.match?(partial).should be_true
      end
    end

    context "with a non-matching pattern" do
      it "is false" do
        value = "foo"
        pattern = /bar/
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::RegexMatcher.new(pattern)
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "mentions =~" do
      value = "foobar"
      pattern = /foo/
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::RegexMatcher.new(pattern)
      matcher.message(partial).should contain("=~")
    end

    it "contains the actual label" do
      value = "foobar"
      label = "different"
      pattern = /foo/
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::RegexMatcher.new(pattern)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      label = "different"
      pattern = /foo/
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::RegexMatcher.new(label, pattern)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        pattern = /foo/
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::RegexMatcher.new(pattern)
        matcher.message(partial).should contain(pattern.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "mentions =~" do
      value = "foobar"
      pattern = /foo/
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::RegexMatcher.new(pattern)
      matcher.negated_message(partial).should contain("=~")
    end

    it "contains the actual label" do
      value = "foobar"
      label = "different"
      pattern = /foo/
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::RegexMatcher.new(pattern)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      label = "different"
      pattern = /foo/
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::RegexMatcher.new(label, pattern)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        pattern = /foo/
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::RegexMatcher.new(pattern)
        matcher.negated_message(partial).should contain(pattern.to_s)
      end
    end
  end
end

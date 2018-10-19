require "../spec_helper"

describe Spectator::Expectations::ValueExpectation do
  describe "#eval" do
    context "with a successful match" do
      it "returns a successful result" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        matcher.match?(partial).should be_true # Sanity check.
        expectation.eval.successful?.should be_true
      end

      it "reports a successful actual message" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        matcher.match?(partial).should be_true # Sanity check.
        expectation.eval.actual_message.should eq(expectation.message)
      end
    end

    context "with an unsuccessful match" do
      it "returns an unsuccessful result" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        matcher.match?(partial).should be_false # Sanity check.
        expectation.eval.successful?.should be_false
      end

      it "reports an unsuccessful actual message" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        matcher.match?(partial).should be_false # Sanity check.
        expectation.eval.actual_message.should eq(expectation.negated_message)
      end
    end

    it "reports a non-negated expected message" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value)
      expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
      expectation.eval.expected_message.should eq(expectation.message)
    end

    context "negated" do
      context "with a successful match" do
        it "returns an unsuccessful result" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::EqualityMatcher.new(value)
          expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
          matcher.match?(partial).should be_true # Sanity check.
          expectation.eval(true).successful?.should be_false
        end

        it "reports an unsuccessful actual message" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::EqualityMatcher.new(value)
          expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
          matcher.match?(partial).should be_true # Sanity check.
          expectation.eval(true).actual_message.should eq(expectation.negated_message)
        end
      end

      context "with an unsuccessful match" do
        it "returns a successful result" do
          value1 = 42
          value2 = 777
          partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
          matcher = Spectator::Matchers::EqualityMatcher.new(value2)
          expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
          matcher.match?(partial).should be_false # Sanity check.
          expectation.eval(true).successful?.should be_true
        end

        it "reports a successful actual message" do
          value1 = 42
          value2 = 777
          partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
          matcher = Spectator::Matchers::EqualityMatcher.new(value2)
          expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
          matcher.match?(partial).should be_false # Sanity check.
          expectation.eval(true).actual_message.should eq(expectation.message)
        end
      end

      it "reports a negated expected message" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        expectation.eval(true).expected_message.should eq(expectation.negated_message)
      end
    end
  end

  describe "#satisifed?" do
    context "with a successful match" do
      it "is true" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        matcher.match?(partial).should be_true # Sanity check.
        expectation.satisfied?.should be_true
      end
    end

    context "with an unsuccessful match" do
      it "is false" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
        expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
        matcher.match?(partial).should be_false # Sanity check.
        expectation.satisfied?.should be_false
      end
    end
  end

  describe "#message" do
    it "equals the matcher's #message" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
      expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
      expectation.message.should eq(matcher.message(partial))
    end
  end

  describe "#negated_message" do
    it "equals the matcher's #negated_message" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
      matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
      expectation = Spectator::Expectations::ValueExpectation.new(partial, matcher)
      expectation.negated_message.should eq(matcher.negated_message(partial))
    end
  end
end

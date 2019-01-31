require "../spec_helper"

describe Spectator::Expectations::Expectation do
  describe "#satisifed?" do
    context "with a successful match" do
      it "is true" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
        expectation = Spectator::Expectations::Expectation.new(true, false, partial, matcher)
        matcher.match?(partial).should be_true # Sanity check.
        expectation.satisfied?.should be_true
      end

      context "when negated" do
        it "is false" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
          matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
          expectation = Spectator::Expectations::Expectation.new(true, true, partial, matcher)
          matcher.match?(partial).should be_true # Sanity check.
          expectation.satisfied?.should be_false
        end
      end
    end

    context "with an unsuccessful match" do
      it "is false" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
        expectation = Spectator::Expectations::Expectation.new(false, false, partial, matcher)
        matcher.match?(partial).should be_false # Sanity check.
        expectation.satisfied?.should be_false
      end

      context "when negated" do
        it "is true" do
          value1 = 42
          value2 = 777
          partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
          matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
          expectation = Spectator::Expectations::Expectation.new(false, true, partial, matcher)
          matcher.match?(partial).should be_false # Sanity check.
          expectation.satisfied?.should be_true
        end
      end
    end
  end

  describe "#actual_message" do
    context "with a successful match" do
      it "equals the matcher's #message" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
        expectation = Spectator::Expectations::Expectation.new(true, false, partial, matcher)
        matcher.match?(partial).should be_true # Sanity check.
        expectation.actual_message.should eq(matcher.message(partial))
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
          matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
          expectation = Spectator::Expectations::Expectation.new(true, true, partial, matcher)
          matcher.match?(partial).should be_true # Sanity check.
          expectation.actual_message.should eq(matcher.negated_message(partial))
        end
      end
    end

    context "with an unsuccessful match" do
      it "equals the matcher's #negated_message" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
        expectation = Spectator::Expectations::Expectation.new(false, false, partial, matcher)
        matcher.match?(partial).should be_false # Sanity check.
        expectation.actual_message.should eq(matcher.negated_message(partial))
      end

      context "when negated" do
        it "equals the matcher's #message" do
          value1 = 42
          value2 = 777
          partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
          matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
          expectation = Spectator::Expectations::Expectation.new(false, true, partial, matcher)
          matcher.match?(partial).should be_false # Sanity check.
          expectation.actual_message.should eq(matcher.message(partial))
        end
      end
    end
  end

  describe "#expected_message" do
    context "with a successful match" do
      it "equals the matcher's #message" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
        matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
        expectation = Spectator::Expectations::Expectation.new(true, false, partial, matcher)
        matcher.match?(partial).should be_true # Sanity check.
        expectation.expected_message.should eq(matcher.message(partial))
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value.to_s, value)
          matcher = Spectator::Matchers::EqualityMatcher.new(value.to_s, value)
          expectation = Spectator::Expectations::Expectation.new(true, true, partial, matcher)
          matcher.match?(partial).should be_true # Sanity check.
          expectation.expected_message.should eq(matcher.negated_message(partial))
        end
      end
    end

    context "with an unsuccessful match" do
      it "equals the matcher's #message" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
        matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
        expectation = Spectator::Expectations::Expectation.new(false, false, partial, matcher)
        matcher.match?(partial).should be_false # Sanity check.
        expectation.expected_message.should eq(matcher.message(partial))
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          value1 = 42
          value2 = 777
          partial = Spectator::Expectations::ValueExpectationPartial.new(value1.to_s, value1)
          matcher = Spectator::Matchers::EqualityMatcher.new(value2.to_s, value2)
          expectation = Spectator::Expectations::Expectation.new(false, true, partial, matcher)
          matcher.match?(partial).should be_false # Sanity check.
          expectation.expected_message.should eq(matcher.negated_message(partial))
        end
      end
    end
  end
end

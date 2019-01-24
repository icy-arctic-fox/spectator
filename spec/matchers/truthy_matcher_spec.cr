require "../spec_helper"

# This is a terrible hack,
# but I don't want to expose `ValueMatcher#expected` publicly
# just for this spec.
module Spectator::Matchers
  struct ValueMatcher(ExpectedType)
    def expected_value
      expected
    end
  end
end

def be_comparison
  Spectator::Matchers::TruthyMatcher.new(true)
end

describe Spectator::Matchers::TruthyMatcher do
  context "truthy" do
    describe "#match?" do
      context "with a truthy value" do
        it "is true" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::TruthyMatcher.new(true)
          matcher.match?(partial).should be_true
        end
      end

      context "with false" do
        it "is false" do
          value = false
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::TruthyMatcher.new(true)
          matcher.match?(partial).should be_false
        end
      end

      context "with nil" do
        it "is false" do
          value = nil
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::TruthyMatcher.new(true)
          matcher.match?(partial).should be_false
        end
      end
    end

    describe "#message" do
      it "contains the actual label" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
        matcher = Spectator::Matchers::TruthyMatcher.new(true)
        matcher.message(partial).should contain(label)
      end

      it "contains the \"truthy\"" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::TruthyMatcher.new(true)
        matcher.message(partial).should contain("truthy")
      end
    end

    describe "#negated_message" do
      it "contains the actual label" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
        matcher = Spectator::Matchers::TruthyMatcher.new(true)
        matcher.negated_message(partial).should contain(label)
      end

      it "contains the \"truthy\"" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::TruthyMatcher.new(true)
        matcher.negated_message(partial).should contain("truthy")
      end
    end
  end

  context "falsey" do
    describe "#match?" do
      context "with a truthy value" do
        it "is false" do
          value = 42
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::TruthyMatcher.new(false)
          matcher.match?(partial).should be_false
        end
      end

      context "with false" do
        it "is true" do
          value = false
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::TruthyMatcher.new(false)
          matcher.match?(partial).should be_true
        end
      end

      context "with nil" do
        it "is true" do
          value = nil
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::TruthyMatcher.new(false)
          matcher.match?(partial).should be_true
        end
      end
    end

    describe "#message" do
      it "contains the actual label" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
        matcher = Spectator::Matchers::TruthyMatcher.new(false)
        matcher.message(partial).should contain(label)
      end

      it "contains the \"falsey\"" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::TruthyMatcher.new(false)
        matcher.message(partial).should contain("falsey")
      end
    end

    describe "#negated_message" do
      it "contains the actual label" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
        matcher = Spectator::Matchers::TruthyMatcher.new(false)
        matcher.negated_message(partial).should contain(label)
      end

      it "contains the \"falsey\"" do
        value = 42
        label = "everything"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::TruthyMatcher.new(false)
        matcher.negated_message(partial).should contain("falsey")
      end
    end
  end

  describe "#<" do
    it "returns a LessThanMatcher" do
      value = 0
      matcher = be_comparison < value
      matcher.should be_a(Spectator::Matchers::LessThanMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison < value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#<=" do
    it "returns a LessThanEqualMatcher" do
      value = 0
      matcher = be_comparison <= value
      matcher.should be_a(Spectator::Matchers::LessThanEqualMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison <= value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#>" do
    it "returns a GreaterThanMatcher" do
      value = 0
      matcher = be_comparison > value
      matcher.should be_a(Spectator::Matchers::GreaterThanMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison > value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#>=" do
    it "returns a GreaterThanEqualMatcher" do
      value = 0
      matcher = be_comparison >= value
      matcher.should be_a(Spectator::Matchers::GreaterThanEqualMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison >= value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#==" do
    it "returns an EqualityMatcher" do
      value = 0
      matcher = be_comparison == value
      matcher.should be_a(Spectator::Matchers::EqualityMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison == value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#!=" do
    it "returns an InequalityMatcher" do
      value = 0
      matcher = be_comparison != value
      matcher.should be_a(Spectator::Matchers::InequalityMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison != value
      matcher.expected_value.should eq(value)
    end
  end
end

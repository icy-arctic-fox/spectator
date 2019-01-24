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
  Spectator::Matchers::BeComparison.new
end

describe Spectator::Matchers::BeComparison do
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

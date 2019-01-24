require "../spec_helper"

describe Spectator::Matchers::InequalityMatcher do
  describe "#match?" do
    it "compares using #!=" do
      spy = SpySUT.new
      partial = Spectator::Expectations::ValueExpectationPartial.new(spy)
      matcher = Spectator::Matchers::InequalityMatcher.new(42)
      matcher.match?(partial).should be_true
      spy.ne_call_count.should be > 0
    end

    context "with identical values" do
      it "is false" do
        value = 42
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::InequalityMatcher.new(value)
        matcher.match?(partial).should be_false
      end
    end

    context "with different values" do
      it "is true" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::InequalityMatcher.new(value2)
        matcher.match?(partial).should be_true
      end
    end

    context "with the same instance" do
      it "is false" do
        # Box is used because it is a reference type and doesn't override the == method.
        ref = Box.new([] of Int32)
        partial = Spectator::Expectations::ValueExpectationPartial.new(ref)
        matcher = Spectator::Matchers::InequalityMatcher.new(ref)
        matcher.match?(partial).should be_false
      end
    end

    context "with different instances" do
      context "with same contents" do
        it "is false" do
          array1 = [1, 2, 3]
          array2 = [1, 2, 3]
          partial = Spectator::Expectations::ValueExpectationPartial.new(array1)
          matcher = Spectator::Matchers::InequalityMatcher.new(array2)
          matcher.match?(partial).should be_false
        end
      end

      context "with different contents" do
        it "is true" do
          array1 = [1, 2, 3]
          array2 = [4, 5, 6]
          partial = Spectator::Expectations::ValueExpectationPartial.new(array1)
          matcher = Spectator::Matchers::InequalityMatcher.new(array2)
          matcher.match?(partial).should be_true
        end
      end
    end
  end

  describe "#message" do
    it "mentions !=" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::InequalityMatcher.new(value)
      matcher.message(partial).should contain("!=")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::InequalityMatcher.new(value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::InequalityMatcher.new(label, value)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::InequalityMatcher.new(value2)
        matcher.message(partial).should contain(value2.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "mentions !=" do
      value = 42
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::InequalityMatcher.new(value)
      matcher.negated_message(partial).should contain("!=")
    end

    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::InequalityMatcher.new(value)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::InequalityMatcher.new(label, value)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::InequalityMatcher.new(value2)
        matcher.negated_message(partial).should contain(value2.to_s)
      end
    end
  end
end

require "../spec_helper"

describe Spectator::Matchers::RangeMatcher do
  describe "#match?" do
    it "compares using #includes?" do
      spy = SpySUT.new
      partial = Spectator::Expectations::ValueExpectationPartial.new(5)
      matcher = Spectator::Matchers::RangeMatcher.new(spy)
      matcher.match?(partial).should be_true
      spy.includes_call_count.should be > 0
    end

    context "given a Range" do
      context "inclusive" do
        it "is true for lower-bound" do
          lower = 3
          upper = 9
          value = lower
          range = Range.new(lower, upper, exclusive: false)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_true
        end

        it "is false for lower-bound minus 1" do
          lower = 3
          upper = 9
          value = lower - 1
          range = Range.new(lower, upper, exclusive: false)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_false
        end

        it "is true for mid-range" do
          lower = 3
          upper = 9
          value = 5
          range = Range.new(lower, upper, exclusive: false)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_true
        end

        it "is true for upper-bound" do
          lower = 3
          upper = 9
          value = upper
          range = Range.new(lower, upper, exclusive: false)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_true
        end

        it "is false for upper-bound plus 1" do
          lower = 3
          upper = 9
          value = upper + 1
          range = Range.new(lower, upper, exclusive: false)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_false
        end
      end

      context "exclusive" do
        it "is true for lower-bound" do
          lower = 3
          upper = 9
          value = lower
          range = Range.new(lower, upper, exclusive: true)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_true
        end

        it "is false for lower-bound minus 1" do
          lower = 3
          upper = 9
          value = lower - 1
          range = Range.new(lower, upper, exclusive: true)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_false
        end

        it "is true for mid-range" do
          lower = 3
          upper = 9
          value = 5
          range = Range.new(lower, upper, exclusive: true)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_true
        end

        it "is false for upper-bound" do
          lower = 3
          upper = 9
          value = upper
          range = Range.new(lower, upper, exclusive: true)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_false
        end

        it "is false for upper-bound plus 1" do
          lower = 3
          upper = 9
          value = upper + 1
          range = Range.new(lower, upper, exclusive: true)
          partial = Spectator::Expectations::ValueExpectationPartial.new(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          matcher.match?(partial).should be_false
        end
      end
    end

    context "given an Enumerable" do
      it "is true for an existing item" do
        array = %i[a b c]
        value = :b
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::RangeMatcher.new(array)
        matcher.match?(partial).should be_true
      end

      it "is false for a non-existing item" do
        array = %i[a b c]
        value = :z
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::RangeMatcher.new(array)
        matcher.match?(partial).should be_false
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::RangeMatcher.new(value)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::RangeMatcher.new(label, value)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::RangeMatcher.new(value2)
        matcher.message(partial).should contain(value2.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::RangeMatcher.new(value)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = 42
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::RangeMatcher.new(label, value)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value1 = 42
        value2 = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(value1)
        matcher = Spectator::Matchers::RangeMatcher.new(value2)
        matcher.negated_message(partial).should contain(value2.to_s)
      end
    end
  end
end

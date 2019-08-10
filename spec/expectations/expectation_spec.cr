require "../spec_helper"

describe Spectator::Expectations::Expectation do
  describe "#satisifed?" do
    context "with a successful match" do
      it "is true" do
        value = 42
        matcher = new_matcher(value)
        partial = new_partial(value)
        match_data = matcher.match(partial.actual)
        match_data.matched?.should be_true # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, partial.source)
        expectation.satisfied?.should be_true
      end

      context "when negated" do
        it "is false" do
          value = 42
          matcher = new_matcher(value)
          partial = new_partial(value)
          match_data = matcher.negated_match(partial.actual)
          match_data.matched?.should be_false # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, partial.source)
          expectation.satisfied?.should be_false
        end
      end
    end

    context "with an unsuccessful match" do
      it "is false" do
        matcher = new_matcher(42)
        partial = new_partial(777)
        match_data = matcher.match(partial.actual)
        match_data.matched?.should be_false # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, partial.source)
        expectation.satisfied?.should be_false
      end

      context "when negated" do
        it "is true" do
          matcher = new_matcher(42)
          partial = new_partial(777)
          match_data = matcher.negated_match(partial.actual)
          match_data.matched?.should be_true # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, partial.source)
          expectation.satisfied?.should be_true
        end
      end
    end
  end
end

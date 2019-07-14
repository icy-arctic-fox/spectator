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

  describe "#values" do
    it "is the same as the match data values" do
      value = 42
      match_data = new_matcher(value).match(new_partial(value))
      expectation = Spectator::Expectations::Expectation.new(match_data, false)
      expectation_values = expectation.values
      match_data.values.zip(expectation_values).each do |m, e|
        m.label.should eq(e.label)
        m.value.value.should eq(e.value.value)
      end
    end

    context "when negated" do
      it "negates all negatable values" do
        value = 42
        match_data = new_matcher(value).match(new_partial(value))
        expectation = Spectator::Expectations::Expectation.new(match_data, true)
        expectation.values.each do |labeled_value|
          label = labeled_value.label
          value = labeled_value.value
          value.to_s.should start_with(/not/i) if label == :expected
        end
      end
    end
  end

  describe "#actual_message" do
    context "with a successful match" do
      it "equals the matcher's #message" do
        value = 42
        match_data = new_matcher(value).match(new_partial(value))
        match_data.matched?.should be_true # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.actual_message.should eq(match_data.message)
      end

      context "when negated" do
        it "equals the matcher's #message" do
          value = 42
          match_data = new_matcher(value).match(new_partial(value))
          match_data.matched?.should be_true # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.actual_message.should eq(match_data.message)
        end
      end
    end

    context "with an unsuccessful match" do
      it "equals the matcher's #negated_message" do
        match_data = new_matcher(42).match(new_partial(777))
        match_data.matched?.should be_false # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.actual_message.should eq(match_data.negated_message)
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          match_data = new_matcher(42).match(new_partial(777))
          match_data.matched?.should be_false # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.actual_message.should eq(match_data.negated_message)
        end
      end
    end
  end

  describe "#expected_message" do
    context "with a successful match" do
      it "equals the matcher's #message" do
        value = 42
        match_data = new_matcher(value).match(new_partial(value))
        match_data.matched?.should be_true # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.expected_message.should eq(match_data.message)
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          value = 42
          match_data = new_matcher(value).match(new_partial(value))
          match_data.matched?.should be_true # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.expected_message.should eq(match_data.negated_message)
        end
      end
    end

    context "with an unsuccessful match" do
      it "equals the matcher's #message" do
        match_data = new_matcher(42).match(new_partial(777))
        match_data.matched?.should be_false # Sanity check.
        expectation = Spectator::Expectations::Expectation.new(match_data, false)
        expectation.expected_message.should eq(match_data.message)
      end

      context "when negated" do
        it "equals the matcher's #negated_message" do
          match_data = new_matcher(42).match(new_partial(777))
          match_data.matched?.should be_false # Sanity check.
          expectation = Spectator::Expectations::Expectation.new(match_data, true)
          expectation.expected_message.should eq(match_data.negated_message)
        end
      end
    end
  end
end

require "../spec_helper"

describe Spectator::Matchers::RangeMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "inclusive" do
          it "is true for lower-bound" do
            lower = 3
            upper = 9
            value = lower
            range = Range.new(lower, upper, exclusive: false)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is false for lower-bound minus 1" do
            lower = 3
            upper = 9
            value = lower - 1
            range = Range.new(lower, upper, exclusive: false)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end

          it "is true for mid-range" do
            lower = 3
            upper = 9
            value = 5
            range = Range.new(lower, upper, exclusive: false)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is true for upper-bound" do
            lower = 3
            upper = 9
            value = upper
            range = Range.new(lower, upper, exclusive: false)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is false for upper-bound plus 1" do
            lower = 3
            upper = 9
            value = upper + 1
            range = Range.new(lower, upper, exclusive: false)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        context "exclusive" do
          it "is true for lower-bound" do
            lower = 3
            upper = 9
            value = lower
            range = Range.new(lower, upper, exclusive: true)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is false for lower-bound minus 1" do
            lower = 3
            upper = 9
            value = lower - 1
            range = Range.new(lower, upper, exclusive: true)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end

          it "is true for mid-range" do
            lower = 3
            upper = 9
            value = 5
            range = Range.new(lower, upper, exclusive: true)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is false for upper-bound" do
            lower = 3
            upper = 9
            value = upper
            range = Range.new(lower, upper, exclusive: true)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end

          it "is false for upper-bound plus 1" do
            lower = 3
            upper = 9
            value = upper + 1
            range = Range.new(lower, upper, exclusive: true)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "lower" do
          it "is #begin from the expected range" do
            range = Range.new(3, 9)
            partial = new_partial(5)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :lower)[:value].should eq(range.begin)
          end

          it "is prefixed with >=" do
            range = Range.new(3, 9)
            partial = new_partial(5)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :lower)[:to_s].should start_with(">=")
          end
        end

        context "upper" do
          it "is #end from the expected range" do
            range = Range.new(3, 9)
            partial = new_partial(5)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :upper)[:value].should eq(range.end)
          end

          context "when inclusive" do
            it "is prefixed with <=" do
              range = Range.new(3, 9, exclusive: false)
              partial = new_partial(5)
              matcher = Spectator::Matchers::RangeMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :upper)[:to_s].should start_with("<=")
            end
          end

          context "when exclusive" do
            it "is prefixed with <" do
              range = Range.new(3, 9, exclusive: false)
              partial = new_partial(5)
              matcher = Spectator::Matchers::RangeMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :upper)[:to_s].should start_with("<")
            end
          end
        end

        context "actual" do
          it "is the actual value" do
            value = 5
            range = Range.new(3, 9)
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(value)
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          range = 1..10
          value = 5
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          range = 1..10
          value = 5
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            range = 1..10
            value = 5
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.message.should contain(range.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          range = 1..10
          value = 5
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::RangeMatcher.new(range)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          range = 1..10
          value = 5
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            range = 1..10
            value = 5
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(range)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(range.to_s)
          end
        end
      end
    end
  end

  describe "#inclusive" do
    context "initially exclusive" do
      it "is true for lower-bound" do
        lower = 3
        upper = 9
        value = lower
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for lower-bound minus 1" do
        lower = 3
        upper = 9
        value = lower - 1
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      it "is true for mid-range" do
        lower = 3
        upper = 9
        value = 5
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is true for upper-bound" do
        lower = 3
        upper = 9
        value = upper
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for upper-bound plus 1" do
        lower = 3
        upper = 9
        value = upper + 1
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      describe "#message" do
        it "mentions inclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
          match_data = matcher.match(partial)
          match_data.message.should contain("inclusive")
        end

        it "does not mention exclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
          match_data = matcher.match(partial)
          match_data.message.should_not contain("exclusive")
        end

        it "contains the original label" do
          range = 1...10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).inclusive
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "mentions inclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("inclusive")
        end

        it "does not mention exclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should_not contain("exclusive")
        end

        it "contains the original label" do
          range = 1...10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).inclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end

    context "initially inclusive" do
      it "is true for lower-bound" do
        lower = 3
        upper = 9
        value = lower
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for lower-bound minus 1" do
        lower = 3
        upper = 9
        value = lower - 1
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      it "is true for mid-range" do
        lower = 3
        upper = 9
        value = 5
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is true for upper-bound" do
        lower = 3
        upper = 9
        value = upper
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for upper-bound plus 1" do
        lower = 3
        upper = 9
        value = upper + 1
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      describe "#message" do
        it "mentions inclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
          match_data = matcher.match(partial)
          match_data.message.should contain("inclusive")
        end

        it "contains the original label" do
          range = 1..10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).inclusive
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "mentions inclusive" do
          range = 1..10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).inclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("inclusive")
        end

        it "contains the original label" do
          range = 1...10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).inclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end
  end

  describe "#exclusive" do
    context "initially inclusive" do
      it "is true for lower-bound" do
        lower = 3
        upper = 9
        value = lower
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for lower-bound minus 1" do
        lower = 3
        upper = 9
        value = lower - 1
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      it "is true for mid-range" do
        lower = 3
        upper = 9
        value = 5
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for upper-bound" do
        lower = 3
        upper = 9
        value = upper
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      it "is false for upper-bound plus 1" do
        lower = 3
        upper = 9
        value = upper + 1
        range = Range.new(lower, upper, exclusive: false)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      describe "#message" do
        it "mentions exclusive" do
          range = 1..10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
          match_data = matcher.match(partial)
          match_data.message.should contain("exclusive")
        end

        it "does not mention inclusive" do
          range = 1..10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
          match_data = matcher.match(partial)
          match_data.message.should_not contain("inclusive")
        end

        it "contains the original label" do
          range = 1..10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).exclusive
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "mentions exclusive" do
          range = 1..10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("exclusive")
        end

        it "does not mention inclusive" do
          range = 1..10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should_not contain("inclusive")
        end

        it "contains the original label" do
          range = 1..10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).exclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end

    context "initially exclusive" do
      it "is true for lower-bound" do
        lower = 3
        upper = 9
        value = lower
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for lower-bound minus 1" do
        lower = 3
        upper = 9
        value = lower - 1
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      it "is true for mid-range" do
        lower = 3
        upper = 9
        value = 5
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_true
      end

      it "is false for upper-bound" do
        lower = 3
        upper = 9
        value = upper
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      it "is false for upper-bound plus 1" do
        lower = 3
        upper = 9
        value = upper + 1
        range = Range.new(lower, upper, exclusive: true)
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
        match_data = matcher.match(partial)
        match_data.matched?.should be_false
      end

      describe "#message" do
        it "mentions exclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
          match_data = matcher.match(partial)
          match_data.message.should contain("exclusive")
        end

        it "contains the original label" do
          range = 1...10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).exclusive
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "mentions exclusive" do
          range = 1...10
          value = 5
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range).exclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("exclusive")
        end

        it "contains the original label" do
          range = 1...10
          value = 5
          label = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RangeMatcher.new(range, label).exclusive
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end
  end
end

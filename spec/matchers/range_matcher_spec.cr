require "../spec_helper"

describe Spectator::Matchers::RangeMatcher do
  describe "#match" do
    it "compares using #includes?" do
      spy = SpySUT.new
      partial = new_partial(5)
      matcher = Spectator::Matchers::RangeMatcher.new(spy)
      matcher.match(partial)
      spy.includes_call_count.should be > 0
    end

    context "returned MatchData" do
      describe "#matched?" do
        context "given a Range" do
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

        context "given an Enumerable" do
          it "is true for an existing item" do
            array = %i[a b c]
            value = :b
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is false for a non-existing item" do
            array = %i[a b c]
            value = :z
            partial = new_partial(value)
            matcher = Spectator::Matchers::RangeMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "given a Range" do
          context "lower" do
            it "is #begin from the expected range" do
              range = Range.new(3, 9)
              partial = new_partial(5)
              matcher = Spectator::Matchers::RangeMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_prefix(match_data, :lower)[:value].should eq(range.begin)
            end

            it "is prefixed with >=" do
              range = Range.new(3, 9)
              partial = new_partial(5)
              matcher = Spectator::Matchers::RangeMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_prefix(match_data, :lower)[:to_s].should start_with(">=")
            end
          end

          context "upper" do
            it "is #end from the expected range" do
              range = Range.new(3, 9)
              partial = new_partial(5)
              matcher = Spectator::Matchers::RangeMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_prefix(match_data, :upper)[:value].should eq(range.end)
            end

            context "when inclusive" do
              it "is prefixed with <=" do
                range = Range.new(3, 9, exclusive: false)
                partial = new_partial(5)
                matcher = Spectator::Matchers::RangeMatcher.new(range)
                match_data = matcher.match(partial)
                match_data_prefix(match_data, :upper)[:to_s].should start_with("<=")
              end
            end

            context "when exclusive" do
              it "is prefixed with <" do
                range = Range.new(3, 9, exclusive: false)
                partial = new_partial(5)
                matcher = Spectator::Matchers::RangeMatcher.new(range)
                match_data = matcher.match(partial)
                match_data_prefix(match_data, :upper)[:to_s].should start_with("<")
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
              match_data_value(match_data, :actual).should eq(value)
            end
          end
        end

        context "given an Enumerable" do
          context "set" do
            it "is the expected value" do
              array = %i[a b c]
              value = :z
              partial = new_partial(value)
              matcher = Spectator::Matchers::RangeMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_prefix(match_data, :set)[:value].should eq(array)
            end
          end

          context "actual" do
            it "is the actual value" do
              array = %i[a b c]
              value = :z
              partial = new_partial(value)
              matcher = Spectator::Matchers::RangeMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_value(match_data, :actual).should eq(value)
            end
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

  describe "#of" do
    it "is true for lower-bound" do
      center = 5
      diff = 4
      lower = center - diff
      value = lower
      partial = new_partial(value)
      matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_true
    end

    it "is false for lower-bound minus 1" do
      center = 5
      diff = 4
      lower = center - diff
      value = lower - 1
      partial = new_partial(value)
      matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_false
    end

    it "is true for mid-range" do
      center = 5
      diff = 4
      value = center
      partial = new_partial(value)
      matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_true
    end

    it "is true for upper-bound" do
      center = 5
      diff = 4
      upper = center + diff
      value = upper
      partial = new_partial(value)
      matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_true
    end

    it "is false for upper-bound plus 1" do
      center = 5
      diff = 4
      upper = center + diff
      value = upper + 1
      partial = new_partial(value)
      matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_false
    end

    describe "#message" do
      it "contains the original label" do
        center = 5
        diff = 4
        value = 3
        label = "foobar"
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(diff, label).of(center)
        match_data = matcher.match(partial)
        match_data.message.should contain(label)
      end

      it "contains the center" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.message.should contain(center.to_s)
      end

      it "contains the diff" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.message.should contain(diff.to_s)
      end
    end

    describe "#negated_message" do
      it "contains the original label" do
        center = 5
        diff = 4
        value = 3
        label = "foobar"
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(diff, label).of(center)
        match_data = matcher.match(partial)
        match_data.negated_message.should contain(label)
      end

      it "contains the center" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.negated_message.should contain(center.to_s)
      end

      it "contains the diff" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::RangeMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.negated_message.should contain(diff.to_s)
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

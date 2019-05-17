require "../spec_helper"

describe Spectator::Matchers::CollectionMatcher do
  describe "#match" do
    it "compares using #includes?" do
      spy = SpySUT.new
      partial = new_partial(5)
      matcher = Spectator::Matchers::CollectionMatcher.new(spy)
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
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end

            it "is false for lower-bound minus 1" do
              lower = 3
              upper = 9
              value = lower - 1
              range = Range.new(lower, upper, exclusive: false)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end

            it "is true for mid-range" do
              lower = 3
              upper = 9
              value = 5
              range = Range.new(lower, upper, exclusive: false)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end

            it "is true for upper-bound" do
              lower = 3
              upper = 9
              value = upper
              range = Range.new(lower, upper, exclusive: false)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end

            it "is false for upper-bound plus 1" do
              lower = 3
              upper = 9
              value = upper + 1
              range = Range.new(lower, upper, exclusive: false)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
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
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end

            it "is false for lower-bound minus 1" do
              lower = 3
              upper = 9
              value = lower - 1
              range = Range.new(lower, upper, exclusive: true)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end

            it "is true for mid-range" do
              lower = 3
              upper = 9
              value = 5
              range = Range.new(lower, upper, exclusive: true)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end

            it "is false for upper-bound" do
              lower = 3
              upper = 9
              value = upper
              range = Range.new(lower, upper, exclusive: true)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end

            it "is false for upper-bound plus 1" do
              lower = 3
              upper = 9
              value = upper + 1
              range = Range.new(lower, upper, exclusive: true)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
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
            matcher = Spectator::Matchers::CollectionMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end

          it "is false for a non-existing item" do
            array = %i[a b c]
            value = :z
            partial = new_partial(value)
            matcher = Spectator::Matchers::CollectionMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "given a Range" do
          context "collection" do
            it "is the expected value" do
              value = 5
              range = Range.new(3, 9)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :collection)[:value].should eq(range)
            end
          end

          context "actual" do
            it "is the actual value" do
              value = 5
              range = Range.new(3, 9)
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(range)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(value)
            end
          end
        end

        context "given an Enumerable" do
          context "collection" do
            it "is the expected value" do
              array = %i[a b c]
              value = :z
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :collection)[:value].should eq(array)
            end
          end

          context "actual" do
            it "is the actual value" do
              array = %i[a b c]
              value = :z
              partial = new_partial(value)
              matcher = Spectator::Matchers::CollectionMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(value)
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
          matcher = Spectator::Matchers::CollectionMatcher.new(range)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          range = 1..10
          value = 5
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::CollectionMatcher.new(range, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            range = 1..10
            value = 5
            partial = new_partial(value)
            matcher = Spectator::Matchers::CollectionMatcher.new(range)
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
          matcher = Spectator::Matchers::CollectionMatcher.new(range)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          range = 1..10
          value = 5
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::CollectionMatcher.new(range, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            range = 1..10
            value = 5
            partial = new_partial(value)
            matcher = Spectator::Matchers::CollectionMatcher.new(range)
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
      matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_true
    end

    it "is false for lower-bound minus 1" do
      center = 5
      diff = 4
      lower = center - diff
      value = lower - 1
      partial = new_partial(value)
      matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_false
    end

    it "is true for mid-range" do
      center = 5
      diff = 4
      value = center
      partial = new_partial(value)
      matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_true
    end

    it "is true for upper-bound" do
      center = 5
      diff = 4
      upper = center + diff
      value = upper
      partial = new_partial(value)
      matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
      match_data = matcher.match(partial)
      match_data.matched?.should be_true
    end

    it "is false for upper-bound plus 1" do
      center = 5
      diff = 4
      upper = center + diff
      value = upper + 1
      partial = new_partial(value)
      matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
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
        matcher = Spectator::Matchers::CollectionMatcher.new(diff, label).of(center)
        match_data = matcher.match(partial)
        match_data.message.should contain(label)
      end

      it "contains the center" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.message.should contain(center.to_s)
      end

      it "contains the diff" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
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
        matcher = Spectator::Matchers::CollectionMatcher.new(diff, label).of(center)
        match_data = matcher.match(partial)
        match_data.negated_message.should contain(label)
      end

      it "contains the center" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.negated_message.should contain(center.to_s)
      end

      it "contains the diff" do
        center = 5
        diff = 4
        value = 3
        partial = new_partial(value)
        matcher = Spectator::Matchers::CollectionMatcher.new(diff).of(center)
        match_data = matcher.match(partial)
        match_data.negated_message.should contain(diff.to_s)
      end
    end
  end
end

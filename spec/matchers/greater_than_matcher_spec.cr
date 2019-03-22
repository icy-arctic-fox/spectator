require "../spec_helper"

describe Spectator::Matchers::GreaterThanMatcher do
  describe "#match" do
    it "compares using #>" do
      spy = SpySUT.new
      partial = new_partial(spy)
      matcher = Spectator::Matchers::GreaterThanMatcher.new(42)
      matcher.match(partial)
      spy.gt_call_count.should be > 0
    end

    context "returned MatchData" do
      describe "#matched?" do
        context "with a larger value" do
          it "is false" do
            actual = 42
            expected = 777
            partial = new_partial(actual)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        context "with a smaller value" do
          it "is true" do
            actual = 777
            expected = 42
            partial = new_partial(actual)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with an equal value" do
          it "is false" do
            value = 42
            partial = new_partial(value)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is the expected value" do
            actual = 777
            expected = 42
            partial = new_partial(actual)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data, :expected)[:value].should eq(expected)
          end

          it "is prefixed with >" do
            actual = 777
            expected = 42
            partial = new_partial(actual)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data, :expected)[:to_s].should start_with(">")
          end
        end

        context "actual" do
          it "is the actual value" do
            actual = 777
            expected = 42
            partial = new_partial(actual)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data, :actual)[:value].should eq(actual)
          end

          context "when #matched? is true" do
            it "is prefixed with >" do
              actual = 777
              expected = 42
              partial = new_partial(actual)
              matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true # Sanity check.
              match_data_value_sans_prefix(match_data, :actual)[:to_s].should start_with(">")
            end
          end

          context "when #matched? is false" do
            it "is prefixed with <=" do
              actual = 42
              expected = 777
              partial = new_partial(actual)
              matcher = Spectator::Matchers::GreaterThanMatcher.new(expected)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false # Sanity check.
              match_data_value_sans_prefix(match_data, :actual)[:to_s].should start_with("<=")
            end
          end
        end
      end

      describe "#message" do
        it "mentions >" do
          value = 42
          partial = new_partial(value)
          matcher = Spectator::Matchers::GreaterThanMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.message.should contain(">")
        end

        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::GreaterThanMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          value = 42
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::GreaterThanMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value1 = 42
            value2 = 777
            partial = new_partial(value1)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(value2)
            match_data = matcher.match(partial)
            match_data.message.should contain(value2.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "mentions >" do
          value = 42
          partial = new_partial(value)
          matcher = Spectator::Matchers::GreaterThanMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(">")
        end

        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::GreaterThanMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          value = 42
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::GreaterThanMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value1 = 42
            value2 = 777
            partial = new_partial(value1)
            matcher = Spectator::Matchers::GreaterThanMatcher.new(value2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(value2.to_s)
          end
        end
      end
    end
  end
end

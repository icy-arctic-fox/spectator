require "../spec_helper"

describe Spectator::Matchers::SizeOfMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "with a matching number of items" do
          it "is true" do
            array = %i[a b c]
            other = [1, 2, 3]
            partial = new_partial(array)
            matcher = Spectator::Matchers::SizeOfMatcher.new(other)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a different number of items" do
          it "is false" do
            array = %i[a b c]
            other = [1, 2, 3, 4]
            partial = new_partial(array)
            matcher = Spectator::Matchers::SizeOfMatcher.new(other)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is the size given" do
            array = %i[a b c]
            other = [1, 2, 3, 4]
            partial = new_partial(array)
            matcher = Spectator::Matchers::SizeOfMatcher.new(other)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(other.size)
          end
        end

        context "actual" do
          it "is the size of the set" do
            array = %i[a b c]
            other = [1, 2, 3, 4]
            partial = new_partial(array)
            matcher = Spectator::Matchers::SizeOfMatcher.new(other)
            match_data = matcher.match(partial)
            match_data_value_with_key(match_data.values, :actual).value.should eq(array.size)
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          array = %i[a b c]
          other = [1, 2, 3, 4]
          label = "foobar"
          partial = new_partial(array, label)
          matcher = Spectator::Matchers::SizeOfMatcher.new(other)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          array = %i[a b c]
          other = [1, 2, 3, 4]
          label = "foobar"
          partial = new_partial(array)
          matcher = Spectator::Matchers::SizeOfMatcher.new(other, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            array = %i[a b c]
            other = [1, 2, 3, 4]
            partial = new_partial(array)
            matcher = Spectator::Matchers::SizeOfMatcher.new(other)
            match_data = matcher.match(partial)
            match_data.message.should contain(other.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          array = %i[a b c]
          other = [1, 2, 3, 4]
          label = "foobar"
          partial = new_partial(array, label)
          matcher = Spectator::Matchers::SizeOfMatcher.new(other)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          array = %i[a b c]
          other = [1, 2, 3, 4]
          label = "foobar"
          partial = new_partial(array)
          matcher = Spectator::Matchers::SizeOfMatcher.new(other, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            array = %i[a b c]
            other = [1, 2, 3, 4]
            partial = new_partial(array)
            matcher = Spectator::Matchers::SizeOfMatcher.new(other)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(other.to_s)
          end
        end
      end
    end
  end
end
